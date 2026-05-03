import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wizmi/theme.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final double total;
  final int deliveryFee;

  const CheckoutPage({
    super.key,
    required this.items,
    required this.total,
    this.deliveryFee = 100,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedPaymentMethod = 'Cash';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = widget.total - widget.deliveryFee;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Delivery Information ────────────────────────────────────────
              _SectionCard(
                title: 'Delivery Information',
                icon: Icons.local_shipping_outlined,
                child: Column(
                  children: [
                    _field(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline_rounded,
                      validator: (v) => (v == null || v.isEmpty) ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 14),
                    _field(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      type: TextInputType.phone,
                      validator: (v) => (v == null || v.isEmpty) ? 'Please enter your phone' : null,
                    ),
                    const SizedBox(height: 14),
                    _field(
                      controller: _addressController,
                      label: 'Delivery Address',
                      icon: Icons.location_on_outlined,
                      maxLines: 3,
                      validator: (v) => (v == null || v.isEmpty) ? 'Please enter your address' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Payment Method ──────────────────────────────────────────────
              _SectionCard(
                title: 'Payment Method',
                icon: Icons.payment_rounded,
                child: Column(
                  children: [
                    _PaymentOption(
                      label: 'Cash on Delivery',
                      icon: Icons.money_rounded,
                      value: 'Cash',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
                    ),
                    _PaymentOption(
                      label: 'Credit / Debit Card',
                      icon: Icons.credit_card_rounded,
                      value: 'Card',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Order Summary ───────────────────────────────────────────────
              _SectionCard(
                title: 'Order Summary',
                icon: Icons.receipt_long_outlined,
                child: Column(
                  children: [
                    ...widget.items.map((item) {
                      final name = item['name']?.toString() ?? 'Part';
                      final price = item['price'] as int? ?? 0;
                      final qty = item['quantity'] as int? ?? 1;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.settings_outlined,
                                  size: 20, color: AppTheme.primary.withValues(alpha: 0.6)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name,
                                      style: GoogleFonts.poppins(
                                          fontSize: 12, fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  Text('Qty: $qty',
                                      style: GoogleFonts.poppins(
                                          fontSize: 11, color: AppTheme.textSecondary)),
                                ],
                              ),
                            ),
                            Text('EGP ${price * qty}',
                                style: GoogleFonts.poppins(
                                    fontSize: 13, fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary)),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 20),
                    _TotalRow(label: 'Subtotal', value: 'EGP ${subtotal.toInt()}'),
                    const SizedBox(height: 6),
                    _TotalRow(
                      label: 'Delivery Fee',
                      value: 'EGP ${widget.deliveryFee}',
                      valueStyle: GoogleFonts.poppins(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary),
                    ),
                    const Divider(height: 20),
                    _TotalRow(
                      label: 'Total',
                      value: 'EGP ${widget.total.toInt()}',
                      labelStyle: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                      valueStyle: GoogleFonts.poppins(
                          fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Confirm Button ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.check_circle_outline_rounded),
                  label: Text(_isLoading ? 'Placing Order...' : 'Confirm Order',
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
                  onPressed: _isLoading ? null : () => _confirmOrder(context),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType type = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary),
        prefixIcon: Icon(icon, color: AppTheme.primary),
      ),
    );
  }

  Future<void> _confirmOrder(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': uid,
        'customerName': _nameController.text.trim(),
        'customerPhone': _phoneController.text.trim(),
        'customerAddress': _addressController.text.trim(),
        'paymentMethod': _selectedPaymentMethod,
        'items': widget.items,
        'subtotal': widget.total - widget.deliveryFee,
        'deliveryFee': widget.deliveryFee,
        'total': widget.total,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('cart').doc(uid).update({
        'items': [],
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: 'Order Placed!',
        desc: 'Your order has been placed successfully. We will contact you shortly.',
        btnOkOnPress: () => Navigator.popUntil(context, (route) => route.isFirst),
        btnOkColor: AppTheme.primary,
      ).show();
    } catch (e) {
      debugPrint('Error confirming order: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to place order. Please try again.',
            style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(12),
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _PaymentOption({
    required this.label,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withValues(alpha: 0.06) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.primary.withValues(alpha: 0.4) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: selected ? AppTheme.primary : AppTheme.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? AppTheme.primary : AppTheme.textPrimary)),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: AppTheme.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const _TotalRow({required this.label, required this.value, this.labelStyle, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: labelStyle ??
                GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        Text(value,
            style: valueStyle ??
                GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
      ],
    );
  }
}
