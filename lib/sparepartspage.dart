import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class Product extends StatefulWidget {
  const Product({super.key});

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  final Color _primaryColor = const Color(0xFF0D47A1);
  String? selectedBrandId;
  String? selectedBrandName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          selectedBrandId = args['brandId'];
          selectedBrandName = args['brandName'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedBrandName ?? 'Products'),
        backgroundColor: _primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, 'cart'),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("product").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          
          if (docs.isEmpty) {
            return const Center(child: Text('No products available'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.65,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final Map<String, dynamic> data = docs[index].data() as Map<String, dynamic>;

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: data['image'] != null
                            ? Image.network(
                                data['image'].toString(),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image, size: 50),
                              )
                            : const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name']?.toString() ?? 'Unnamed Product',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (data.containsKey('description') && data['description'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                data['description'].toString(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (data.containsKey('price') && data['price'] != null)
                                  Text(
                                    '\$${data['price']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: _primaryColor,
                                    ),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.add_shopping_cart),
                                  iconSize: 20,
                                  color: _primaryColor,
                                  onPressed: () => _addToCart(docs[index].id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _addToCart(String productId) async {
    try {
      final cartRef = FirebaseFirestore.instance.collection('cart').doc('user_id');
      
      // Check if cart exists
      final cartDoc = await cartRef.get();
      if (!cartDoc.exists) {
        // Create new cart
        await cartRef.set({
          'items': [],
          'total': 0,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Get current cart items
      final cartData = cartDoc.data() as Map<String, dynamic>?;
      final items = List<Map<String, dynamic>>.from(cartData?['items'] ?? []);
      
      // Check if item already exists
      final existingItemIndex = items.indexWhere((item) => item['partId'] == productId);

      if (existingItemIndex != -1) {
        // If item exists, increment quantity
        items[existingItemIndex]['quantity'] = (items[existingItemIndex]['quantity'] ?? 0) + 1;
      } else {
        // If item doesn't exist, add new item
        items.add({
          'partId': productId,
          'quantity': 1,
          'addedAt': DateTime.now().toIso8601String(),
        });
      }

      // Update cart with modified items array
      await cartRef.update({
        'items': items,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Show success message with AwesomeDialog
      _showSuccessDialog(context, 'Item added to cart successfully!');

    } catch (e) {
      debugPrint('Error adding to cart: $e');
      // Show error message with AwesomeDialog
      _showErrorDialog(context, 'Failed to add item to cart. Please try again.');
    }
  }

  void _showSuccessDialog(BuildContext context, String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      title: 'Success',
      desc: message,
      btnOkOnPress: () {
        
      },
      btnOkColor: const Color(0xFF0D47A1),
    ).show();
  }

  void _showErrorDialog(BuildContext context, String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: 'Error',
      desc: message,
      btnOkOnPress: () {},
      btnOkColor: Colors.red,
    ).show();
  }
}
