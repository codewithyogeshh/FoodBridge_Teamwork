import 'package:flutter/foundation.dart';
import '../../ui/core/constants.dart';

@immutable
class UserProfileModel {
  final String id;
  final String phone;
  final String fullName;
  final UserRole role;
  final String? avatarUrl;
  final String? organizationName;
  final DateTime createdAt;

  const UserProfileModel({
    required this.id,
    required this.phone,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    this.organizationName,
    required this.createdAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    UserRole role;
    switch ((json['role'] as String? ?? 'donor').toLowerCase()) {
      case 'ngo':
        role = UserRole.ngo;
        break;
      case 'admin':
        role = UserRole.admin;
        break;
      case 'community':
        role = UserRole.community;
        break;
      case 'volunteer':
        role = UserRole.volunteer;
        break;
      case 'donor':
      default:
        role = UserRole.donor;
    }

    return UserProfileModel(
      id: json['id'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      fullName: json['full_name'] as String? ?? 'User',
      role: role,
      avatarUrl: json['avatar_url'] as String?,
      organizationName: json['organization_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'full_name': fullName,
      'role': role.name,
      'avatar_url': avatarUrl,
      'organization_name': organizationName,
    };
  }
}
