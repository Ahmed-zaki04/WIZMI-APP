import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Track Order'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          final order = WizmiOrder.fromFirestore(snapshot.data!);
          return _TrackingBody(order: order);
        },
      ),
    );
  }
}

class _TrackingBody extends StatelessWidget {
  final WizmiOrder order;
  const _TrackingBody({required this.order});

  static const _statuses = ['Confirmed', 'Assigned', 'En Route', 'Delivered'];

  int get _currentStep => _statuses.indexOf(order.status).clamp(0, 3);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _statusColor(order.status).withOpacity(0.15),
                  AppColors.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _statusColor(order.status).withOpacity(0.4)),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _statusColor(order.status).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _statusIcon(order.status),
                    color: _statusColor(order.status),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  order.status,
                  style: TextStyle(
                    color: _statusColor(order.status),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _statusSubtitle(order.status),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // Progress steps
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: List.generate(_statuses.length, (i) {
                final done = i <= _currentStep;
                final active = i == _currentStep;
                return _buildStep(
                  label: _statuses[i],
                  subtitle: _stepSubtitle(_statuses[i]),
                  done: done,
                  active: active,
                  isLast: i == _statuses.length - 1,
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          // Order info
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
                  'Order Details',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _detailRow(Icons.local_gas_station, 'Fuel', order.fuelType),
                _detailRow(Icons.water_drop_outlined, 'Quantity', '${order.quantity} L'),
                _detailRow(Icons.payments_outlined, 'Payment', order.paymentMethod),
                _detailRow(Icons.location_on_outlined, 'Address', order.address),
                _detailRow(
                  Icons.attach_money,
                  'Total',
                  '${order.totalPrice.toStringAsFixed(2)} EGP',
                ),
              ],
            ),
          ),
          if (order.driverName.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: AppColors.primary, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Driver',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      Text(
                        order.driverName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.phone, color: AppColors.primary),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStep({
    required String label,
    required String subtitle,
    required bool done,
    required bool active,
    required bool isLast,
  }) {
    final color = done ? AppColors.primary : AppColors.border;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: done ? AppColors.primary : AppColors.surface2,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 10,
                        )
                      ]
                    : [],
              ),
              child: done
                  ? const Icon(Icons.check, color: Colors.black, size: 14)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: done ? AppColors.primary.withOpacity(0.4) : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: done ? AppColors.textPrimary : AppColors.textMuted,
                    fontSize: 15,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: done ? AppColors.textSecondary : AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return AppColors.amber;
      case 'Assigned':
        return const Color(0xFF3498DB);
      case 'En Route':
        return AppColors.primary;
      case 'Delivered':
        return AppColors.success;
      case 'Cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Confirmed':
        return Icons.check_circle_outline;
      case 'Assigned':
        return Icons.person_outline;
      case 'En Route':
        return Icons.local_shipping_outlined;
      case 'Delivered':
        return Icons.done_all;
      case 'Cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  String _statusSubtitle(String status) {
    switch (status) {
      case 'Confirmed':
        return 'Your order has been received';
      case 'Assigned':
        return 'A driver has been assigned';
      case 'En Route':
        return 'Driver is on the way to you';
      case 'Delivered':
        return 'Fuel delivered successfully!';
      case 'Cancelled':
        return 'Order was cancelled';
      default:
        return '';
    }
  }

  String _stepSubtitle(String status) {
    switch (status) {
      case 'Confirmed':
        return 'Order received and being processed';
      case 'Assigned':
        return 'Driver assigned to your order';
      case 'En Route':
        return 'Driver heading to your location';
      case 'Delivered':
        return 'Fuel delivered to your vehicle';
      default:
        return '';
    }
  }
}
