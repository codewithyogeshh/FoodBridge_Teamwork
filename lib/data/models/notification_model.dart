import 'package:flutter/material.dart';
import '../../ui/core/constants.dart';
import '../../ui/core/theme.dart';

class NotificationModel {
  final String id;
  final String recipientRole; // 'ngo', 'admin', 'donor', 'all'
  final String? recipientId;
  final String title;
  final String message;
  final String type; // 'donation_created', 'donation_reserved', 'pickup_verified', 'delivered', 'emergency_alert', 'system'
  final String? entityType;
  final String? entityId;
  final Map<String, dynamic> metadata;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.recipientRole,
    this.recipientId,
    required this.title,
    required this.message,
    this.type = 'donation_created',
    this.entityType,
    this.entityId,
    Map<String, dynamic>? metadata,
    this.isRead = false,
    DateTime? createdAt,
  })  : metadata = metadata ?? const {},
        createdAt = createdAt ?? DateTime.now();

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      recipientRole: json['recipient_role']?.toString() ?? 'all',
      recipientId: json['recipient_id']?.toString(),
      title: json['title']?.toString() ?? 'FoodBridge Alert',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'donation_created',
      entityType: json['entity_type']?.toString(),
      entityId: json['entity_id']?.toString(),
      metadata: json['metadata'] is Map<String, dynamic>
          ? json['metadata'] as Map<String, dynamic>
          : (json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata'] as Map) : {}),
      isRead: json['is_read'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipient_role': recipientRole,
      'recipient_id': recipientId,
      'title': title,
      'message': message,
      'type': type,
      'entity_type': entityType,
      'entity_id': entityId,
      'metadata': metadata,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? recipientRole,
    String? recipientId,
    String? title,
    String? message,
    String? type,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? metadata,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipientRole: recipientRole ?? this.recipientRole,
      recipientId: recipientId ?? this.recipientId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isUrgent {
    final urgency = metadata['urgency_level']?.toString().toLowerCase();
    return urgency == 'critical' || type == 'emergency_alert';
  }

  UrgencyLevel get urgencyLevel {
    final level = metadata['urgency_level']?.toString().toUpperCase();
    if (level == 'CRITICAL') return UrgencyLevel.critical;
    if (level == 'HIGH') return UrgencyLevel.high;
    if (level == 'MEDIUM') return UrgencyLevel.medium;
    return UrgencyLevel.low;
  }

  IconData get iconData {
    switch (type) {
      case 'donation_created':
        return Icons.restaurant_rounded;
      case 'donation_reserved':
        return Icons.handshake_rounded;
      case 'pickup_verified':
        return Icons.verified_rounded;
      case 'delivered':
        return Icons.celebration_rounded;
      case 'emergency_alert':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color get accentColor {
    switch (type) {
      case 'donation_created':
        return isUrgent ? AppTheme.statusCritical : AppTheme.forestGreen;
      case 'donation_reserved':
        return AppTheme.statusHigh;
      case 'pickup_verified':
        return const Color(0xFF0077B6);
      case 'delivered':
        return const Color(0xFF10B981);
      case 'emergency_alert':
        return AppTheme.statusCritical;
      default:
        return AppTheme.forestGreen;
    }
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
