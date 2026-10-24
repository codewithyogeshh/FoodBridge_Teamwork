import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import 'supabase_service.dart';

/// Service dedicated to managing real-time notifications and their lifecycle
class NotificationService extends ChangeNotifier {
  final SupabaseService supabaseService;
  SupabaseService get _supabaseService => supabaseService;

  final List<NotificationModel> _notifications = [];
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  StreamSubscription<NotificationModel>? _streamSubscription;

  NotificationService({required this.supabaseService});

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Initializes or updates the notification stream for a specific role
  Future<void> init({String? role}) async {
    _streamSubscription?.cancel();
    _notifications.clear();

    // Fetch initial notifications
    final initialNotifs = await _supabaseService.getNotifications(role: role);
    _notifications.addAll(initialNotifs);
    _sortNotifications();
    notifyListeners();

    // Subscribe to real-time updates
    _streamSubscription = _supabaseService.notificationStream.listen((notif) {
      if (role == null ||
          notif.recipientRole == role ||
          notif.recipientRole == 'all') {
        _handleIncomingNotification(notif);
      }
    });

    _isInitialized = true;
  }

  void addLocalNotification(NotificationModel notif) {
    _handleIncomingNotification(notif);
  }

  void _handleIncomingNotification(NotificationModel notif) {
    // Avoid duplicates if already in list (e.g. from initial fetch or race conditions)
    if (!_notifications.any((n) => n.id == notif.id)) {
      _notifications.insert(0, notif);
      _sortNotifications();
      notifyListeners();

      // Hook for local push notifications could go here
      _showLocalNotification(notif);
    }
  }

  void _sortNotifications() {
    _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> markAsRead(String id) async {
    final success = await _supabaseService.markNotificationAsRead(id);
    if (success) {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    }
  }

  Future<void> markAllAsRead(String role) async {
    final success = await _supabaseService.markAllNotificationsAsRead(role);
    if (success) {
      for (int i = 0; i < _notifications.length; i++) {
        if (_notifications[i].recipientRole == role ||
            _notifications[i].recipientRole == 'all') {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }
      notifyListeners();
    }
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  void _showLocalNotification(NotificationModel notif) {
    // In a real app, we'd use flutter_local_notifications here
    // For this demo, we'll simulate the system-level alert
    debugPrint(
      '🚀 [SYSTEM] Local Push Notification: ${notif.title} - ${notif.message}',
    );

    // If the app is in background (simulated), this would trigger a tray notification
    if (kDebugMode) {
      print('🔔 PUSH ALERT: [${notif.type.toUpperCase()}] ${notif.title}');
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
