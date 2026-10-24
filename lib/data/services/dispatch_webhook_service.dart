import 'package:flutter/foundation.dart';

class WhatsAppAlertMessage {
  final String id;
  final String recipientNgo;
  final String recipientPhone;
  final String donationTitle;
  final String donorName;
  final String location;
  final String safeUntilText;
  final int servings;
  final DateTime sentAt;
  bool isClaimed;

  WhatsAppAlertMessage({
    required this.id,
    required this.recipientNgo,
    required this.recipientPhone,
    required this.donationTitle,
    required this.donorName,
    required this.location,
    required this.safeUntilText,
    required this.servings,
    required this.sentAt,
    this.isClaimed = false,
  });

  String get formattedMessage =>
      '🚨 *FOODBRIDGE SURPLUS DISPATCH ALERT*\n\n'
      'Dear *$recipientNgo*,\n'
      'Surplus food posted *within 2.5 km* of your kitchen:\n\n'
      '🍲 *Item:* $donationTitle ($servings Servings)\n'
      '📍 *Pickup:* $location\n'
      '🏢 *Donor:* $donorName\n'
      '⏰ *Safe Until:* $safeUntilText\n\n'
      '🔒 *Atomic Lock:* Reply *CLAIM* or click link below to lock pickup before other shelters:\n'
      'https://foodbridge.ngo/claim/$id\n\n'
      '_Powered by FoodBridge 2.0 AI Perishability Dispatch_';
}

class DispatchWebhookService extends ChangeNotifier {
  static final DispatchWebhookService instance = DispatchWebhookService._internal();
  DispatchWebhookService._internal();

  final List<WhatsAppAlertMessage> _alerts = [
    WhatsAppAlertMessage(
      id: 'wa-101',
      recipientNgo: 'City Relief Mission & Shelter',
      recipientPhone: '+91 98450 44921',
      donationTitle: '60 Boxed Vegetarian Meals',
      donorName: 'Grand Orchid Banquet',
      location: 'MG Road, Central District',
      safeUntilText: 'In 2 hrs 15 mins (Urgent)',
      servings: 60,
      sentAt: DateTime.now().subtract(const Duration(minutes: 8)),
      isClaimed: true,
    ),
    WhatsAppAlertMessage(
      id: 'wa-102',
      recipientNgo: 'Annam Kitchen & Children Trust',
      recipientPhone: '+91 97110 88231',
      donationTitle: '45 Fresh Sandwiches & Fruit Bowls',
      donorName: 'Subway & Café Bistro',
      location: 'Tech Park Blvd, Tower 4',
      safeUntilText: 'In 3 hrs 30 mins',
      servings: 45,
      sentAt: DateTime.now().subtract(const Duration(minutes: 2)),
      isClaimed: false,
    ),
  ];

  List<WhatsAppAlertMessage> get alerts => List.unmodifiable(_alerts);

  void triggerSurplusAlert({
    required String donationTitle,
    required String donorName,
    required String location,
    required String safeUntilText,
    required int servings,
    String? ngoName,
  }) {
    final alert = WhatsAppAlertMessage(
      id: 'wa-${DateTime.now().millisecondsSinceEpoch}',
      recipientNgo: ngoName ?? 'Community Care Shelter',
      recipientPhone: '+91 98200 99412',
      donationTitle: donationTitle,
      donorName: donorName,
      location: location,
      safeUntilText: safeUntilText,
      servings: servings,
      sentAt: DateTime.now(),
    );
    _alerts.insert(0, alert);
    notifyListeners();
  }

  void claimAlert(String id) {
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index != -1) {
      _alerts[index].isClaimed = true;
      notifyListeners();
    }
  }
}
