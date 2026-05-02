import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:wizmi/theme.dart';
import 'package:wizmi/widgets/common_widgets.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // ── Mark all as read ───────────────────────────────────────────────────────
  Future<void> _markAllRead(String uid) async {
    final snap = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();

    if (snap.docs.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // ── Date grouping helpers ──────────────────────────────────────────────────
  /// Returns a list of mixed items: String (header) or DocumentSnapshot.
  List<Object> _buildGroupedList(List<QueryDocumentSnapshot> docs) {
    final grouped = <String, List<QueryDocumentSnapshot>>{};
    final keyOrder = <String>[];

    for (final doc in docs) {
      final ts = (doc.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
      final date = ts?.toDate() ?? DateTime.now();
      final key = _dateKey(date);
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
        keyOrder.add(key);
      }
      grouped[key]!.add(doc);
    }

    final result = <Object>[];
    for (final key in keyOrder) {
      result.add(key);
      result.addAll(grouped[key]!);
    }
    return result;
  }

  String _dateKey(DateTime date) {
    final now = DateTime.now();
    final today    = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);

    if (d == today)     return 'Today';
    if (d == yesterday) return 'Yesterday';
    return DateFormat('MMM d').format(date);
  }

  // ── Timestamp label ────────────────────────────────────────────────────────
  String _formatTimestamp(DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.inDays > 7)     return '${ts.day}/${ts.month}/${ts.year}';
    if (diff.inDays > 0)     return '${diff.inDays}d ago';
    if (diff.inHours > 0)    return '${diff.inHours}h ago';
    if (diff.inMinutes > 0)  return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  // ── Status helpers ─────────────────────────────────────────────────────────
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'processing':
        return Colors.blue;
      case 'completed':
        return AppTheme.success;
      case 'rejected':
      case 'cancelled':
        return AppTheme.error;
      default:
        return AppTheme.primary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'processing':
        return Icons.check_circle;
      case 'completed':
        return Icons.done_all;
      case 'rejected':
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (currentUser != null)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark all as read',
              onPressed: () => _markAllRead(currentUser.uid),
            ),
        ],
      ),
      body: currentUser == null
          ? const Center(child: Text('Please login to view notifications'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('userId', isEqualTo: currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Sort newest first
                final notifications = snapshot.data!.docs
                  ..sort((a, b) {
                    final aTs = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                    final bTs = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                    if (aTs == null) return 1;
                    if (bTs == null) return -1;
                    return bTs.compareTo(aTs);
                  });

                if (notifications.isEmpty) {
                  return const WizmiEmptyState(
                    icon: Icons.notifications_none_outlined,
                    title: 'No notifications yet',
                    subtitle: 'You\'ll see updates about your bookings here.',
                  );
                }

                final items = _buildGroupedList(notifications);

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    // ── Date header ──────────────────────────────────────
                    if (item is String) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                        child: Text(
                          item,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      );
                    }

                    // ── Notification card ────────────────────────────────
                    final doc          = item as QueryDocumentSnapshot;
                    final data         = doc.data() as Map<String, dynamic>;
                    final ts           = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                    final isRead       = data['isRead'] as bool? ?? false;
                    final status       = data['status'] as String? ?? '';
                    final color        = _statusColor(status);

                    return Dismissible(
                      key: Key(doc.id),
                      background: Container(
                        color: AppTheme.error,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete_outline,
                            color: Colors.white, size: 26),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        FirebaseFirestore.instance
                            .collection('notifications')
                            .doc(doc.id)
                            .delete();
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isRead
                              ? Colors.white
                              : AppTheme.primary.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isRead
                                ? const Color(0xFFE5E7EB)
                                : AppTheme.primary.withValues(alpha: 0.15),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          leading: CircleAvatar(
                            backgroundColor: color.withValues(alpha: 0.15),
                            child: Icon(_statusIcon(status),
                                color: color, size: 20),
                          ),
                          title: Text(
                            data['title'] as String? ?? '',
                            style: GoogleFonts.poppins(
                              fontWeight: isRead
                                  ? FontWeight.w400
                                  : FontWeight.w600,
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 2),
                              Text(
                                data['message'] as String? ?? '',
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTimestamp(ts),
                                style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                          trailing: isRead
                              ? null
                              : Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                          onTap: () {
                            if (!isRead) {
                              FirebaseFirestore.instance
                                  .collection('notifications')
                                  .doc(doc.id)
                                  .update({'isRead': true});
                            }
                          },
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
