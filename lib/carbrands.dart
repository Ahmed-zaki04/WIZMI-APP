import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wizmi/theme.dart';

class CarBrands extends StatefulWidget {
  const CarBrands({super.key});

  @override
  State<CarBrands> createState() => _CarBrandsState();
}

class _CarBrandsState extends State<CarBrands> {
  final Color _primaryColor = const Color(0xFF0D47A1);
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Brands'),
        backgroundColor: _primaryColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search brands...',
                prefixIcon: Icon(Icons.search, color: AppTheme.primary),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("car_brands").snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                final filtered = _searchQuery.isEmpty
                    ? docs
                    : docs.where((d) {
                        final name = (d.data() as Map)['name']?.toString().toLowerCase() ?? '';
                        return name.contains(_searchQuery);
                      }).toList();

                if (filtered.isEmpty) {
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
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final Map<String, dynamic> data = filtered[index].data() as Map<String, dynamic>;

                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          'spareparts',
                          arguments: {
                            'brandId': filtered[index].id,
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
                                    ? CachedNetworkImage(
                                        imageUrl: data['logo'].toString(),
                                        fit: BoxFit.contain,
                                        placeholder: (_, __) => const Center(
                                            child: CircularProgressIndicator(strokeWidth: 2)),
                                        errorWidget: (_, __, ___) => const Icon(
                                            Icons.directions_car, size: 40, color: Colors.grey),
                                      )
                                    : const Icon(Icons.directions_car, size: 40, color: Colors.grey),
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
          ),
        ],
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
      final cartRef = FirebaseFirestore.instance.collection('cart').doc(FirebaseAuth.instance.currentUser?.uid ?? '');
      
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
                        'EGP $price',
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