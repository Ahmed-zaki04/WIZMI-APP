import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wizmi/theme.dart';
import 'package:wizmi/widgets/common_widgets.dart';

// ─── service-type metadata ────────────────────────────────────────────────────
class _ServiceMeta {
  final Color color;
  final IconData icon;
  final String label;
  const _ServiceMeta(this.color, this.icon, this.label);
}

const _serviceMeta = <String, _ServiceMeta>{
  'towing':     _ServiceMeta(Colors.orange,  Icons.local_shipping,    'Towing'),
  'mechanic':   _ServiceMeta(Colors.blue,    Icons.engineering,       'Mechanic'),
  'wash':       _ServiceMeta(Colors.cyan,    Icons.cleaning_services, 'Car Wash'),
  'rental':     _ServiceMeta(Colors.purple,  Icons.directions_car,    'Car Rental'),
  'diagnostic': _ServiceMeta(Colors.green,   Icons.speed,             'Diagnostics'),
};

const _filterLabels = ['All', 'Towing', 'Mechanic', 'Car Wash', 'Car Rental', 'Diagnostics'];
const _filterKeys   = ['all', 'towing', 'mechanic', 'wash', 'rental', 'diagnostic'];

// ─── page ─────────────────────────────────────────────────────────────────────
class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _allBookings = [];
  String _activeFilter = 'all';

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() => _loading = true);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }

    final db = FirebaseFirestore.instance;

    // Fetch all 5 collections in parallel
    final results = await Future.wait([
      db.collection('towing_requests')
          .where('userId', isEqualTo: uid)
          .get()
          .then((s) => s.docs.map((d) => {...d.data(), 'id': d.id, 'serviceType': 'towing'}).toList()),
      db.collection('mechanic_requests')
          .where('userId', isEqualTo: uid)
          .get()
          .then((s) => s.docs.map((d) => {...d.data(), 'id': d.id, 'serviceType': 'mechanic'}).toList()),
      db.collection('car_wash_requests')
          .where('userId', isEqualTo: uid)
          .get()
          .then((s) => s.docs.map((d) => {...d.data(), 'id': d.id, 'serviceType': 'wash'}).toList()),
      db.collection('car_rental_requests')
          .where('userId', isEqualTo: uid)
          .get()
          .then((s) => s.docs.map((d) => {...d.data(), 'id': d.id, 'serviceType': 'rental'}).toList()),
      db.collection('diagnostic_requests')
          .where('userId', isEqualTo: uid)
          .get()
          .then((s) => s.docs.map((d) => {...d.data(), 'id': d.id, 'serviceType': 'diagnostic'}).toList()),
    ]);

    final merged = results.expand((list) => list).toList();

    // Sort by timestamp descending (newest first)
    merged.sort((a, b) {
      final ta = _toDateTime(a['timestamp']);
      final tb = _toDateTime(b['timestamp']);
      if (ta == null && tb == null) return 0;
      if (ta == null) return 1;
      if (tb == null) return -1;
      return tb.compareTo(ta);
    });

    if (mounted) {
      setState(() {
        _allBookings = merged;
        _loading = false;
      });
    }
  }

  DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  List<Map<String, dynamic>> get _filtered {
    if (_activeFilter == 'all') return _allBookings;
    return _allBookings.where((b) => b['serviceType'] == _activeFilter).toList();
  }

  String _formatDate(dynamic value) {
    final dt = _toDateTime(value);
    if (dt == null) return 'Unknown date';
    return DateFormat('MMM d, yyyy').format(dt);
  }

  String _detailField(Map<String, dynamic> booking) {
    final type = booking['serviceType'] as String? ?? '';
    switch (type) {
      case 'towing':
      case 'mechanic':
      case 'diagnostic':
        return booking['carModel'] as String? ?? '';
      case 'wash':
        return booking['package'] as String? ?? '';
      case 'rental':
        return booking['carType'] as String? ?? '';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'My Bookings',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchBookings,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _loading
                ? _buildShimmer()
                : _filtered.isEmpty
                    ? WizmiEmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'No bookings yet',
                        subtitle: _activeFilter == 'all'
                            ? 'Your service requests will appear here.'
                            : 'No ${_filterLabels[_filterKeys.indexOf(_activeFilter)]} bookings found.',
                        buttonLabel: 'Explore Services',
                        onButton: () => Navigator.pushReplacementNamed(context, 'home'),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchBookings,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) => _BookingCard(
                            booking: _filtered[i],
                            detail: _detailField(_filtered[i]),
                            dateStr: _formatDate(_filtered[i]['timestamp']),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_filterLabels.length, (i) {
            final key = _filterKeys[i];
            final selected = _activeFilter == key;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  _filterLabels[i],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    color: selected ? AppTheme.primary : AppTheme.textSecondary,
                  ),
                ),
                selected: selected,
                onSelected: (_) => setState(() => _activeFilter = key),
                selectedColor: AppTheme.primary.withValues(alpha: 0.12),
                checkmarkColor: AppTheme.primary,
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: selected
                      ? AppTheme.primary.withValues(alpha: 0.4)
                      : const Color(0xFFE5E7EB),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                showCheckmark: false,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => Container(
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

// ─── booking card ─────────────────────────────────────────────────────────────
class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final String detail;
  final String dateStr;

  const _BookingCard({
    required this.booking,
    required this.detail,
    required this.dateStr,
  });

  @override
  Widget build(BuildContext context) {
    final type = booking['serviceType'] as String? ?? 'towing';
    final meta = _serviceMeta[type] ?? _serviceMeta['towing']!;
    final status = booking['status'] as String? ?? 'pending';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: meta.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(meta.icon, color: meta.color, size: 24),
          ),
          const SizedBox(width: 14),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      meta.label,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    StatusBadge(status: status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (detail.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
