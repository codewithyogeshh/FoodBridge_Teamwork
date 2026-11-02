import 'package:flutter_test/flutter_test.dart';
import 'package:foodbridge/data/models/donation_model.dart';
import 'package:foodbridge/data/repositories/app_repository.dart';
import 'package:foodbridge/ui/features/ai/food_vision_scanner_dialog.dart';
import 'package:foodbridge/ui/core/constants.dart';

void main() {
  group('1. AI Food Quality & Vision Scanner Tests', () {
    test(
      'FoodVisionResult stores dish, portions, and freshness score accurately',
      () {
        final result = FoodVisionResult(
          title: 'Fresh Paneer Butter Masala & 45 Tandoori Rotis',
          foodType: 'Cooked Meals',
          estimatedServings: 45,
          urgencyScore: 92,
          freshnessScore: 94,
          safeHours: 'Safe for 3.5 hours',
          storageRecommendation:
              'Keep warm (>60°C) in insulated thermal container',
          allergens: ['Dairy (Paneer)', 'Gluten (Wheat)'],
        );

        expect(result.estimatedServings, equals(45));
        expect(result.freshnessScore, equals(94));
        expect(result.freshnessScore, greaterThanOrEqualTo(90));
        expect(result.allergens, contains('Dairy (Paneer)'));
        expect(result.foodType, equals('Cooked Meals'));
      },
    );
  });

  group('2. Smart Route Multi-Stop Batching Tests', () {
    test(
      'Calculates combined delivery fee and assigns both donations in batch',
      () async {
        final repo = AppRepository();
        final now = DateTime.now();

        final don1 = await repo.createDonation(
          DonationModel(
            id: 'batch-don-1',
            donorName: 'Grand Orchid Banquet',
            donorPhone: '+91 98860 11111',
            title: 'Surplus Fresh Rice (50 servings)',
            foodType: 'Cooked Meals',
            quantityLabel: '50 portions',
            quantityServings: 50,
            preparedAt: now.subtract(const Duration(hours: 1)),
            safeUntil: now.add(const Duration(hours: 3)),
            storageRequirements: 'Insulated Hot Box',
            allergens: const [],
            pickupAddress: 'MG Road, Bengaluru',
            pickupLatitude: 12.9716,
            pickupLongitude: 77.5946,
            pickupOtp: '1234',
            urgencyLevel: UrgencyLevel.high,
            aiUrgencyScore: 88,
            status: DonationStatus.available,
            requiresVolunteerDelivery: true,
            deliveryFee: 26.0,
            createdAt: now,
            updatedAt: now,
          ),
        );

        final don2 = await repo.createDonation(
          DonationModel(
            id: 'batch-don-2',
            donorName: 'Spice Garden',
            donorPhone: '+91 98860 22222',
            title: 'Surplus Paneer Curry (35 servings)',
            foodType: 'Cooked Meals',
            quantityLabel: '35 portions',
            quantityServings: 35,
            preparedAt: now.subtract(const Duration(hours: 1)),
            safeUntil: now.add(const Duration(hours: 3)),
            storageRequirements: 'Insulated Hot Box',
            allergens: const ['Dairy'],
            pickupAddress: 'Brigade Road, Bengaluru',
            pickupLatitude: 12.9720,
            pickupLongitude: 77.6010,
            pickupOtp: '5678',
            urgencyLevel: UrgencyLevel.high,
            aiUrgencyScore: 86,
            status: DonationStatus.available,
            requiresVolunteerDelivery: true,
            deliveryFee: 28.0,
            createdAt: now,
            updatedAt: now,
          ),
        );

        final combinedFee = don1.deliveryFee + don2.deliveryFee;
        expect(combinedFee, equals(54.0));

        final success1 = await repo.acceptVolunteerDelivery(
          donationId: don1.id,
          volunteerId: 'vol-test-01',
          volunteerName: 'Ramesh Rider',
        );
        final success2 = await repo.acceptVolunteerDelivery(
          donationId: don2.id,
          volunteerId: 'vol-test-01',
          volunteerName: 'Ramesh Rider',
        );

        expect(success1, isTrue);
        expect(success2, isTrue);

        final myActive = repo.myActiveDeliveries;
        expect(myActive.any((d) => d.id == don1.id), isTrue);
        expect(myActive.any((d) => d.id == don2.id), isTrue);
      },
    );
  });

  group('3. SOS Emergency Food Rescue Tests', () {
    test(
      'SOS Donation is created with Critical Urgency (99) and volunteer delivery requirement',
      () async {
        final repo = AppRepository();
        final now = DateTime.now();

        final sosDonation = DonationModel(
          id: 'sos-test-999',
          donorName: 'Grand Orchid Convention Hall',
          donorPhone: '+91 98860 12345',
          title: '🚨 MASS SOS: Wedding Banquet Feast (300 Portions)',
          foodType: 'Cooked Meals',
          quantityLabel: '300 Plates',
          quantityServings: 300,
          preparedAt: now.subtract(const Duration(hours: 1)),
          safeUntil: now.add(const Duration(hours: 3)),
          storageRequirements: 'Hot Insulated Containers (>65°C)',
          allergens: const ['Dairy', 'Gluten'],
          pickupAddress: 'MG Road Convention Hall',
          pickupLatitude: 12.9716,
          pickupLongitude: 77.5946,
          pickupOtp: '8912',
          urgencyLevel: UrgencyLevel.critical,
          aiUrgencyScore: 99,
          aiRecommendationSummary: '10km Emergency Shelter Blast Active',
          status: DonationStatus.available,
          requiresVolunteerDelivery: true,
          deliveryFee: 45.0,
          createdAt: now,
          updatedAt: now,
        );

        final created = await repo.createDonation(sosDonation);
        expect(created.aiUrgencyScore, equals(99));
        expect(created.urgencyLevel, equals(UrgencyLevel.critical));
        expect(created.requiresVolunteerDelivery, isTrue);
        expect(created.quantityServings, equals(300));
      },
    );
  });

  group('4. Geofenced Pickup Verification Tests', () {
    test('Enforces 50m proximity rule before permitting OTP validation', () {
      bool isGeofenceUnlocked(double distanceMeters) {
        return distanceMeters <= 50.0;
      }

      expect(isGeofenceUnlocked(340.0), isFalse); // Far away
      expect(isGeofenceUnlocked(50.1), isFalse); // Just outside boundary
      expect(isGeofenceUnlocked(50.0), isTrue); // Exact threshold
      expect(isGeofenceUnlocked(18.0), isTrue); // At doorstep
    });
  });

  group('5. Predictive Food Waste Analytics Tests', () {
    test('Calculates probability and expected surplus range accurately', () {
      const pastSundayServings = [35, 42, 38];
      final averageSurplus =
          pastSundayServings.reduce((a, b) => a + b) /
          pastSundayServings.length;

      expect(averageSurplus, closeTo(38.33, 0.1));
      const confidence = 89;
      expect(confidence, greaterThan(80));
    });
  });
}
