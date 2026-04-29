import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CarBrands extends StatelessWidget {
  final Color _primaryColor = const Color(0xFF0D47A1);

  const CarBrands({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Brands'),
        backgroundColor: _primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("car_brands").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          
          if (docs.isEmpty) {
            return const Center(child: Text('No car brands available'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final Map<String, dynamic> data = docs[index].data() as Map<String, dynamic>;
              
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    'spareparts',
                    arguments: {
                      'brandId': docs[index].id,
                      'brandName': data['name']?.toString() ?? 'Unknown Brand',
                    },
                  );
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: data['logo'] != null
                              ? Image.network(
                                  data['logo'].toString(),
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.car_repair, size: 50),
                                )
                              : const Icon(Icons.car_repair, size: 50),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['name']?.toString() ?? 'Unknown Brand',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
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
    );
  }
}

class ProductCard extends StatelessWidget {
  final String productId;
  final String image;
  final String name;
  final String price;
  final String description;
  final int stock;

  const ProductCard({
    super.key,
    required this.productId,
    required this.image,
    required this.name,
    required this.price,
    required this.description,
    required this.stock,
  });

  Future<void> _addToCart() async {
    try {
      final cartRef = FirebaseFirestore.instance.collection('cart').doc('user_id'); // Replace with actual user ID
      
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

      // Add item to cart
      await cartRef.update({
        'items': FieldValue.arrayUnion([
          {
            'partId': productId,
            'quantity': 1,
            'addedAt': FieldValue.serverTimestamp(),
          }
        ]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding to cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$$price',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      if (stock > 0)
                        IconButton(
                          icon: const Icon(Icons.add_shopping_cart),
                          color: const Color(0xFF0D47A1),
                          onPressed: _addToCart,
                        )
                      else
                        const Text(
                          'Out of Stock',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
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
  }
}