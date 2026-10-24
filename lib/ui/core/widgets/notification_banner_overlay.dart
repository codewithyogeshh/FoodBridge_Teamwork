import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/app_repository.dart';
import '../../core/theme.dart';

class RealtimeNotificationOverlay extends StatefulWidget {
  final Widget child;
  final AppRepository repository;
  final Function(NotificationModel notif)? onActionTap;

  const RealtimeNotificationOverlay({
    super.key,
    required this.child,
    required this.repository,
    this.onActionTap,
  });

  @override
  State<RealtimeNotificationOverlay> createState() =>
      _RealtimeNotificationOverlayState();
}

class _RealtimeNotificationOverlayState
    extends State<RealtimeNotificationOverlay>
    with SingleTickerProviderStateMixin {
  StreamSubscription<NotificationModel>? _sub;
  NotificationModel? _activeNotification;
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animController,
            curve: Curves.easeOutBack,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    _sub = widget.repository.onNotificationStream.listen((notif) {
      final currentRoleStr = widget.repository.currentRole.name.toLowerCase();
      // Only show banner if the notification is targeted for current role or 'all'
      if (notif.recipientRole == currentRoleStr ||
          notif.recipientRole == 'all') {
        _triggerBanner(notif);
      }
    });
  }

  void _triggerBanner(NotificationModel notif) {
    _autoDismissTimer?.cancel();
    setState(() {
      _activeNotification = notif;
    });
    _animController.forward(from: 0.0);

    // Auto dismiss after 6.5 seconds
    _autoDismissTimer = Timer(const Duration(milliseconds: 6500), () {
      _dismissBanner();
    });
  }

  void _dismissBanner() {
    _autoDismissTimer?.cancel();
    _animController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _activeNotification = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _sub?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_activeNotification != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _activeNotification!.isUrgent
                              ? AppTheme.statusCritical.withValues(alpha: 0.5)
                              : AppTheme.forestGreen.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (_activeNotification!.isUrgent
                                        ? AppTheme.statusCritical
                                        : AppTheme.forestGreen)
                                    .withValues(alpha: 0.18),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          // Pulsing / Highlighted Icon
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _activeNotification!.accentColor
                                  .withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _activeNotification!.iconData,
                              color: _activeNotification!.accentColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Text Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _activeNotification!.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.richCharcoal,
                                        ),
                                      ),
                                    ),
                                    if (_activeNotification!.isUrgent) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.statusCritical,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Text(
                                          'URGENT',
                                          style: TextStyle(
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _activeNotification!.message,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.grey.shade700,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Action Button
                          if (widget.onActionTap != null)
                            ElevatedButton(
                              onPressed: () {
                                final notif = _activeNotification!;
                                _dismissBanner();
                                widget.onActionTap!(notif);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _activeNotification!.accentColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'View',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),

                          // Dismiss icon
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            color: Colors.grey.shade500,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: _dismissBanner,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
