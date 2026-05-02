import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:wizmi/checkout.dart';

class CartPage extends StatelessWidget {
  final Color _primaryColor = const Color(0xFF0D47A1);

  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: _primaryColor,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .doc(FirebaseAuth.instance.currentUser?.uid ?? '')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Your cart is empty'));
          }

          final cartData = snapshot.data!.data() as Map<String, dynamic>;
          final items = List<Map<String, dynamic>>.from(cartData['items'] ?? []);

          if (items.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('product')
                          .doc(item['partId'])
                          .get(),
                      builder: (context, productSnapshot) {
                        if (!productSnapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        final product = productSnapshot.data!.data() as Map<String, dynamic>;

                        return Dismissible(
                          key: Key(item['partId']),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (direction) => _removeFromCart(item['partId']),
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 5,
                            ),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  product['image'],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                product['name'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'EGP ${product['price']}',
                                style: TextStyle(
                                  color: _primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () => _updateQuantity(
                                      item['partId'],
                                      item['quantity'] - 1,
                                    ),
                                  ),
                                  Text(
                                    '${item['quantity']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () => _updateQuantity(
                                      item['partId'],
                                      item['quantity'] + 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          FutureBuilder<double>(
                            future: _calculateTotal(items),
                            builder: (context, snapshot) {
                              return Text(
                                'EGP ${snapshot.data?.toStringAsFixed(2) ?? '0.00'}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: _primaryColor,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _checkout(context),
                          child: const Text(
                            'CHECKOUT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _removeFromCart(String partId) async {
    try {
      final cartRef = FirebaseFirestore.instance.collection('cart').doc(FirebaseAuth.instance.currentUser?.uid ?? '');
      final cartDoc = await cartRef.get();
      if (!cartDoc.exists) return;

      final items = List<Map<String, dynamic>>.from(cartDoc.get('items'));
      items.removeWhere((item) => item['partId'] == partId);

      await cartRef.update({
        'items': items,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error removing from cart: $e');
    }
  }

  Future<void> _updateQuantity(String partId, int newQuantity) async {
    if (newQuantity < 1) {
      await _removeFromCart(partId);
      return;
    }

    try {
      final cartRef = FirebaseFirestore.instance.collection('cart').doc(FirebaseAuth.instance.currentUser?.uid ?? '');
      final cartDoc = await cartRef.get();
      if (!cartDoc.exists) return;

      final items = List<Map<String, dynamic>>.from(cartDoc.get('items'));
      final itemIndex = items.indexWhere((item) => item['partId'] == partId);
      
      if (itemIndex != -1) {
        items[itemIndex]['quantity'] = newQuantity;
        await cartRef.update({
          'items': items,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error updating quantity: $e');
    }
  }

  Future<double> _calculateTotal(List<Map<String, dynamic>> items) async {
    double total = 0;
    for (var item in items) {
      final productDoc = await FirebaseFirestore.instance
          .collection('product')
          .doc(item['partId'])
          .get();
      
      if (productDoc.exists) {
        final product = productDoc.data() as Map<String, dynamic>;
        final price = double.tryParse(product['price'].toString()) ?? 0.0;
        final quantity = item['quantity'] as int;
        total += price * quantity;
      }
    }
    return total;
  }

  Future<void> _checkout(BuildContext context) async {
    try {
      final cartRef = FirebaseFirestore.instance.collection('cart').doc(FirebaseAuth.instance.currentUser?.uid ?? '');
      final cartDoc = await cartRef.get();
      if (!cartDoc.exists) return;

      final items = List<Map<String, dynamic>>.from(cartDoc.get('items'));
      final total = await _calculateTotal(items);

      if (context.mounted) {
        // Navigate to checkout page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CheckoutPage(
              items: items,
              total: total,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error during checkout: $e');
      if (context.mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'Error',
          desc: 'Failed to proceed to checkout. Please try again.',
          btnOkOnPress: () {},
        ).show();
      }
    }
  }
} 