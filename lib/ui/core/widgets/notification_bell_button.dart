import 'package:flutter/material.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/app_repository.dart';
import '../../core/theme.dart';
import 'notification_center_sheet.dart';

class NotificationBellButton extends StatelessWidget {
  final AppRepository repository;
  final Function(NotificationModel notif)? onNotificationTap;
  final Color? iconColor;

  const NotificationBellButton({
    super.key,
    required this.repository,
    this.onNotificationTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repository.notificationService,
      builder: (context, _) {
        final unreadCount = repository.notificationService.unreadCount;
        final hasUnread = unreadCount > 0;

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(
                hasUnread
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_outlined,
                color: iconColor ?? AppTheme.richCharcoal,
                size: 22,
              ),
              tooltip: 'Live Alerts & Dispatch ($unreadCount unread)',
              onPressed: () {
                NotificationCenterSheet.show(
                  context,
                  repository: repository,
                  onNotificationTap: onNotificationTap,
                );
              },
            ),
            if (hasUnread)
              Positioned(
                top: 8,
                right: 8,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.all(3.5),
                    decoration: BoxDecoration(
                      color: AppTheme.statusCritical,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.statusCritical.withValues(alpha: 0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
