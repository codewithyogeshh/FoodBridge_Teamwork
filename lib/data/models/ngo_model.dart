import 'dart:math' as math;
import 'package:flutter/foundation.dart';

enum NGOVerificationStatus {
  pending,
  verified,
  rejected;

  String get dbValue {
    switch (this) {
      case NGOVerificationStatus.pending:
        return 'PENDING';
      case NGOVerificationStatus.verified:
        return 'VERIFIED';
      case NGOVerificationStatus.rejected:
        return 'REJECTED';
    }
  }

  static NGOVerificationStatus fromString(String val) {
    switch (val.toUpperCase()) {
      case 'VERIFIED':
        return NGOVerificationStatus.verified;
      case 'REJECTED':
        return NGOVerificationStatus.rejected;
      case 'PENDING':
      default:
        return NGOVerificationStatus.pending;
    }
  }
}

@immutable
class NGOModel {
  final String id;
  final String? profileId;
  final String organizationName;
  final String registrationNumber;
  final String contactPerson;
  final String phone;
  final String address;
  final double latitude;
  final double longitude;
  final NGOVerificationStatus verificationStatus;
  final String? verificationDocumentUrl;
  final int capacityMealsPerDay;
  final String? foodSafetyCertId;
  final String? govtIdType; // 'Aadhaar Card' or 'PAN Card'
  final String? govtIdNumber;
  final String? govtDocFileName;
  final String? fssaiDocFileName;
  final String? docFileSize;
  final String? docVerifiedHash;
  final bool hasOwnVolunteers;
  final DateTime createdAt;

  const NGOModel({
    required this.id,
    this.profileId,
    required this.organizationName,
    required this.registrationNumber,
    required this.contactPerson,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.verificationStatus,
    this.verificationDocumentUrl,
    required this.capacityMealsPerDay,
    this.foodSafetyCertId,
    this.govtIdType = 'Aadhaar Card',
    this.govtIdNumber = '5482 1928 8912',
    this.govtDocFileName = 'Aadhaar_Card_Verified_Scan.pdf',
    this.fssaiDocFileName = 'FSSAI_Certificate_Scan.pdf',
    this.docFileSize = '1.4 MB',
    this.docVerifiedHash = 'SHA256: 8F2A-94B1-C84E-Verified',
    this.hasOwnVolunteers = false,
    required this.createdAt,
  });

  bool get isVerified => verificationStatus == NGOVerificationStatus.verified;

  /// Calculate distance in Kilometers from a given coordinate using Haversine formula
  double distanceTo(double lat, double lng) {
    const double p = 0.017453292519943295; // Math.PI / 180
    final double a =
        0.5 -
        math.cos((lat - latitude) * p) / 2 +
        math.cos(latitude * p) *
            math.cos(lat * p) *
            (1 - math.cos((lng - longitude) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a)); // 2 * R; R = 6371 km
  }

  /// Calculate affordable nominal volunteer delivery fee (₹20 to ₹30) based on distance
  double calculateVolunteerDeliveryFee(double distanceKm) {
    if (hasOwnVolunteers) return 0.0;
    // Base ₹20 for <= 2.5 km, + ₹3/km — scales with distance (no cap)
    final fee = 20.0 + ((distanceKm - 2.5).clamp(0.0, double.infinity) * 3.0);
    return fee.roundToDouble();
  }

  factory NGOModel.fromJson(Map<String, dynamic> json) {
    return NGOModel(
      id: json['id'] as String? ?? '',
      profileId: json['profile_id'] as String?,
      organizationName: json['organization_name'] as String? ?? 'Verified NGO',
      registrationNumber:
          json['registration_number'] as String? ?? 'REG-PENDING',
      contactPerson: json['contact_person'] as String? ?? 'Coordinator',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 12.9716,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 77.5946,
      verificationStatus: NGOVerificationStatus.fromString(
        json['verification_status'] as String? ?? 'PENDING',
      ),
      verificationDocumentUrl: json['verification_document_url'] as String?,
      capacityMealsPerDay:
          (json['capacity_meals_per_day'] as num?)?.toInt() ?? 200,
      foodSafetyCertId: json['food_safety_cert_id'] as String?,
      govtIdType: json['govt_id_type'] as String? ?? 'Aadhaar Card',
      govtIdNumber: json['govt_id_number'] as String? ?? '5482 1928 8912',
      govtDocFileName:
          json['govt_doc_file_name'] as String? ??
          'Aadhaar_Card_Verified_Scan.pdf',
      fssaiDocFileName:
          json['fssai_doc_file_name'] as String? ??
          'FSSAI_Certificate_Scan.pdf',
      docFileSize: json['doc_file_size'] as String? ?? '1.4 MB',
      docVerifiedHash:
          json['doc_verified_hash'] as String? ??
          'SHA256: 8F2A-94B1-C84E-Verified',
      hasOwnVolunteers:
          json['has_own_volunteers'] == true ||
          json['hasOwnVolunteers'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organization_name': organizationName,
      'registration_number': registrationNumber,
      'contact_person': contactPerson,
      'phone': phone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'verification_status': verificationStatus.dbValue,
      'verification_document_url': verificationDocumentUrl,
      'capacity_meals_per_day': capacityMealsPerDay,
      'food_safety_cert_id': foodSafetyCertId,
      'govt_id_type': govtIdType,
      'govt_id_number': govtIdNumber,
      'govt_doc_file_name': govtDocFileName,
      'fssai_doc_file_name': fssaiDocFileName,
      'doc_file_size': docFileSize,
      'doc_verified_hash': docVerifiedHash,
      'has_own_volunteers': hasOwnVolunteers,
    };
  }

  NGOModel copyWith({
    String? id,
    String? profileId,
    String? organizationName,
    String? registrationNumber,
    String? contactPerson,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
    NGOVerificationStatus? verificationStatus,
    String? verificationDocumentUrl,
    int? capacityMealsPerDay,
    String? foodSafetyCertId,
    String? govtIdType,
    String? govtIdNumber,
    String? govtDocFileName,
    String? fssaiDocFileName,
    String? docFileSize,
    String? docVerifiedHash,
    bool? hasOwnVolunteers,
    DateTime? createdAt,
  }) {
    return NGOModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      organizationName: organizationName ?? this.organizationName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationDocumentUrl:
          verificationDocumentUrl ?? this.verificationDocumentUrl,
      capacityMealsPerDay: capacityMealsPerDay ?? this.capacityMealsPerDay,
      foodSafetyCertId: foodSafetyCertId ?? this.foodSafetyCertId,
      govtIdType: govtIdType ?? this.govtIdType,
      govtIdNumber: govtIdNumber ?? this.govtIdNumber,
      govtDocFileName: govtDocFileName ?? this.govtDocFileName,
      fssaiDocFileName: fssaiDocFileName ?? this.fssaiDocFileName,
      docFileSize: docFileSize ?? this.docFileSize,
      docVerifiedHash: docVerifiedHash ?? this.docVerifiedHash,
      hasOwnVolunteers: hasOwnVolunteers ?? this.hasOwnVolunteers,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
