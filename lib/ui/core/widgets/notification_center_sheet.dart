import 'package:flutter/material.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/app_repository.dart';
import '../../core/theme.dart';

class NotificationCenterSheet extends StatefulWidget {
  final AppRepository repository;
  final Function(NotificationModel notif)? onNotificationTap;

  const NotificationCenterSheet({
    super.key,
    required this.repository,
    this.onNotificationTap,
  });

  static Future<void> show(
    BuildContext context, {
    required AppRepository repository,
    Function(NotificationModel notif)? onNotificationTap,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NotificationCenterSheet(
        repository: repository,
        onNotificationTap: onNotificationTap,
      ),
    );
  }

  @override
  State<NotificationCenterSheet> createState() =>
      _NotificationCenterSheetState();
}

class _NotificationCenterSheetState extends State<NotificationCenterSheet> {
  String _selectedFilter = 'all'; // 'all', 'unread', 'donations'

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repository,
      builder: (context, _) {
        final allNotifs = widget.repository.notifications;
        final unreadCount = widget.repository.unreadNotificationCount;

        List<NotificationModel> filtered = allNotifs;
        if (_selectedFilter == 'unread') {
          filtered = allNotifs.where((n) => !n.isRead).toList();
        } else if (_selectedFilter == 'donations') {
          filtered = allNotifs
              .where(
                (n) =>
                    n.type == 'donation_created' ||
                    n.type == 'donation_reserved',
              )
              .toList();
        }

        return Container(
          height: MediaQuery.of(context).size.height * 0.78,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),

              // Sheet Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.forestGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: AppTheme.forestGreen,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Live Alerts & Dispatch',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.richCharcoal,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            unreadCount > 0
                                ? '$unreadCount unread • Supabase Realtime active'
                                : 'All caught up • Connected to WebSocket',
                            style: TextStyle(
                              fontSize: 12,
                              color: unreadCount > 0
                                  ? AppTheme.forestGreen
                                  : AppTheme.charcoalMuted,
                              fontWeight: unreadCount > 0
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (unreadCount > 0)
                      TextButton(
                        onPressed: () {
                          widget.repository.markAllNotificationsRead();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text(
                          'Mark All Read',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.forestGreen,
                          ),
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildFilterChip('All', 'all', allNotifs.length),
                    const SizedBox(width: 8),
                    _buildFilterChip('Unread', 'unread', unreadCount),
                    const SizedBox(width: 8),
                    _buildFilterChip('Surplus Food', 'donations', null),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              const Divider(height: 1),

              // List of Notifications
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.mark_email_read_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No notifications found',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.richCharcoal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'When donors post surplus food, live alerts appear here instantly.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.charcoalMuted,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final notif = filtered[index];
                          return _buildNotificationCard(notif);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String value, int? count) {
    final isSelected = _selectedFilter == value;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = value),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.forestGreen : const Color(0xFFF1F5F2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.forestGreen : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.richCharcoal,
              ),
            ),
            if (count != null && count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : AppTheme.forestGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : AppTheme.forestGreen,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notif) {
    final isUnread = !notif.isRead;
    return InkWell(
      onTap: () {
        widget.repository.markNotificationRead(notif.id);
        if (widget.onNotificationTap != null) {
          Navigator.pop(context);
          widget.onNotificationTap!(notif);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFFF7FCF8) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread
                ? AppTheme.forestGreen.withValues(alpha: 0.35)
                : AppTheme.borderColor,
            width: isUnread ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Pill
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: notif.accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(notif.iconData, color: notif.accentColor, size: 20),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: isUnread
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: AppTheme.richCharcoal,
                          ),
                        ),
                      ),
                      if (isUnread) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.forestGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.message,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (notif.isUrgent) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.statusCritical.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '🔥 CRITICAL URGENCY',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.statusCritical,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        notif.timeAgo,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.charcoalMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (notif.type == 'donation_created')
                        const Row(
                          children: [
                            Text(
                              'View Details',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.forestGreen,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 14,
                              color: AppTheme.forestGreen,
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
