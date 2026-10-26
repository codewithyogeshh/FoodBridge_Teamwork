import 'package:flutter_test/flutter_test.dart';
import 'package:foodbridge/data/models/donation_model.dart';
import 'package:foodbridge/data/models/ngo_model.dart';
import 'package:foodbridge/data/services/ai_allocation_service.dart';
import 'package:foodbridge/data/models/ai_recommendation_model.dart';
import 'package:foodbridge/ui/core/constants.dart';
import 'package:foodbridge/data/models/community_donation_model.dart';
import 'package:foodbridge/data/models/user_profile_model.dart';
import 'package:foodbridge/data/models/notification_model.dart';
import 'package:foodbridge/data/services/supabase_service.dart';
import 'package:foodbridge/data/repositories/app_repository.dart';
import 'package:foodbridge/data/services/offline_sync_service.dart';
import 'package:foodbridge/data/services/localization_service.dart';

void main() {
  group('AIAllocationService Tests', () {
    final aiService = AIAllocationService();

    test(
      'Computes critical urgency for cooked meals with <= 180 min remaining',
      () {
        final now = DateTime.now();
        final urgency = aiService.computePerishabilityUrgency(
          foodType: 'Cooked Meals',
          preparedAt: now.subtract(const Duration(hours: 1)),
          safeUntil: now.add(const Duration(hours: 2)), // 120 min left
        );
        expect(urgency, UrgencyLevel.critical);
      },
    );

    test('Computes low urgency for bakery items with 2 days remaining', () {
      final now = DateTime.now();
      final urgency = aiService.computePerishabilityUrgency(
        foodType: 'Bakery & Grains',
        preparedAt: now.subtract(const Duration(hours: 2)),
        safeUntil: now.add(const Duration(hours: 48)),
      );
      expect(urgency, UrgencyLevel.low);
    });

    test(
      'Produces AI allocation recommendations with transparent explanations and safety disclaimer',
      () {
        final now = DateTime.now();
        final donation = DonationModel(
          id: 'test-don-001',
          donorId: 'donor-1',
          donorName: 'Grand Hyatt Catering',
          donorPhone: '+1 555-0199',
          title: '50 Hot Gourmet Meals',
          foodType: 'Cooked Meals',
          quantityLabel: '50 boxes',
          quantityServings: 50,
          pickupAddress: '333 O\'Farrell St, San Francisco, CA',
          pickupLatitude: 37.7858,
          pickupLongitude: -122.4089,
          pickupOtp: '849201',
          urgencyLevel: UrgencyLevel.critical,
          aiUrgencyScore: 92,
          preparedAt: now.subtract(const Duration(hours: 1)),
          safeUntil: now.add(const Duration(hours: 2, minutes: 30)),
          storageRequirements: 'Warm (Above 60°C)',
          allergens: const ['Dairy', 'Gluten'],
          status: DonationStatus.available,
          createdAt: now,
          updatedAt: now,
        );

        final ngos = [
          NGOModel(
            id: 'ngo-1',
            organizationName: 'City Relief Mission',
            registrationNumber: 'REG-001',
            contactPerson: 'Director Sarah',
            phone: '+1 555-0100',
            address: '450 Mission St',
            latitude: 37.7812,
            longitude: -122.4098,
            capacityMealsPerDay: 500,
            verificationStatus: NGOVerificationStatus.verified,
            createdAt: now,
          ),
          NGOModel(
            id: 'ngo-2',
            organizationName: 'Community Youth Pantry',
            registrationNumber: 'REG-002',
            contactPerson: 'David Chen',
            phone: '+1 555-0200',
            address: '890 Folsom St',
            latitude: 37.7650,
            longitude: -122.4300,
            capacityMealsPerDay: 200,
            verificationStatus: NGOVerificationStatus.verified,
            createdAt: now,
          ),
        ];

        final analysis = aiService.analyzeDonationAllocation(
          donation: donation,
          availableNGOs: ngos,
        );

        expect(analysis.matches.isNotEmpty, true);
        expect(
          analysis.matches.first.ngo.organizationName,
          'City Relief Mission',
        );
        expect(analysis.matches.first.matchReasons.isNotEmpty, true);

        // AI Safety Guardrail rule check:
        expect(
          AIAllocationAnalysis.safetyNotice.contains(
            'cannot physically inspect or certify microbiological food safety',
          ),
          true,
        );
        expect(
          AIAllocationAnalysis.safetyNotice.contains(
            'visually and thermally verify food freshness',
          ),
          true,
        );
      },
    );
  });

  group('Model Calculations & Serialization', () {
    test('NGOModel calculates Haversine distance accurately', () {
      final now = DateTime.now();
      final ngo = NGOModel(
        id: 'ngo-test',
        organizationName: 'Test Center',
        registrationNumber: 'REG-999',
        contactPerson: 'John Doe',
        phone: '1234567890',
        address: '123 Test St',
        latitude: 37.7749,
        longitude: -122.4194,
        capacityMealsPerDay: 300,
        verificationStatus: NGOVerificationStatus.verified,
        createdAt: now,
      );

      // Same location distance should be 0.0 km
      final distSelf = ngo.distanceTo(37.7749, -122.4194);
      expect(distSelf, 0.0);

      // Small offset should be positive distance
      final distNearby = ngo.distanceTo(37.7849, -122.4094);
      expect(distNearby > 0.5 && distNearby < 3.0, true);
    });

    test('DonationModel parses from JSON correctly', () {
      final now = DateTime.now();
      final json = {
        'id': 'don-99',
        'donor_id': 'donor-xyz',
        'donor_name': 'Green Market',
        'donor_phone': '+1 555-8822',
        'title': 'Fresh Organic Vegetables',
        'food_type': 'Produce',
        'quantity_label': '20 kg',
        'quantity_servings': 40,
        'pickup_address': 'Market Street 100',
        'pickup_latitude': 37.77,
        'pickup_longitude': -122.41,
        'prepared_at': now.toIso8601String(),
        'safe_until': now.add(const Duration(days: 2)).toIso8601String(),
        'storage_requirements': 'Cool ambient (15-20°C)',
        'allergens': ['None'],
        'status': 'AVAILABLE',
        'pickup_otp': '789123',
        'urgency_level': 'LOW',
        'ai_urgency_score': 30,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final donation = DonationModel.fromJson(json);
      expect(donation.id, 'don-99');
      expect(donation.foodType, 'Produce');
      expect(donation.status, DonationStatus.available);
      expect(donation.pickupOtp, '789123');
    });

    test('UserProfileModel parses community role properly', () {
      final json = {
        'id': 'usr-comm-1',
        'email': 'giver@example.org',
        'full_name': 'Aarav Patel',
        'role': 'community',
        'created_at': DateTime.now().toIso8601String(),
      };
      final profile = UserProfileModel.fromJson(json);
      expect(profile.role, UserRole.community);
      expect(profile.fullName, 'Aarav Patel');
    });
  });

  group('Community Donations & User Privacy Tests', () {
    test(
      'Anonymous mode conceals donor identity and phone on public feeds',
      () {
        final now = DateTime.now();
        final anonDonation = CommunityDonationModel(
          id: 'cd-anon-01',
          category: CommunityDonationCategory.clothes,
          title: 'Warm Sweaters and Wool Blankets (10 pcs)',
          description: 'Clean sanitized winter wear',
          quantityOrAmount: '10 Items',
          donorName: 'Dr. Priya Mehta',
          donorPhone: '+91 98200 12345',
          isAnonymous: true,
          pickupAddress: '42 Marine Drive, Mumbai',
          status: CommunityDonationStatus.submitted,
          createdAt: now,
        );

        // Verify privacy masking
        expect(anonDonation.displayDonorName, 'Generous Community Well-Wisher');
        expect(anonDonation.displayDonorPhone, 'Private & Encrypted');

        final publicDonation = anonDonation.copyWith(isAnonymous: false);
        expect(publicDonation.displayDonorName, 'Dr. Priya Mehta');
        expect(publicDonation.displayDonorPhone, '+91 98200 12345');
      },
    );

    test(
      'CommunityDonationModel serializes and deserializes monetary and physical categories',
      () {
        final now = DateTime.now();
        final donation = CommunityDonationModel(
          id: 'cd-mon-02',
          category: CommunityDonationCategory.monetary,
          title: 'Sponsorship for 50 Shelter Meals',
          description: 'Hot nutritious meal preparation funds',
          quantityOrAmount: '₹1000',
          donorName: 'Rahul Verma',
          donorPhone: '+91 98111 22334',
          isAnonymous: false,
          pickupAddress: 'Online Contribution (UPI)',
          status: CommunityDonationStatus.distributed,
          assignedNgoName: 'Annam Kitchen Trust',
          tax80GReceiptNumber: '80G-FB-2026-44910',
          paymentTransactionId: 'TXN-UPI-994821',
          createdAt: now,
        );

        final map = donation.toJson();
        expect(map['category'], 'monetary');
        expect(map['tax_80g_receipt_number'], '80G-FB-2026-44910');
        expect(map['payment_tx_id'], 'TXN-UPI-994821');

        final parsed = CommunityDonationModel.fromJson(map);
        expect(parsed.id, 'cd-mon-02');
        expect(parsed.category, CommunityDonationCategory.monetary);
        expect(parsed.status, CommunityDonationStatus.distributed);
        expect(parsed.tax80GReceiptNumber, '80G-FB-2026-44910');
      },
    );

    test(
      'AppRepository creates and persists community donation correctly',
      () async {
        final repository = AppRepository();
        final initialCount = repository.communityDonations.length;

        final newDonation = CommunityDonationModel(
          id: 'cd-test-01',
          category: CommunityDonationCategory.books,
          title: 'Class 10 Science & Math Textbooks',
          description: 'Complete syllabus with solved guides',
          quantityOrAmount: '12 Books',
          donorName: 'Kavita Sen',
          donorPhone: '+91 97111 88990',
          isAnonymous: true,
          pickupAddress: 'Sector 14, Gurugram',
          createdAt: DateTime.now(),
        );

        final created = await repository.createCommunityDonation(newDonation);
        expect(created.id, 'cd-test-01');
        expect(repository.communityDonations.length, initialCount + 1);
        expect(
          repository.communityDonations.first.title,
          'Class 10 Science & Math Textbooks',
        );
      },
    );
  });

  group('Supabase Real-Time Notifications & Dispatch Tests', () {
    test(
      'NotificationModel serializes and parses properly with urgency metadata',
      () {
        final notif = NotificationModel(
          id: 'notif-t-1',
          recipientRole: 'ngo',
          title: '🚨 New Surplus Food Alert: 100 Hot Meals',
          message: 'Grand Banquet posted 100 meals near MG Road',
          type: 'donation_created',
          entityId: 'don-100',
          metadata: {
            'donation_id': 'don-100',
            'urgency_level': 'CRITICAL',
            'quantity_servings': 100,
          },
          isRead: false,
        );

        expect(notif.isUrgent, isTrue);
        expect(notif.urgencyLevel, UrgencyLevel.critical);

        final json = notif.toJson();
        expect(json['recipient_role'], 'ngo');
        expect(json['type'], 'donation_created');

        final restored = NotificationModel.fromJson(json);
        expect(restored.id, 'notif-t-1');
        expect(restored.title, '🚨 New Surplus Food Alert: 100 Hot Meals');
        expect(restored.isUrgent, isTrue);
        expect(restored.isRead, isFalse);
      },
    );

    test(
      'Creating a donation automatically creates instant notifications for NGO and Admin',
      () async {
        final supabaseService = SupabaseService(enableRealtime: false);
        final repository = AppRepository(supabaseService: supabaseService);

        final now = DateTime.now();
        final newDonation = DonationModel(
          id: 'test-realtime-don-1',
          donorId: 'd-1',
          donorName: 'Spice Garden Restaurant',
          donorPhone: '+91 98860 99999',
          title: 'Surplus Fresh Biryani & Raita (80 portions)',
          foodType: 'Cooked Meals',
          quantityLabel: '80 Portions',
          quantityServings: 80,
          preparedAt: now.subtract(const Duration(minutes: 30)),
          safeUntil: now.add(const Duration(hours: 3)),
          storageRequirements: 'Insulated warmer',
          allergens: const ['Dairy'],
          pickupAddress: 'Koramangala 5th Block, Bengaluru',
          pickupLatitude: 12.9350,
          pickupLongitude: 77.6200,
          pickupInstructions: 'Kitchen rear entrance',
          pickupOtp: '7412',
          urgencyLevel: UrgencyLevel.critical,
          aiUrgencyScore: 95,
          status: DonationStatus.available,
          createdAt: now,
          updatedAt: now,
        );

        final created = await repository.createDonation(newDonation);
        expect(created.title, 'Surplus Fresh Biryani & Raita (80 portions)');

        // Allow realtime stream event to deliver
        await Future.delayed(const Duration(milliseconds: 50));

        // Verify instant notification generated for NGO
        repository.setRole(UserRole.ngo);
        final hasNgoNotif = repository.notifications.any(
          (n) =>
              n.recipientRole == 'ngo' &&
              n.title.contains('Surplus Fresh Biryani'),
        );
        expect(hasNgoNotif, isTrue);
        expect(repository.unreadNotificationCount, greaterThan(0));

        // Verify instant notification generated for Admin
        repository.setRole(UserRole.admin);
        final hasAdminNotif = repository.notifications.any(
          (n) =>
              n.recipientRole == 'admin' &&
              n.title.contains('Surplus Fresh Biryani'),
        );
        expect(hasAdminNotif, isTrue);
        expect(repository.unreadNotificationCount, greaterThan(0));

        // Verify mark read functionality
        repository.setRole(UserRole.ngo);
        final firstUnread = repository.notifications.firstWhere(
          (n) => !n.isRead,
        );
        await repository.markNotificationRead(firstUnread.id);
        expect(
          repository.notifications
              .firstWhere((n) => n.id == firstUnread.id)
              .isRead,
          isTrue,
        );

        repository.dispose();
      },
    );
  });

  group('Volunteer Role & Delivery Logistics Tests', () {
    test(
      'NGOModel calculates affordable delivery fee (₹20-₹30) based on distance',
      () {
        final now = DateTime.now();
        final ngoWithFleet = NGOModel(
          id: 'ngo-fleet-1',
          organizationName: 'Fleet NGO',
          registrationNumber: 'REG-1',
          contactPerson: 'Leader',
          phone: '+91 9999999999',
          address: 'MG Road',
          latitude: 12.9716,
          longitude: 77.5946,
          verificationStatus: NGOVerificationStatus.verified,
          capacityMealsPerDay: 300,
          hasOwnVolunteers: true,
          createdAt: now,
        );

        final ngoWithoutFleet = NGOModel(
          id: 'ngo-nofleet-2',
          organizationName: 'Shelter NGO',
          registrationNumber: 'REG-2',
          contactPerson: 'Coordinator',
          phone: '+91 8888888888',
          address: 'Koramangala',
          latitude: 12.9716,
          longitude: 77.5946,
          verificationStatus: NGOVerificationStatus.verified,
          capacityMealsPerDay: 150,
          hasOwnVolunteers: false,
          createdAt: now,
        );

        // If NGO has own fleet, fee is 0
        expect(ngoWithFleet.calculateVolunteerDeliveryFee(3.0), equals(0.0));

        // If NGO lacks fleet, fee is distance-based: ₹20 base for <= 2.5 km, + ₹3/km
        final shortDistFee = ngoWithoutFleet.calculateVolunteerDeliveryFee(1.5);
        expect(shortDistFee, equals(20.0));

        final midDistFee = ngoWithoutFleet.calculateVolunteerDeliveryFee(4.0);
        // 20 + (4.0 - 2.5) * 3 = 24.5 -> rounds to 25
        expect(midDistFee, equals(25.0));

        final longDistFee = ngoWithoutFleet.calculateVolunteerDeliveryFee(15.0);
        // 20 + (15.0 - 2.5) * 3 = 57.5 -> rounds to 58 (no cap)
        expect(longDistFee, equals(58.0));
        expect(longDistFee, greaterThan(30.0));
      },
    );

    test('UserProfileModel correctly parses UserRole.volunteer', () {
      final profile = UserProfileModel.fromJson({
        'id': 'vol-001',
        'phone': '+91 9988776655',
        'full_name': 'Ramesh Rider',
        'role': 'volunteer',
      });
      expect(profile.role, equals(UserRole.volunteer));
      expect(profile.toJson()['role'], equals('volunteer'));
    });

    test(
      'Volunteer workflow: accept, pickup, and complete delivery with fee',
      () async {
        final repository = AppRepository();
        repository.setRole(UserRole.volunteer);

        expect(repository.currentRole, equals(UserRole.volunteer));

        // Create a test donation requiring volunteer delivery
        final donation = await repository.createDonation(
          DonationModel(
            id: 'test-vol-don-001',
            donorName: 'Biryani Express',
            donorPhone: '+91 9876543210',
            title: '30 Hot Meal Boxes',
            foodType: 'Cooked Meals',
            quantityLabel: '30 Boxes',
            quantityServings: 30,
            preparedAt: DateTime.now().subtract(const Duration(minutes: 30)),
            safeUntil: DateTime.now().add(const Duration(hours: 3)),
            storageRequirements: 'Keep warm',
            allergens: const ['Dairy'],
            pickupAddress: 'Brigade Road, Bengaluru',
            pickupLatitude: 12.9716,
            pickupLongitude: 77.5946,
            pickupOtp: '1234',
            urgencyLevel: UrgencyLevel.high,
            aiUrgencyScore: 85,
            status: DonationStatus.available,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        // Reserve with volunteer delivery requested
        await repository.reserveDonation(
          donationId: donation.id,
          ngoId: 'test-ngo-id',
          ngoName: 'Seva Orphanage',
          requiresVolunteerDelivery: true,
          deliveryFee: 26.0,
        );

        // Verify it appears in available volunteer deliveries
        final available = repository.availableVolunteerDeliveries;
        expect(available.any((d) => d.id == donation.id), isTrue);

        // Volunteer accepts delivery
        final accepted = await repository.acceptVolunteerDelivery(
          donationId: donation.id,
          volunteerId: 'vol-user-1',
          volunteerName: 'Ramesh Rider',
        );
        expect(accepted, isTrue);

        // Verify it moves to active deliveries
        expect(
          repository.myActiveDeliveries.any((d) => d.id == donation.id),
          isTrue,
        );

        // Volunteer confirms pickup
        final pickedUp = await repository.confirmVolunteerPickup(
          donationId: donation.id,
          enteredOtp: '1234',
        );
        expect(pickedUp, isTrue);

        final initialEarnings = repository.volunteerTotalEarnings;

        // Volunteer completes delivery
        final completed = await repository.completeVolunteerDelivery(
          donationId: donation.id,
        );
        expect(completed, isTrue);
        expect(
          repository.volunteerTotalEarnings,
          equals(initialEarnings + 26.0),
        );
        expect(
          repository.myCompletedDeliveries.any((d) => d.id == donation.id),
          isTrue,
        );

        repository.dispose();
      },
    );

    test(
      'Donor posts surplus donation: instantly visible in volunteer available deliveries and dispatches volunteer notification',
      () async {
        final repository = AppRepository();
        repository.setRole(UserRole.donor);

        // Donor posts a fresh donation
        final freshDonation = await repository.createDonation(
          DonationModel(
            id: 'test-donor-post-001',
            donorName: 'Grand Orchid Banquet',
            donorPhone: '+91 98860 12345',
            title: '50 Fresh Meals Pack',
            foodType: 'Cooked Meals',
            quantityLabel: '50 Packets',
            quantityServings: 50,
            preparedAt: DateTime.now().subtract(const Duration(minutes: 15)),
            safeUntil: DateTime.now().add(const Duration(hours: 4)),
            storageRequirements: 'Insulated hot bags',
            allergens: const ['None'],
            pickupAddress: 'MG Road, Bengaluru',
            pickupLatitude: 12.9750,
            pickupLongitude: 77.6000,
            pickupOtp: '8899',
            urgencyLevel: UrgencyLevel.high,
            aiUrgencyScore: 90,
            status: DonationStatus.available,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        // Switch to volunteer
        repository.setRole(UserRole.volunteer);

        // 1. Check real-time volunteer notification exists
        final hasVolNotif = repository.notifications.any(
          (n) =>
              n.recipientRole == 'volunteer' &&
              n.title.contains('New Food Donation Ready for Delivery'),
        );
        expect(hasVolNotif, isTrue);

        // 2. Check fresh donation appears in available volunteer deliveries immediately!
        final available = repository.availableVolunteerDeliveries;
        expect(available.any((d) => d.id == freshDonation.id), isTrue);

        // 3. Volunteer can accept it directly
        final accepted = await repository.acceptVolunteerDelivery(
          donationId: freshDonation.id,
          volunteerId: 'vol-user-2',
          volunteerName: 'Pooja Patil',
        );
        expect(accepted, isTrue);

        // 4. Verify it auto-assigned to an NGO shelter and is in active deliveries
        expect(
          repository.myActiveDeliveries.any((d) => d.id == freshDonation.id),
          isTrue,
        );
        final activeDonation = repository.myActiveDeliveries.firstWhere(
          (d) => d.id == freshDonation.id,
        );
        expect(activeDonation.reservedNgoName, isNotNull);
        expect(activeDonation.deliveryFee, greaterThanOrEqualTo(20.0));

        repository.dispose();
      },
    );
  });

  group('OfflineSyncService Tests', () {
    final syncService = OfflineSyncService.instance;

    setUp(() {
      syncService.clearQueue();
      syncService.toggleConnectivity(false); // set offline for deterministic queue assertions
    });

    test('enqueueAction enqueues offline action when offline', () {
      expect(syncService.pendingCount, equals(0));
      expect(syncService.hasPendingActions, isFalse);

      syncService.enqueueAction('OTP_VERIFIED', {'otp': '123456'});

      expect(syncService.pendingCount, equals(1));
      expect(syncService.hasPendingActions, isTrue);
      expect(syncService.pendingQueue.first.actionType, equals('OTP_VERIFIED'));
    });

    test('enqueueAll adds multiple actions to queue', () {
      syncService.enqueueAll([
        {'actionType': 'CLAIM_PICKUP', 'payload': {'id': 'd-1'}},
        {'actionType': 'THERMAL_LOG', 'payload': {'temp': 4.5}},
      ]);

      expect(syncService.pendingCount, equals(2));
      expect(syncService.hasPendingActions, isTrue);
      expect(syncService.pendingQueue[0].actionType, equals('CLAIM_PICKUP'));
      expect(syncService.pendingQueue[1].actionType, equals('THERMAL_LOG'));
    });

    test('clearQueue resets pending actions and retries', () {
      syncService.enqueueAction('SAMPLE', {});
      expect(syncService.pendingCount, equals(1));

      syncService.clearQueue();

      expect(syncService.pendingCount, equals(0));
      expect(syncService.hasPendingActions, isFalse);
      expect(syncService.retryCount, equals(0));
    });
  });

  group('UserProfileModel Helper Tests', () {
    test('role query getters reflect assigned role accurately', () {
      final user = UserProfileModel(
        id: 'u-1',
        phone: '+91 9876543210',
        fullName: 'Yogesh Chavan',
        role: UserRole.volunteer,
        createdAt: DateTime.now(),
      );

      expect(user.isVolunteer, isTrue);
      expect(user.isDonor, isFalse);
      expect(user.isNgo, isFalse);
      expect(user.isAdmin, isFalse);
      expect(user.isCommunity, isFalse);
    });

    test('copyWith produces updated clone without mutating original', () {
      final user = UserProfileModel(
        id: 'u-2',
        phone: '+91 9876543210',
        fullName: 'Rahul Sharma',
        role: UserRole.donor,
        createdAt: DateTime.now(),
      );

      final updated = user.copyWith(fullName: 'Rahul S. Sharma', email: 'rahul@example.com');
      expect(updated.fullName, equals('Rahul S. Sharma'));
      expect(updated.email, equals('rahul@example.com'));
      expect(updated.phone, equals(user.phone));
      expect(user.email, isNull);
    });
  });

  group('DonationModel Freshness & Helper Tests', () {
    test('isSafeToConsume and remainingMinutes calculate accurately', () {
      final now = DateTime.now();
      final freshDonation = DonationModel(
        id: 'don-test-fresh',
        title: 'Fresh Bread',
        foodType: 'Bakery & Grains',
        quantityLabel: '20 loaves',
        quantityServings: 20,
        pickupAddress: 'Pune Station',
        preparedAt: now.subtract(const Duration(minutes: 30)),
        safeUntil: now.add(const Duration(hours: 3)),
        status: DonationStatus.available,
        createdAt: now,
        updatedAt: now,
      );

      expect(freshDonation.isExpired, isFalse);
      expect(freshDonation.isSafeToConsume, isTrue);
      expect(freshDonation.remainingMinutes, greaterThan(150));
    });

    test('expired donation reflects isSafeToConsume false', () {
      final now = DateTime.now();
      final expiredDonation = DonationModel(
        id: 'don-test-exp',
        title: 'Salad',
        foodType: 'Produce & Veggies',
        quantityLabel: '5 boxes',
        quantityServings: 5,
        pickupAddress: 'Shivajinagar, Pune',
        preparedAt: now.subtract(const Duration(hours: 5)),
        safeUntil: now.subtract(const Duration(hours: 1)),
        status: DonationStatus.expired,
        createdAt: now,
        updatedAt: now,
      );

      expect(expiredDonation.isExpired, isTrue);
      expect(expiredDonation.isSafeToConsume, isFalse);
      expect(expiredDonation.remainingMinutes, equals(0));
    });

    test('UserProfileModel serializes vehicleType correctly in json', () {
      final jsonMap = {
        'id': 'vol-100',
        'phone': '+91 9999888877',
        'full_name': 'Anita Deshmukh',
        'role': 'volunteer',
        'vehicle_type': 'Motorcycle / Scooter',
      };

      final profile = UserProfileModel.fromJson(jsonMap);
      expect(profile.vehicleType, equals('Motorcycle / Scooter'));
      expect(profile.isVolunteer, isTrue);

      final exportedJson = profile.toJson();
      expect(exportedJson['vehicle_type'], equals('Motorcycle / Scooter'));
    });
  });

  group('LocalizationService Tests', () {
    test('fetches correct localized string and switches language', () {
      final loc = LocalizationService.instance;
      loc.setLanguage(AppLanguage.mr);

      expect(loc.translate('app_title'), equals('फूडब्रिज २.०'));
      expect(loc.translate('role_volunteer'), equals('स्वयंसेवक डिलिव्हरी रायडर'));

      loc.setLanguage(AppLanguage.hi);
      expect(loc.translate('role_volunteer'), equals('स्वयंसेवक डिलीवरी राइडर'));

      loc.setLanguage(AppLanguage.en);
      expect(loc.translate('continue_btn'), equals('Continue'));
    });
  });

  group('NGOModel Helper Tests', () {
    test('hasStorageCapacity and verification flags report correctly', () {
      final now = DateTime.now();
      final ngo = NGOModel(
        id: 'ngo-pune-1',
        organizationName: 'Pune Seva Trust',
        registrationNumber: 'MH-PUN-2024-89',
        contactPerson: 'Sunil Rao',
        phone: '+91 9422001122',
        address: 'FC Road, Pune',
        latitude: 18.5204,
        longitude: 73.8567,
        verificationStatus: NGOVerificationStatus.verified,
        capacityMealsPerDay: 150,
        createdAt: now,
      );

      expect(ngo.isVerified, isTrue);
      expect(ngo.isPendingVerification, isFalse);
      expect(ngo.hasStorageCapacity, isTrue);
    });
  });

  group('CommunityDonationModel Helper Tests', () {
    test('isFulfilled and has80GReceipt reflect state accurately', () {
      final now = DateTime.now();
      final donation = CommunityDonationModel(
        id: 'comm-1',
        category: CommunityDonationCategory.books,
        title: 'Science Textbooks (Grade 10)',
        description: 'Complete syllabus set',
        quantityOrAmount: '12 books',
        donorName: 'Dr. Ramesh Kulkarni',
        donorPhone: '+91 9823012345',
        pickupAddress: 'Kothrud, Pune',
        status: CommunityDonationStatus.distributed,
        tax80GReceiptNumber: '80G-PUN-2026-0044',
        createdAt: now,
      );

      expect(donation.isFulfilled, isTrue);
      expect(donation.has80GReceipt, isTrue);
      expect(donation.displayDonorName, equals('Dr. Ramesh Kulkarni'));
    });
  });

  group('AIAllocationService Environmental Metrics Tests', () {
    final aiService = AIAllocationService();

    test('computes accurate CO2 and water conservation metrics', () {
      expect(aiService.computeCo2SavedKg(10), equals(25.0)); // 10 * 2.5 kg
      expect(aiService.computeWaterSavedLiters(10), equals(7200.0)); // 10 * 720 L
      expect(aiService.computeCo2SavedKg(0), equals(0.0));
      expect(aiService.computeWaterSavedLiters(-5), equals(0.0));
    });
  });

  group('NotificationModel Helper Tests', () {
    test('isUrgent flags emergency alert and urgent keywords', () {
      final emergencyNotif = NotificationModel(
        id: 'n-1',
        recipientRole: 'ngo',
        title: 'Emergency Food Alert',
        message: 'Surplus hot meals expiring in 45 minutes',
        type: 'emergency_alert',
      );
      expect(emergencyNotif.isUrgent, isTrue);

      final regularNotif = NotificationModel(
        id: 'n-2',
        recipientRole: 'donor',
        title: 'Thank You for Donating',
        message: 'Your donation reached 40 beneficiaries',
        type: 'system',
      );
      expect(regularNotif.isUrgent, isFalse);
    });
  });
}
