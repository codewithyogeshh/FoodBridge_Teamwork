import 'package:flutter/foundation.dart';
import '../../ui/core/constants.dart';

@immutable
class DonationModel {
  final String id;
  final String? donorId;
  final String donorName;
  final String donorPhone;
  final String title;
  final String foodType;
  final String quantityLabel;
  final int quantityServings;
  final DateTime preparedAt;
  final DateTime safeUntil;
  final String? storageRequirements;
  final List<String> allergens;
  final String pickupAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  final String? pickupInstructions;
  final String pickupOtp;
  final String? imageUrl;
  final UrgencyLevel urgencyLevel;
  final int aiUrgencyScore;
  final String? aiRecommendationSummary;
  final DonationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DonationModel({
    required this.id,
    this.donorId,
    required this.donorName,
    required this.donorPhone,
    required this.title,
    required this.foodType,
    required this.quantityLabel,
    required this.quantityServings,
    required this.preparedAt,
    required this.safeUntil,
    this.storageRequirements,
    required this.allergens,
    required this.pickupAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    this.pickupInstructions,
    required this.pickupOtp,
    this.imageUrl,
    required this.urgencyLevel,
    required this.aiUrgencyScore,
    this.aiRecommendationSummary,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Time remaining before food reaches safe consumption threshold
  Duration get timeRemaining => safeUntil.difference(DateTime.now());

  bool get isExpired => DateTime.now().isAfter(safeUntil);

  String get formattedTimeRemaining {
    final diff = timeRemaining;
    if (diff.isNegative) return 'Expired';
    if (diff.inHours > 0) {
      return '${diff.inHours}h ${diff.inMinutes.remainder(60)}m left';
    }
    return '${diff.inMinutes}m left';
  }

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      id: json['id'] as String? ?? '',
      donorId: json['donor_id'] as String?,
      donorName: json['donor_name'] as String? ?? 'Anonymous Donor',
      donorPhone: json['donor_phone'] as String? ?? '',
      title: json['title'] as String? ?? '',
      foodType: json['food_type'] as String? ?? 'Cooked Meals',
      quantityLabel: json['quantity_label'] as String? ?? '',
      quantityServings: (json['quantity_servings'] as num?)?.toInt() ?? 10,
      preparedAt: json['prepared_at'] != null
          ? DateTime.tryParse(json['prepared_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      safeUntil: json['safe_until'] != null
          ? DateTime.tryParse(json['safe_until'] as String) ??
              DateTime.now().add(const Duration(hours: 4))
          : DateTime.now().add(const Duration(hours: 4)),
      storageRequirements: json['storage_requirements'] as String?,
      allergens: json['allergens'] != null
          ? List<String>.from(json['allergens'] as List)
          : <String>[],
      pickupAddress: json['pickup_address'] as String? ?? '',
      pickupLatitude: (json['pickup_latitude'] as num?)?.toDouble() ?? 12.9716,
      pickupLongitude: (json['pickup_longitude'] as num?)?.toDouble() ?? 77.5946,
      pickupInstructions: json['pickup_instructions'] as String?,
      pickupOtp: json['pickup_otp'] as String? ?? '1234',
      imageUrl: json['image_url'] as String?,
      urgencyLevel: UrgencyLevel.fromString(json['urgency_level'] as String? ?? 'MEDIUM'),
      aiUrgencyScore: (json['ai_urgency_score'] as num?)?.toInt() ?? 70,
      aiRecommendationSummary: json['ai_recommendation_summary'] as String?,
      status: DonationStatus.fromString(json['status'] as String? ?? 'AVAILABLE'),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'donor_name': donorName,
      'donor_phone': donorPhone,
      'title': title,
      'food_type': foodType,
      'quantity_label': quantityLabel,
      'quantity_servings': quantityServings,
      'prepared_at': preparedAt.toIso8601String(),
      'safe_until': safeUntil.toIso8601String(),
      'storage_requirements': storageRequirements,
      'allergens': allergens,
      'pickup_address': pickupAddress,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'pickup_instructions': pickupInstructions,
      'pickup_otp': pickupOtp,
      'image_url': imageUrl,
      'urgency_level': urgencyLevel.dbValue,
      'ai_urgency_score': aiUrgencyScore,
      'ai_recommendation_summary': aiRecommendationSummary,
      'status': status.dbValue,
    };
  }

  DonationModel copyWith({
    String? id,
    String? donorId,
    String? donorName,
    String? donorPhone,
    String? title,
    String? foodType,
    String? quantityLabel,
    int? quantityServings,
    DateTime? preparedAt,
    DateTime? safeUntil,
    String? storageRequirements,
    List<String>? allergens,
    String? pickupAddress,
    double? pickupLatitude,
    double? pickupLongitude,
    String? pickupInstructions,
    String? pickupOtp,
    String? imageUrl,
    UrgencyLevel? urgencyLevel,
    int? aiUrgencyScore,
    String? aiRecommendationSummary,
    DonationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DonationModel(
      id: id ?? this.id,
      donorId: donorId ?? this.donorId,
      donorName: donorName ?? this.donorName,
      donorPhone: donorPhone ?? this.donorPhone,
      title: title ?? this.title,
      foodType: foodType ?? this.foodType,
      quantityLabel: quantityLabel ?? this.quantityLabel,
      quantityServings: quantityServings ?? this.quantityServings,
      preparedAt: preparedAt ?? this.preparedAt,
      safeUntil: safeUntil ?? this.safeUntil,
      storageRequirements: storageRequirements ?? this.storageRequirements,
      allergens: allergens ?? this.allergens,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      pickupInstructions: pickupInstructions ?? this.pickupInstructions,
      pickupOtp: pickupOtp ?? this.pickupOtp,
      imageUrl: imageUrl ?? this.imageUrl,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
      aiUrgencyScore: aiUrgencyScore ?? this.aiUrgencyScore,
      aiRecommendationSummary:
          aiRecommendationSummary ?? this.aiRecommendationSummary,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
