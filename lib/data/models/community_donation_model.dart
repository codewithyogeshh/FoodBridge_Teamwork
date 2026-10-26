import 'package:flutter/foundation.dart';

enum CommunityDonationCategory {
  clothes,
  books,
  monetary,
  essentials;

  String get label {
    switch (this) {
      case CommunityDonationCategory.clothes:
        return 'Clothes & Blankets';
      case CommunityDonationCategory.books:
        return 'Books & Stationery';
      case CommunityDonationCategory.monetary:
        return '80G Monetary Relief';
      case CommunityDonationCategory.essentials:
        return 'Dry Rations & Essentials';
    }
  }

  String get iconName {
    switch (this) {
      case CommunityDonationCategory.clothes:
        return 'checkroom';
      case CommunityDonationCategory.books:
        return 'menu_book';
      case CommunityDonationCategory.monetary:
        return 'account_balance_wallet';
      case CommunityDonationCategory.essentials:
        return 'inventory_2';
    }
  }
}

enum CommunityDonationStatus {
  submitted,
  matchedWithNGO,
  inTransit,
  distributed;

  String get label {
    switch (this) {
      case CommunityDonationStatus.submitted:
        return 'Donation Pledged';
      case CommunityDonationStatus.matchedWithNGO:
        return 'Matched to Shelter';
      case CommunityDonationStatus.inTransit:
        return 'Pickup in Progress';
      case CommunityDonationStatus.distributed:
        return 'Fulfilled & Distributed';
    }
  }
}

@immutable
class CommunityDonationModel {
  final String id;
  final CommunityDonationCategory category;
  final String title;
  final String description;
  final String quantityOrAmount;
  final String donorName;
  final String donorPhone;
  final bool isAnonymous;
  final String pickupAddress;
  final CommunityDonationStatus status;
  final String? assignedNgoName;
  final String? tax80GReceiptNumber;
  final String? paymentTransactionId;
  final String? conditionRating; // e.g. "Brand New", "Gently Used"
  final DateTime createdAt;

  const CommunityDonationModel({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.quantityOrAmount,
    required this.donorName,
    required this.donorPhone,
    this.isAnonymous = false,
    required this.pickupAddress,
    this.status = CommunityDonationStatus.submitted,
    this.assignedNgoName,
    this.tax80GReceiptNumber,
    this.paymentTransactionId,
    this.conditionRating,
    required this.createdAt,
  });

  String get displayDonorName =>
      isAnonymous ? 'Generous Community Well-Wisher' : donorName;

  String get displayDonorPhone =>
      isAnonymous ? 'Private & Encrypted' : donorPhone;

  bool get isFulfilled => status == CommunityDonationStatus.distributed;
  bool get has80GReceipt =>
      tax80GReceiptNumber != null && tax80GReceiptNumber!.isNotEmpty;

  CommunityDonationModel copyWith({
    String? id,
    CommunityDonationCategory? category,
    String? title,
    String? description,
    String? quantityOrAmount,
    String? donorName,
    String? donorPhone,
    bool? isAnonymous,
    String? pickupAddress,
    CommunityDonationStatus? status,
    String? assignedNgoName,
    String? tax80GReceiptNumber,
    String? paymentTransactionId,
    String? conditionRating,
    DateTime? createdAt,
  }) {
    return CommunityDonationModel(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      quantityOrAmount: quantityOrAmount ?? this.quantityOrAmount,
      donorName: donorName ?? this.donorName,
      donorPhone: donorPhone ?? this.donorPhone,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      status: status ?? this.status,
      assignedNgoName: assignedNgoName ?? this.assignedNgoName,
      tax80GReceiptNumber: tax80GReceiptNumber ?? this.tax80GReceiptNumber,
      paymentTransactionId: paymentTransactionId ?? this.paymentTransactionId,
      conditionRating: conditionRating ?? this.conditionRating,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory CommunityDonationModel.fromJson(Map<String, dynamic> json) {
    CommunityDonationCategory category;
    switch ((json['category'] as String? ?? 'clothes').toLowerCase()) {
      case 'books':
        category = CommunityDonationCategory.books;
        break;
      case 'monetary':
        category = CommunityDonationCategory.monetary;
        break;
      case 'essentials':
        category = CommunityDonationCategory.essentials;
        break;
      case 'clothes':
      default:
        category = CommunityDonationCategory.clothes;
    }

    CommunityDonationStatus status;
    switch ((json['status'] as String? ?? 'submitted').toLowerCase()) {
      case 'matchedwithngo':
        status = CommunityDonationStatus.matchedWithNGO;
        break;
      case 'intransit':
        status = CommunityDonationStatus.inTransit;
        break;
      case 'distributed':
        status = CommunityDonationStatus.distributed;
        break;
      case 'submitted':
      default:
        status = CommunityDonationStatus.submitted;
    }

    return CommunityDonationModel(
      id: json['id'] as String? ?? '',
      category: category,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      quantityOrAmount: json['quantity_or_amount'] as String? ?? '',
      donorName: json['donor_name'] as String? ?? '',
      donorPhone: json['donor_phone'] as String? ?? '',
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      pickupAddress: json['pickup_address'] as String? ?? '',
      status: status,
      assignedNgoName: json['assigned_ngo_name'] as String?,
      tax80GReceiptNumber: json['tax_80g_receipt_number'] as String?,
      paymentTransactionId:
          (json['payment_tx_id'] ?? json['payment_transaction_id']) as String?,
      conditionRating: json['condition_rating'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.name,
      'title': title,
      'description': description,
      'quantity_or_amount': quantityOrAmount,
      'donor_name': donorName,
      'donor_phone': donorPhone,
      'is_anonymous': isAnonymous,
      'pickup_address': pickupAddress,
      'status': status.name,
      'assigned_ngo_name': assignedNgoName,
      'tax_80g_receipt_number': tax80GReceiptNumber,
      'payment_tx_id': paymentTransactionId,
      'condition_rating': conditionRating,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
