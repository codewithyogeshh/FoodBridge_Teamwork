import '../models/ngo_model.dart';
import '../models/donation_model.dart';
import '../models/notification_model.dart';
import '../../ui/core/constants.dart';

/// Centralized seed data for offline fallback, demos, and testing.
class SeedData {
  SeedData._();

  static List<NGOModel> get initialNGOs => [
        NGOModel(
          id: 'a1111111-1111-1111-1111-111111111111',
          organizationName: 'Hope Care Foundation Kitchen',
          registrationNumber: 'NGO-2021-8849',
          contactPerson: 'Sister Agnes',
          phone: '+91 98450 12345',
          address: '12 Brigade Road, Bengaluru',
          latitude: 12.9719,
          longitude: 77.5950,
          verificationStatus: NGOVerificationStatus.verified,
          capacityMealsPerDay: 350,
          foodSafetyCertId: 'FSSAI-8839210-BLR',
          createdAt: DateTime.now().subtract(const Duration(days: 120)),
        ),
        NGOModel(
          id: 'a2222222-2222-2222-2222-222222222222',
          organizationName: 'Robin Hood Food Rescue',
          registrationNumber: 'NGO-2019-3321',
          contactPerson: 'Arjun Verma',
          phone: '+91 98450 67890',
          address: '45 Indiranagar 100ft Road, Bengaluru',
          latitude: 12.9784,
          longitude: 77.6408,
          verificationStatus: NGOVerificationStatus.verified,
          capacityMealsPerDay: 500,
          foodSafetyCertId: 'FSSAI-7744129-BLR',
          createdAt: DateTime.now().subtract(const Duration(days: 340)),
        ),
        NGOModel(
          id: 'a3333333-3333-3333-3333-333333333333',
          organizationName: 'Seva Orphanage & Children Shelter',
          registrationNumber: 'NGO-2023-9912',
          contactPerson: 'Meera Nair',
          phone: '+91 98450 54321',
          address: '88 Koramangala 4th Block, Bengaluru',
          latitude: 12.9352,
          longitude: 77.6245,
          verificationStatus: NGOVerificationStatus.verified,
          capacityMealsPerDay: 180,
          foodSafetyCertId: 'FSSAI-9921045-BLR',
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
        ),
        NGOModel(
          id: 'a4444444-4444-4444-4444-444444444444',
          organizationName: 'Annam Amrita Community Kitchen',
          registrationNumber: 'NGO-2024-1029',
          contactPerson: 'Rajesh K.',
          phone: '+91 98450 11223',
          address: '23 Malleshwaram 7th Cross, Bengaluru',
          latitude: 12.9965,
          longitude: 77.5713,
          verificationStatus: NGOVerificationStatus.pending,
          capacityMealsPerDay: 250,
          foodSafetyCertId: 'PENDING-VERIF-DOCS',
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
        ),
      ];

  static List<DonationModel> get initialDonations => [
        DonationModel(
          id: 'dc7246be-3d73-4e89-b689-a9bfddd819e3',
          donorName: 'Spice Garden Restaurant',
          donorPhone: '+91 98860 12345',
          title: 'Surplus Fresh Biryani & Raita (80 portions)',
          foodType: 'Cooked Meals',
          quantityLabel: '80 Portions (~32 kg)',
          quantityServings: 80,
          preparedAt: DateTime.now().subtract(const Duration(hours: 1)),
          safeUntil: DateTime.now().add(const Duration(hours: 4)),
          storageRequirements:
              'Keep warm above 60°C or immediate thermal insulated transport',
          allergens: const ['Dairy', 'Nuts'],
          pickupAddress: 'Royal Banquet Hall, Residency Rd, Bengaluru',
          pickupLatitude: 12.9698,
          pickupLongitude: 77.6012,
          pickupInstructions:
              'Enter via Service Gate 3 at rear. Thermal insulated food pans provided.',
          pickupOtp: '7412',
          imageUrl:
              'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=800&auto=format&fit=crop',
          urgencyLevel: UrgencyLevel.critical,
          aiUrgencyScore: 94,
          aiRecommendationSummary:
              'Cooked meal with high temperature sensitivity. Recommended for Hope Care Foundation (1.8 km).',
          status: DonationStatus.available,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        DonationModel(
          id: 'a3cc5e55-8185-45b5-8347-5a459bcde5c4',
          donorName: 'Artisan Bakery & Patisserie',
          donorPhone: '+91 98860 22334',
          title: 'Fresh Artisan Bread & Croissant Surplus',
          foodType: 'Bakery & Grains',
          quantityLabel: '45 Portions (~12 kg)',
          quantityServings: 45,
          preparedAt: DateTime.now().subtract(const Duration(hours: 2)),
          safeUntil: DateTime.now().add(const Duration(hours: 16)),
          storageRequirements:
              'Ambient dry storage, keep in food-safe wax paper bags',
          allergens: const ['Gluten', 'Eggs'],
          pickupAddress: '14 Lavelle Road, Shanthala Nagar, Bengaluru',
          pickupLatitude: 12.9712,
          pickupLongitude: 77.5990,
          pickupInstructions:
              'Pick up directly from front cashier counter. Speak to Manager Kevin.',
          pickupOtp: '5192',
          imageUrl:
              'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800&auto=format&fit=crop',
          urgencyLevel: UrgencyLevel.high,
          aiUrgencyScore: 82,
          aiRecommendationSummary:
              'Baked goods with 16h window. High nutritional value, ideal for Seva Shelter afternoon snack.',
          status: DonationStatus.available,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        DonationModel(
          id: 'b5ee7f11-9292-4f88-a111-9c8877aa22bb',
          donorName: 'Grand Orchid Banquet Hall',
          donorPhone: '+91 98860 99881',
          title: 'Dal Makhani, Pulao & Roti Boxes (50 Meals)',
          foodType: 'Cooked Meals',
          quantityLabel: '50 Warm Thali Boxes',
          quantityServings: 50,
          preparedAt: DateTime.now().subtract(const Duration(minutes: 45)),
          safeUntil: DateTime.now().add(const Duration(hours: 3)),
          storageRequirements:
              'Thermal box transport, safe temperature controlled',
          allergens: const ['Dairy'],
          pickupAddress: 'Grand Orchid, MG Road, Bengaluru',
          pickupLatitude: 12.9755,
          pickupLongitude: 77.6066,
          pickupInstructions:
              'Kitchen loading bay, door #2. Contact Chef Anand.',
          pickupOtp: '8914',
          imageUrl:
              'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=800&auto=format&fit=crop',
          urgencyLevel: UrgencyLevel.critical,
          aiUrgencyScore: 91,
          aiRecommendationSummary:
              'Cooked food reserved by Seva Orphanage without own vehicle. FoodBridge volunteer delivery assigned.',
          status: DonationStatus.reserved,
          requiresVolunteerDelivery: true,
          deliveryFee: 25.0,
          reservedNgoId: 'a3333333-3333-3333-3333-333333333333',
          reservedNgoName: 'Seva Orphanage & Children Shelter',
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
      ];

  static List<NotificationModel> get initialNotifications => [
        NotificationModel(
          id: 'notif-seed-01',
          recipientRole: 'all',
          title: '⚡ Zero-Waste Real-Time Network Active',
          message:
              'Supabase Realtime WebSockets & Database Triggers are connected. Instant push alerts enabled.',
          type: 'system',
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        NotificationModel(
          id: 'notif-seed-vol-01',
          recipientRole: 'volunteer',
          title: '🚴 New Delivery Available (कमाई: ₹25)',
          message:
              'Pick up 50 hot meals from Grand Orchid Banquet, deliver to Seva Orphanage (3.1 km). Guaranteed delivery fee ₹25!',
          type: 'donation_reserved',
          entityId: 'b5ee7f11-9292-4f88-a111-9c8877aa22bb',
          metadata: {
            'donation_id': 'b5ee7f11-9292-4f88-a111-9c8877aa22bb',
            'delivery_fee': 25.0,
            'ngo_name': 'Seva Orphanage & Children Shelter',
          },
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        NotificationModel(
          id: 'notif-seed-02',
          recipientRole: 'ngo',
          title: '🚨 New Surplus Food Alert: Surplus Wedding Feast',
          message:
              'Grand Orchid Banquet posted 75 Portions of Cooked Meals near Residency Rd. Safe until 3 hours.',
          type: 'donation_created',
          entityId: 'd1111111-1111-1111-1111-111111111111',
          metadata: {
            'donation_id': 'd1111111-1111-1111-1111-111111111111',
            'urgency_level': 'CRITICAL',
            'quantity_servings': 75,
          },
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
        NotificationModel(
          id: 'notif-seed-03',
          recipientRole: 'admin',
          title: '📦 New Donation Registered: Surplus Wedding Feast',
          message:
              'Donor Grand Orchid Banquet (+91 98860 12345) submitted 75 portions. Urgency: CRITICAL.',
          type: 'donation_created',
          entityId: 'd1111111-1111-1111-1111-111111111111',
          metadata: {
            'donation_id': 'd1111111-1111-1111-1111-111111111111',
            'urgency_level': 'CRITICAL',
            'quantity_servings': 75,
          },
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
      ];
}
