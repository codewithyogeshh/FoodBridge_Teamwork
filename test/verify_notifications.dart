// ignore_for_file: avoid_print
import 'package:foodbridge/data/models/notification_model.dart';
import 'package:foodbridge/data/services/notification_service.dart';
import 'package:foodbridge/data/services/supabase_service.dart';

void main() async {
  print('🧪 Starting Real-time Notification Verification...');

  final supabase = SupabaseService(enableRealtime: false); // Manual trigger
  final notificationService = NotificationService(supabaseService: supabase);

  notificationService.addListener(() {
    print('📈 Notification List Updated!');
    print('Count: ${notificationService.notifications.length}');
    if (notificationService.notifications.isNotEmpty) {
      final latest = notificationService.notifications.first;
      print('Latest: [${latest.type}] ${latest.title}');
      print('Unread: ${notificationService.unreadCount}');
    }
  });

  await notificationService.init(role: 'ngo');
  print('✅ NotificationService initialized for NGO role.');

  print('📡 Simulating incoming Real-time Notification...');
  final testNotif = NotificationModel(
    id: 'test-realtime-123',
    recipientRole: 'ngo',
    title: '🚨 URGENT: 50 Meals Available',
    message: 'Test Restaurant has surplus food ready for pickup.',
    type: 'donation_created',
    createdAt: DateTime.now(),
  );

  notificationService.addLocalNotification(testNotif);

  print('🏁 Verification script completed.');
}
