import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/wizmi_dialog.dart';
import 'fuel_selection_screen.dart';

class OrderSummaryScreen extends StatefulWidget {
  const OrderSummaryScreen({super.key});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  final _addressCtrl = TextEditingController();
  bool _locating = false;

  final List<String> _paymentMethods = ['Cash', 'Vodafone Cash', 'Credit Card'];

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() => _locating = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        setState(() => _locating = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final addr = 'Lat: ${pos.latitude.toStringAsFixed(5)}, Lng: ${pos.longitude.toStringAsFixed(5)}';
      _addressCtrl.text = addr;
      if (mounted) {
        context.read<OrderProvider>().setAddress(addr, pos.latitude, pos.longitude);
      }
    } catch (_) {
      // Fallback: user types manually
    }
    setState(() => _locating = false);
  }

  Future<void> _confirmOrder() async {
    final provider = context.read<OrderProvider>();
    final auth = context.read<WizmiAuthProvider>();
    provider.setAddress(_addressCtrl.text.trim(), provider.lat, provider.lng);

    final error = await provider.placeOrder(auth.name, auth.phone);
    if (!mounted) return;

    if (error != null) {
      WizmiDialog.show(
        context,
        title: 'Order Failed',
        message: error,
        type: WizmiDialogType.error,
      );
    } else {
      provider.reset();
      WizmiDialog.show(
        context,
        title: 'Order Confirmed!',
        message: 'Your fuel is on the way. Track it in My Orders.',
        type: WizmiDialogType.success,
        onOk: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Order Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StepBar(step: 2),
                  const SizedBox(height: 28),
                  // Order summary card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Summary',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _summaryRow('Fuel Type', order.selectedFuel?.name ?? '-'),
                        _summaryRow('Grade', order.selectedFuel?.subtitle ?? '-'),
                        _summaryRow('Quantity', '${order.quantity} L'),
                        _summaryRow(
                          'Price per Liter',
                          '${order.selectedFuel?.pricePerLiter.toStringAsFixed(2) ?? '0.00'} EGP',
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${order.totalPrice.toStringAsFixed(2)} EGP',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Location
                  const Text(
                    'Delivery Location',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addressCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Enter your delivery address',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      suffixIcon: _locating
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.my_location, color: AppColors.primary),
                              onPressed: _detectLocation,
                              tooltip: 'Use my location',
                            ),
                    ),
                    onChanged: (v) => context
                        .read<OrderProvider>()
                        .setAddress(v, order.lat, order.lng),
                  ),
                  const SizedBox(height: 24),
                  // Payment
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._paymentMethods.map(
                    (m) => _PaymentOption(
                      method: m,
                      selected: order.paymentMethod == m,
                      onTap: () => order.setPayment(m),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: GradientButton(
              label: 'Confirm Order',
              icon: Icons.check_circle_outline,
              onPressed: _confirmOrder,
              loading: order.placing,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String method;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  IconData _icon() {
    switch (method) {
      case 'Vodafone Cash':
        return Icons.phone_android;
      case 'Credit Card':
        return Icons.credit_card;
      default:
        return Icons.payments_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(_icon(),
                color: selected ? AppColors.primary : AppColors.textSecondary, size: 22),
            const SizedBox(width: 12),
            Text(
              method,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
                color: selected ? AppColors.primary : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check, size: 12, color: Colors.black)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
