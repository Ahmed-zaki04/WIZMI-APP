import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wizmi/checkout.dart';
import 'package:wizmi/theme.dart';

const int _kDeliveryFee = 100;

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('cart').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildEmptyCart();
          }

          final cartData = snapshot.data!.data() as Map<String, dynamic>;
          final items = List<Map<String, dynamic>>.from(cartData['items'] ?? []);

          if (items.isEmpty) return _buildEmptyCart();

          final subtotal = items.fold<int>(
            0,
            (acc, item) => acc + ((item['price'] as int? ?? 0) * (item['quantity'] as int? ?? 1)),
          );
          final grandTotal = subtotal + _kDeliveryFee;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final name = item['name']?.toString() ?? 'Unknown Part';
                    final price = item['price'] as int? ?? 0;
                    final qty = item['quantity'] as int? ?? 1;
                    final partId = item['partId']?.toString() ?? '';

                    return Dismissible(
                      key: Key(partId + index.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppTheme.error,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
                      ),
                      onDismissed: (_) => _removeFromCart(uid, partId),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              // Icon placeholder
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.settings_outlined,
                                    size: 26, color: AppTheme.primary.withValues(alpha: 0.6)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'EGP $price',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Quantity controls
                              Row(
                                children: [
                                  _QtyButton(
                                    icon: Icons.remove_rounded,
                                    onTap: () => _updateQuantity(uid, partId, qty - 1),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Text(
                                      '$qty',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                  _QtyButton(
                                    icon: Icons.add_rounded,
                                    onTap: () => _updateQuantity(uid, partId, qty + 1),
                                    filled: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── Order summary + checkout ──────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SummaryRow(label: 'Subtotal', value: 'EGP $subtotal'),
                      const SizedBox(height: 6),
                      _SummaryRow(
                        label: 'Delivery Fee',
                        value: 'EGP $_kDeliveryFee',
                        valueColor: AppTheme.textSecondary,
                        icon: Icons.local_shipping_outlined,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                          Text('EGP $grandTotal',
                              style: GoogleFonts.poppins(
                                  fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.shopping_bag_outlined),
                          label: Text('Checkout',
                              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
                          onPressed: () => _checkout(context, items, grandTotal.toDouble()),
                        ),
                      ),
                      const SizedBox(height: 8),
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

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shopping_cart_outlined,
                  size: 60, color: AppTheme.primary.withValues(alpha: 0.4)),
            ),
            const SizedBox(height: 24),
            Text('Your cart is empty',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Text('Browse spare parts and add them here',
                style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Future<void> _removeFromCart(String uid, String partId) async {
    try {
      final cartRef = FirebaseFirestore.instance.collection('cart').doc(uid);
      final cartDoc = await cartRef.get();
      if (!cartDoc.exists) return;
      final items = List<Map<String, dynamic>>.from(cartDoc.get('items'));
      items.removeWhere((item) => item['partId'] == partId);
      await cartRef.update({'items': items, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      debugPrint('Error removing from cart: $e');
    }
  }

  Future<void> _updateQuantity(String uid, String partId, int newQty) async {
    if (newQty < 1) {
      await _removeFromCart(uid, partId);
      return;
    }
    try {
      final cartRef = FirebaseFirestore.instance.collection('cart').doc(uid);
      final cartDoc = await cartRef.get();
      if (!cartDoc.exists) return;
      final items = List<Map<String, dynamic>>.from(cartDoc.get('items'));
      final idx = items.indexWhere((item) => item['partId'] == partId);
      if (idx != -1) {
        items[idx]['quantity'] = newQty;
        await cartRef.update({'items': items, 'updatedAt': FieldValue.serverTimestamp()});
      }
    } catch (e) {
      debugPrint('Error updating quantity: $e');
    }
  }

  void _checkout(BuildContext context, List<Map<String, dynamic>> items, double grandTotal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutPage(
          items: items,
          total: grandTotal,
          deliveryFee: _kDeliveryFee,
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  const _QtyButton({required this.icon, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: filled ? AppTheme.primary : AppTheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: filled ? Colors.white : AppTheme.primary),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;

  const _SummaryRow({required this.label, required this.value, this.valueColor, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary)),
          ],
        ),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppTheme.textPrimary)),
      ],
    );
  }
}
