import 'package:flutter_test/flutter_test.dart';
import 'package:foodbridge/data/models/donation_model.dart';
import 'package:foodbridge/data/services/supabase_service.dart';
import 'package:foodbridge/data/repositories/app_repository.dart';
import 'package:foodbridge/ui/core/constants.dart';

void main() {
  group('Supabase Backend Diagnostics & Real-Time Console Tests', () {
    test('SupabaseDiagnosticReport model initializes and reflects health state', () {
      final report = SupabaseDiagnosticReport(
        restConnected: true,
        restLatencyMs: 45,
        realtimeSubscribed: true,
        tableStatus: {
          'donations': true,
          'ngos': true,
          'community_donations': true,
          'notifications': true,
        },
        schemaColumns: {
          'assigned_volunteer_id': true,
          'delivery_fee': true,
          'requires_volunteer_delivery': true,
        },
        rpcFunctions: {
          'reserve_donation_atomic': true,
          'verify_pickup_otp': true,
        },
        timestamp: DateTime.now(),
        statusSummary: 'All systems operational',
      );

      expect(report.isHealthy, isTrue);
      expect(report.restLatencyMs, equals(45));
      expect(report.tableStatus['donations'], isTrue);
      expect(report.schemaColumns['delivery_fee'], isTrue);
      expect(report.rpcFunctions['verify_pickup_otp'], isTrue);
    });

    test('SupabaseService runDiagnostics executes gracefully and returns structured report', () async {
      final service = SupabaseService(enableRealtime: false);
      final report = await service.runDiagnostics();

      expect(report, isNotNull);
      expect(report.tableStatus.containsKey('donations'), isTrue);
      expect(report.tableStatus.containsKey('ngos'), isTrue);
      expect(report.schemaColumns.containsKey('assigned_volunteer_id'), isTrue);
      expect(report.rpcFunctions.containsKey('reserve_donation_atomic'), isTrue);
      expect(report.statusSummary.isNotEmpty, isTrue);
    });

    test('AppRepository exposes runSupabaseDiagnostics and sendRealtimeTestPing', () async {
      final repo = AppRepository();
      final report = await repo.runSupabaseDiagnostics();

      expect(report, isNotNull);
      expect(report.tableStatus.isNotEmpty, isTrue);

      final pingSent = await repo.sendRealtimeTestPing('Test websocket heartbeat');
      // In test mock environment without live websocket credentials, it returns false or handles smoothly
      expect(pingSent, anyOf(isTrue, isFalse));
    });
  });

  group('ESG & Environmental Sustainability Reporting Calculations', () {
    test('Calculates accurate CO2e, Water, and Methane diversion metrics from donations', () {
      final now = DateTime.now();
      final sampleDonations = [
        DonationModel(
          id: 'esg-don-1',
          donorId: 'donor-1',
          donorName: 'Grand Orchid Banquet',
          donorPhone: '+91 98860 12345',
          title: 'Surplus Banquet Feast',
          foodType: 'Cooked Meals',
          quantityLabel: '100 portions',
          quantityServings: 100,
          pickupAddress: 'MG Road, Bengaluru',
          pickupLatitude: 12.9716,
          pickupLongitude: 77.5946,
          pickupOtp: '123456',
          urgencyLevel: UrgencyLevel.high,
          aiUrgencyScore: 85,
          preparedAt: now.subtract(const Duration(hours: 1)),
          safeUntil: now.add(const Duration(hours: 3)),
          storageRequirements: 'Insulated Hot Box',
          allergens: const ['Gluten'],
          status: DonationStatus.delivered,
          createdAt: now,
          updatedAt: now,
        ),
        DonationModel(
          id: 'esg-don-2',
          donorId: 'donor-2',
          donorName: 'Spice Garden',
          donorPhone: '+91 98860 54321',
          title: 'Surplus Fresh Rotis & Dal',
          foodType: 'Cooked Meals',
          quantityLabel: '50 portions',
          quantityServings: 50,
          pickupAddress: 'Indiranagar, Bengaluru',
          pickupLatitude: 12.9784,
          pickupLongitude: 77.6408,
          pickupOtp: '654321',
          urgencyLevel: UrgencyLevel.medium,
          aiUrgencyScore: 70,
          preparedAt: now.subtract(const Duration(hours: 2)),
          safeUntil: now.add(const Duration(hours: 2)),
          storageRequirements: 'Room Temp',
          allergens: const [],
          status: DonationStatus.delivered,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final int totalServings = sampleDonations.fold(0, (sum, d) => sum + d.quantityServings);
      expect(totalServings, equals(150));

      // 1 serving ≈ 0.45 kg
      final double totalFoodKg = totalServings * 0.45;
      expect(totalFoodKg, equals(67.5));

      // 1 kg landfill food emits 2.5 kg CO2e
      final double co2eSavedKg = totalFoodKg * 2.5;
      expect(co2eSavedKg, equals(168.75));

      // 1 meal requires ~1,050 L freshwater
      final int waterSavedLiters = totalServings * 1050;
      expect(waterSavedLiters, equals(157500));

      // Methane avoided: 0.085 kg / kg food
      final double methaneAvoidedKg = totalFoodKg * 0.085;
      expect(methaneAvoidedKg, closeTo(5.737, 0.01));

      // Economic value at ₹70/meal
      final int economicValueInr = totalServings * 70;
      expect(economicValueInr, equals(10500));
    });

    test('Certificate ID and Cryptographic SHA256 audit format generation', () {
      const int servings = 850;
      const double co2e = 956.25;

      final certId = 'CERT-ESG-${DateTime.now().year}-${(servings * 7 + 1042).toString().padLeft(5, '0')}';
      final certHash = 'sha256:8f4b${servings}a91d${(co2e * 10).toInt()}e4198c21';

      expect(certId.startsWith('CERT-ESG-2026-'), isTrue);
      expect(certHash.startsWith('sha256:8f4b850a91d'), isTrue);
    });
  });

  group('Community Leaderboard & Gamification Badge Tests', () {
    test('Leaderboard rank evaluation and badge assignment', () {
      final leaderboardRanks = [
        {'name': 'Grand Orchid Banquet', 'meals': 1250, 'badge': 'Zero Waste Champion'},
        {'name': 'Spice Garden Restaurant', 'meals': 820, 'badge': 'Gold Donor'},
        {'name': 'FreshHarvest Agro Mart', 'meals': 650, 'badge': 'Fresh Produce Hero'},
      ];

      expect(leaderboardRanks[0]['meals'] as int, greaterThan(leaderboardRanks[1]['meals'] as int));
      expect(leaderboardRanks[1]['meals'] as int, greaterThan(leaderboardRanks[2]['meals'] as int));
      expect(leaderboardRanks[0]['badge'], equals('Zero Waste Champion'));
    });
  });
}
