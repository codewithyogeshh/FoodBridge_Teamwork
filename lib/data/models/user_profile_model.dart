import 'package:flutter/foundation.dart';
import '../../ui/core/constants.dart';

@immutable
class UserProfileModel {
  final String id;
  final String phone;
  final String fullName;
  final UserRole role;
  final String? email;
  final String? avatarUrl;
  final String? organizationName;
  final String? vehicleType;
  final DateTime createdAt;

  const UserProfileModel({
    required this.id,
    required this.phone,
    required this.fullName,
    required this.role,
    this.email,
    this.avatarUrl,
    this.organizationName,
    this.vehicleType,
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
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      organizationName: json['organization_name'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  bool get isDonor => role == UserRole.donor;
  bool get isVolunteer => role == UserRole.volunteer;
  bool get isNgo => role == UserRole.ngo;
  bool get isAdmin => role == UserRole.admin;
  bool get isCommunity => role == UserRole.community;

  UserProfileModel copyWith({
    String? id,
    String? phone,
    String? fullName,
    UserRole? role,
    String? email,
    String? avatarUrl,
    String? organizationName,
    String? vehicleType,
    DateTime? createdAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      organizationName: organizationName ?? this.organizationName,
      vehicleType: vehicleType ?? this.vehicleType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'full_name': fullName,
      'role': role.name,
      'email': email,
      'avatar_url': avatarUrl,
      'organization_name': organizationName,
      'vehicle_type': vehicleType,
    };
  }
}
