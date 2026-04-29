import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _filter = 'All';
  final List<String> _filters = ['All', 'Confirmed', 'Assigned', 'En Route', 'Delivered', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.read<OrderProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.amber),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats row
          StreamBuilder<List<WizmiOrder>>(
            stream: orderProvider.allOrders(),
            builder: (_, snap) {
              final all = snap.data ?? [];
              final today = all.where((o) {
                final now = DateTime.now();
                return o.createdAt.year == now.year &&
                    o.createdAt.month == now.month &&
                    o.createdAt.day == now.day;
              }).toList();
              final revenue = today.fold<double>(
                0, (sum, o) => sum + o.totalPrice);
              return Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                color: AppColors.surface,
                child: Row(
                  children: [
                    _statCard('Total Orders', '${all.length}', AppColors.primary, Icons.receipt),
                    const SizedBox(width: 10),
                    _statCard('Today', '${today.length}', AppColors.amber, Icons.today),
                    const SizedBox(width: 10),
                    _statCard(
                      'Revenue',
                      '${revenue.toStringAsFixed(0)} EGP',
                      const Color(0xFF3498DB),
                      Icons.attach_money,
                    ),
                  ],
                ),
              );
            },
          ),
          // Filter bar
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filters.length,
              itemBuilder: (_, i) {
                final f = _filters[i];
                final active = _filter == f;
                return GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: active ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        color: active ? Colors.black : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Orders list
          Expanded(
            child: StreamBuilder<List<WizmiOrder>>(
              stream: orderProvider.allOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No orders yet',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                final filtered = _filter == 'All'
                    ? snapshot.data!
                    : snapshot.data!.where((o) => o.status == _filter).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No $_filter orders',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _AdminOrderCard(
                    order: filtered[i],
                    onStatusChange: (orderId, status, {driverName, driverPhone}) {
                      orderProvider.updateOrderStatus(
                        orderId,
                        status,
                        driverName: driverName ?? '',
                        driverPhone: driverPhone ?? '',
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final WizmiOrder order;
  final Function(String orderId, String status, {String? driverName, String? driverPhone}) onStatusChange;

  const _AdminOrderCard({required this.order, required this.onStatusChange});

  void _showStatusDialog(BuildContext context) {
    final driverNameCtrl = TextEditingController(text: order.driverName);
    final driverPhoneCtrl = TextEditingController(text: order.driverPhone);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Order Status',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: driverNameCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Driver name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: driverPhoneCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'Driver phone',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 16),
            ...WizmiOrder.statuses.where((s) => s != 'Cancelled').map(
              (s) => ListTile(
                leading: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _statusColor(s),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(s, style: const TextStyle(color: AppColors.textPrimary)),
                trailing: order.status == s
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  Navigator.pop(ctx);
                  onStatusChange(
                    order.id,
                    s,
                    driverName: driverNameCtrl.text,
                    driverPhone: driverPhoneCtrl.text,
                  );
                },
              ),
            ),
            ListTile(
              leading: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
              title: const Text('Cancel Order',
                  style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(ctx);
                onStatusChange(order.id, 'Cancelled');
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Confirmed': return AppColors.amber;
      case 'Assigned': return const Color(0xFF3498DB);
      case 'En Route': return AppColors.primary;
      case 'Delivered': return AppColors.success;
      case 'Cancelled': return AppColors.error;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showStatusDialog(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor(order.status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: _statusColor(order.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd/MM HH:mm').format(order.createdAt),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 16),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              order.userName.isNotEmpty ? order.userName : 'Customer',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            Text(
              order.userPhone,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _chip(Icons.local_gas_station, order.fuelType),
                const SizedBox(width: 8),
                _chip(Icons.water_drop_outlined, '${order.quantity}L'),
                const Spacer(),
                Text(
                  '${order.totalPrice.toStringAsFixed(0)} EGP',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.address,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 3),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}
