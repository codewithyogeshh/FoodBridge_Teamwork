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

void main() {
  group('AIAllocationService Tests', () {
    final aiService = AIAllocationService();

    test('Computes critical urgency for cooked meals with <= 180 min remaining', () {
      final now = DateTime.now();
      final urgency = aiService.computePerishabilityUrgency(
        foodType: 'Cooked Meals',
        preparedAt: now.subtract(const Duration(hours: 1)),
        safeUntil: now.add(const Duration(hours: 2)), // 120 min left
      );
      expect(urgency, UrgencyLevel.critical);
    });

    test('Computes low urgency for bakery items with 2 days remaining', () {
      final now = DateTime.now();
      final urgency = aiService.computePerishabilityUrgency(
        foodType: 'Bakery & Grains',
        preparedAt: now.subtract(const Duration(hours: 2)),
        safeUntil: now.add(const Duration(hours: 48)),
      );
      expect(urgency, UrgencyLevel.low);
    });

    test('Produces AI allocation recommendations with transparent explanations and safety disclaimer', () {
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
      expect(analysis.matches.first.ngo.organizationName, 'City Relief Mission');
      expect(analysis.matches.first.matchReasons.isNotEmpty, true);

      // AI Safety Guardrail rule check:
      expect(AIAllocationAnalysis.safetyNotice.contains('cannot physically inspect or certify microbiological food safety'), true);
      expect(AIAllocationAnalysis.safetyNotice.contains('visually and thermally verify food freshness'), true);
    });
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
    test('Anonymous mode conceals donor identity and phone on public feeds', () {
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
    });

    test('CommunityDonationModel serializes and deserializes monetary and physical categories', () {
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
    });

    test('AppRepository creates and persists community donation correctly', () async {
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
      expect(repository.communityDonations.first.title, 'Class 10 Science & Math Textbooks');
    });
  });

  group('Supabase Real-Time Notifications & Dispatch Tests', () {
    test('NotificationModel serializes and parses properly with urgency metadata', () {
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
    });

    test('Creating a donation automatically creates instant notifications for NGO and Admin', () async {
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
      final hasNgoNotif = repository.notifications.any((n) =>
          n.recipientRole == 'ngo' && n.title.contains('Surplus Fresh Biryani'));
      expect(hasNgoNotif, isTrue);
      expect(repository.unreadNotificationCount, greaterThan(0));

      // Verify instant notification generated for Admin
      repository.setRole(UserRole.admin);
      final hasAdminNotif = repository.notifications.any((n) =>
          n.recipientRole == 'admin' && n.title.contains('Surplus Fresh Biryani'));
      expect(hasAdminNotif, isTrue);
      expect(repository.unreadNotificationCount, greaterThan(0));

      // Verify mark read functionality
      repository.setRole(UserRole.ngo);
      final firstUnread = repository.notifications.firstWhere((n) => !n.isRead);
      await repository.markNotificationRead(firstUnread.id);
      expect(repository.notifications.firstWhere((n) => n.id == firstUnread.id).isRead, isTrue);

      repository.dispose();
    });
  });
}
