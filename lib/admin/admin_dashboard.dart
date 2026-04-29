import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:wizmi/services/notification_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final Color _primaryColor = const Color(0xFF0D47A1);
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _migrateExistingRequests();
  }

  Future<void> _migrateExistingRequests() async {
    try {
      debugPrint('Starting migration of existing requests...');
      
      // List of collections to check
      final collections = [
        'towing_requests',
        'mechanic_requests',
        'diagnostic_requests',
        'car_wash_requests',
        'car_rental_requests',
        'parts_orders'
      ];

      for (final collection in collections) {
        debugPrint('Checking collection: $collection');
        
        // Get all documents in the collection
        final querySnapshot = await FirebaseFirestore.instance
            .collection(collection)
            .get();

        for (final doc in querySnapshot.docs) {
          final data = doc.data();
          
          // If document doesn't have userId but has a name/phone
          if (!data.containsKey('userId') && (data['name'] != null || data['phone'] != null)) {
            debugPrint('Found request without userId in $collection: ${doc.id}');
            
            // Try to find the user in the users collection based on name or phone
            QuerySnapshot userQuery = await FirebaseFirestore.instance
                .collection('users')
                .where('name', isEqualTo: data['name'])
                .limit(1)
                .get();

            if (userQuery.docs.isEmpty && data['phone'] != null) {
              userQuery = await FirebaseFirestore.instance
                  .collection('users')
                  .where('phone', isEqualTo: data['phone'])
                  .limit(1)
                  .get();
            }

            if (userQuery.docs.isNotEmpty) {
              // Found matching user, update the request with their ID
              final userId = userQuery.docs.first.id;
              debugPrint('Found matching user: $userId for request: ${doc.id}');
              
              await doc.reference.update({
                'userId': userId,
                'migrated': true,
                'migrationTimestamp': FieldValue.serverTimestamp()
              });
            } else {
              // If no matching user found, mark as legacy request
              debugPrint('No matching user found for request: ${doc.id}');
              await doc.reference.update({
                'isLegacyRequest': true,
                'migrationTimestamp': FieldValue.serverTimestamp()
              });
            }
          }
        }
      }
      debugPrint('Migration completed successfully');
    } catch (e) {
      debugPrint('Error during migration: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: _primaryColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.build_circle_outlined),
            selectedIcon: Icon(Icons.build_circle),
            label: 'Services',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildServicesTab();
      case 1:
        return _buildOrdersTab();
      default:
        return const Center(child: Text('Unknown tab'));
    }
  }

  Widget _buildServicesTab() {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            labelColor: _primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Towing'),
              Tab(text: 'Mechanic'),
              Tab(text: 'Diagnostic'),
              Tab(text: 'Car Wash'),
              Tab(text: 'Car Rental'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildServiceRequests('towing_requests'),
                _buildServiceRequests('mechanic_requests'),
                _buildServiceRequests('diagnostic_requests'),
                _buildServiceRequests('car_wash_requests'),
                _buildServiceRequests('car_rental_requests'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRequests(String collection) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data!.docs;

        if (requests.isEmpty) {
          return const Center(child: Text('No requests found'));
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index].data() as Map<String, dynamic>;
            final status = request['status'] ?? 'pending';
            final timestamp = (request['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ExpansionTile(
                title: Text(
                  '${request['name'] ?? 'Unknown'} - ${request['phone'] ?? 'No phone'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  'Status: ${status.toUpperCase()} - ${_formatDate(timestamp)}',
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontSize: 14,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (request['carModel'] != null)
                          _buildInfoRow('Car Model', request['carModel']),
                        if (request['location'] != null)
                          _buildInfoRow('Location', request['location']),
                        if (request['issueType'] != null)
                          _buildInfoRow('Issue', request['issueType']),
                        if (request['symptoms'] != null)
                          _buildInfoRow('Symptoms', request['symptoms']),
                        if (request['package'] != null)
                          _buildInfoRow('Package', request['package']),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (status == 'pending') ...[
                              ElevatedButton.icon(
                                onPressed: () => _updateStatus(
                                  collection,
                                  requests[index].id,
                                  'accepted',
                                ),
                                icon: const Icon(Icons.check, color: Colors.white),
                                label: const Text('Accept', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _updateStatus(
                                  collection,
                                  requests[index].id,
                                  'rejected',
                                ),
                                icon: const Icon(Icons.close, color: Colors.white),
                                label: const Text('Reject', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                              ),
                            ],
                            if (status == 'accepted')
                              ElevatedButton.icon(
                                onPressed: () => _updateStatus(
                                  collection,
                                  requests[index].id,
                                  'completed',
                                ),
                                icon: const Icon(Icons.done_all, color: Colors.white),
                                label: const Text('Mark Complete', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOrdersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!.docs;

        if (orders.isEmpty) {
          return const Center(child: Text('No orders found'));
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index].data() as Map<String, dynamic>;
            final status = order['status'] ?? 'pending';
            DateTime timestamp;
            final createdAt = order['createdAt'];
            if (createdAt is Timestamp) {
              timestamp = createdAt.toDate();
            } else if (createdAt is String) {
              timestamp = DateTime.parse(createdAt);
            } else {
              timestamp = DateTime.now();
            }

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ExpansionTile(
                title: Text(
                  'Order #${orders[index].id.substring(0, 8)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  'Status: ${status.toUpperCase()} - ${_formatDate(timestamp)}',
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontSize: 14,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Customer', order['customerName'] ?? 'Unknown'),
                        _buildInfoRow('Phone', order['customerPhone'] ?? 'No phone'),
                        _buildInfoRow('Address', order['customerAddress'] ?? 'No address'),
                        _buildInfoRow('Payment', order['paymentMethod'] ?? 'Not specified'),
                        _buildInfoRow('Total', '\$${order['total']?.toStringAsFixed(2) ?? '0.00'}'),
                        const SizedBox(height: 16),
                        const Text(
                          'Items:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...List.from(order['items'] ?? []).map((item) {
                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('product')
                                .doc(item['partId'])
                                .get(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const ListTile(
                                  leading: Icon(Icons.shopping_basket),
                                  title: Text('Loading...'),
                                  dense: true,
                                );
                              }

                              final product = snapshot.data!.data() as Map<String, dynamic>;
                              return ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    product['image'] ?? '',
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.shopping_basket),
                                  ),
                                ),
                                title: Text(
                                  '${item['quantity']}x ${product['name'] ?? 'Unknown Product'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: Text(
                                  '\$${product['price'] ?? '0.00'}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                dense: true,
                              );
                            },
                          );
                        }).toList(),
                        const SizedBox(height: 16),
                        if (status == 'pending')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _updateOrderStatus(
                                  orders[index].id,
                                  'processing',
                                ),
                                icon: const Icon(Icons.check, color: Colors.white),
                                label: const Text('Process', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _updateOrderStatus(
                                  orders[index].id,
                                  'cancelled',
                                ),
                                icon: const Icon(Icons.close, color: Colors.white),
                                label: const Text('Cancel', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        if (status == 'processing')
                          ElevatedButton.icon(
                            onPressed: () => _updateOrderStatus(
                              orders[index].id,
                              'completed',
                            ),
                            icon: const Icon(Icons.done_all, color: Colors.white),
                            label: const Text('Mark Complete', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String collection, String docId, String status) async {
    try {
      debugPrint('Updating status for document $docId in collection $collection');
      final docRef = FirebaseFirestore.instance.collection(collection).doc(docId);
      final docSnapshot = await docRef.get();
      final data = docSnapshot.data();
      
      if (data == null) {
        debugPrint('Document data is null');
        return;
      }

      // Update the request status
      await docRef.update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      String title;
      String message;
      DialogType dialogType;
      Color dialogColor;
      
      switch (status) {
        case 'accepted':
          title = 'Request Accepted';
          message = 'Good news! Your ${_getServiceName(collection)} request has been accepted. We will process it shortly.';
          dialogType = DialogType.success;
          dialogColor = Colors.green;
          break;
        case 'rejected':
          title = 'Request Rejected';
          message = 'We regret to inform you that your ${_getServiceName(collection)} request could not be accepted at this time.';
          dialogType = DialogType.error;
          dialogColor = Colors.red;
          break;
        case 'completed':
          title = 'Service Completed';
          message = 'Thank you for choosing our service! Your ${_getServiceName(collection)} service has been completed. We appreciate your business.';
          dialogType = DialogType.success;
          dialogColor = Colors.green;
          break;
        default:
          return;
      }

      // Create notification in the notifications collection
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': title,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'status': status,
        'serviceType': _getServiceName(collection),
        'isRead': false,
        'userName': data['name'],
        'userPhone': data['phone'],
        'requestId': docId,
        'collection': collection
      });

      // Only move to history collection when the request is completed or rejected
      if (status == 'completed' || status == 'rejected') {
        // First, copy the document to history collection
        await FirebaseFirestore.instance.collection('${collection}_history').add({
          ...data,
          'status': status,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // Then delete from original collection
        await docRef.delete();
      }

      if (mounted) {
        AwesomeDialog(
          context: context,
          dialogType: dialogType,
          animType: AnimType.rightSlide,
          title: title,
          desc: message,
          btnOkOnPress: () {},
          btnOkColor: dialogColor,
        ).show();
      }
    } catch (e) {
      debugPrint('Error updating status: $e');
      if (mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'Error',
          desc: 'Failed to update status: $e',
          btnOkOnPress: () {},
          btnOkColor: Colors.red,
        ).show();
      }
    }
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('orders').doc(orderId);
      final docSnapshot = await docRef.get();
      final data = docSnapshot.data();
      
      if (data == null) return;

      await docRef.update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      String title;
      String message;
      DialogType dialogType;
      Color dialogColor;

      switch (status) {
        case 'processing':
          title = 'Order Processing';
          message = 'Good news! Your order #${orderId.substring(0, 8)} is now being processed.';
          dialogType = DialogType.success;
          dialogColor = Colors.blue;
          break;
        case 'completed':
          title = 'Order Completed';
          message = 'Thank you for your order! Your order #${orderId.substring(0, 8)} has been completed. We appreciate your business.';
          dialogType = DialogType.success;
          dialogColor = Colors.green;
          break;
        case 'cancelled':
          title = 'Order Cancelled';
          message = 'Your order #${orderId.substring(0, 8)} has been cancelled.';
          dialogType = DialogType.error;
          dialogColor = Colors.red;
          break;
        default:
          return;
      }

      // Create notification in the notifications collection
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': title,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'status': status,
        'serviceType': 'Order',
        'isRead': false,
        'userName': data['name'],
        'userPhone': data['phone'],
        'orderId': orderId
      });

      // If order is completed or cancelled, move it to history
      if (status == 'completed' || status == 'cancelled') {
        // First, copy the order to history collection
        await FirebaseFirestore.instance.collection('orders_history').add({
          ...data,
          'status': status,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // Then delete from orders collection
        await docRef.delete();
      }

      if (mounted) {
        AwesomeDialog(
          context: context,
          dialogType: dialogType,
          animType: AnimType.rightSlide,
          title: title,
          desc: message,
          btnOkOnPress: () {},
          btnOkColor: dialogColor,
        ).show();
      }
    } catch (e) {
      debugPrint('Error updating order status: $e');
      if (mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'Error',
          desc: 'Failed to update order status: $e',
          btnOkOnPress: () {},
          btnOkColor: Colors.red,
        ).show();
      }
    }
  }

  String _getServiceName(String collection) {
    switch (collection) {
      case 'towing_requests':
        return 'Towing';
      case 'mechanic_requests':
        return 'Mechanic';
      case 'diagnostic_requests':
        return 'Diagnostic';
      case 'car_wash_requests':
        return 'Car Wash';
      case 'car_rental_requests':
        return 'Car Rental';
      case 'parts_orders':
        return 'Parts Order';
      default:
        return 'Service';
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.rightSlide,
      title: 'Logout',
      desc: 'Are you sure you want to logout?',
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          Navigator.pushReplacementNamed(context, 'admin_login');
        }
      },
      btnOkColor: _primaryColor,
      btnCancelColor: Colors.grey,
    ).show();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
      case 'processing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 