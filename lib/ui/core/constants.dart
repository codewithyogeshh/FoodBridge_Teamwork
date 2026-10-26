/// FoodBridge 2.0 Global Constants and Configuration
class AppConstants {
  // Supabase Backend Configuration
  static const String supabaseUrl = 'https://idajqabgvficbtvrqkvx.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlkYWpxYWJndmZpY2J0dnJxa3Z4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI3Mzk0MjksImV4cCI6MjEwODMxNTQyOX0.iEdk-ClT3NooOe-PtVxovfqMAXAQuItsQL-q2_Gguc0';

  // Application Info
  static const String appName = 'FoodBridge 2.0';
  static const String appTagline = 'Zero-Waste AI Food Rescue Network';
  static const String appVersion = 'v2.5.0-hackathon';

  // Food Categories
  static const List<String> foodCategories = [
    'Cooked Meals',
    'Bakery & Grains',
    'Produce & Veggies',
    'Packaged Goods',
    'Dairy & Beverages',
    'Fruits & Juices',
  ];

  // Storage Requirements
  static const List<String> storageOptions = [
    'Hot Insulated (> 60°C)',
    'Refrigerated (< 4°C)',
    'Cool & Dry (15-20°C)',
    'Ambient Room Temp',
    'Frozen (< -18°C)',
  ];

  // Allergens
  static const List<String> commonAllergens = [
    'Dairy',
    'Gluten',
    'Nuts',
    'Soy',
    'Eggs',
    'Shellfish',
    'Mustard',
    'Sesame',
  ];

  // Impact Calculations (per meal saved)
  static const double co2SavedPerMealKg = 2.5; // 2.5 kg CO2e per meal
  static const double waterSavedPerMealL =
      720.0; // 720 liters water footprint conserved

  // Animation & UI Timings
  static const Duration fastAnimationDuration = Duration(milliseconds: 200);
  static const Duration standardAnimationDuration = Duration(milliseconds: 350);
  static const Duration modalAnimationDuration = Duration(milliseconds: 400);

  // Network & Sync Timeouts
  static const Duration defaultApiTimeout = Duration(seconds: 15);
  static const Duration backgroundSyncDebounce = Duration(seconds: 2);
}

enum UserRole { donor, community, ngo, admin, volunteer }

enum DonationStatus {
  available,
  reserved,
  pickupVerified,
  delivered,
  cancelled,
  expired;

  String get dbValue {
    switch (this) {
      case DonationStatus.available:
        return 'AVAILABLE';
      case DonationStatus.reserved:
        return 'RESERVED';
      case DonationStatus.pickupVerified:
        return 'PICKUP_VERIFIED';
      case DonationStatus.delivered:
        return 'DELIVERED';
      case DonationStatus.cancelled:
        return 'CANCELLED';
      case DonationStatus.expired:
        return 'EXPIRED';
    }
  }

  static DonationStatus fromString(String val) {
    switch (val.toUpperCase()) {
      case 'AVAILABLE':
        return DonationStatus.available;
      case 'RESERVED':
        return DonationStatus.reserved;
      case 'PICKUP_VERIFIED':
        return DonationStatus.pickupVerified;
      case 'DELIVERED':
        return DonationStatus.delivered;
      case 'CANCELLED':
        return DonationStatus.cancelled;
      case 'EXPIRED':
        return DonationStatus.expired;
      default:
        return DonationStatus.available;
    }
  }
}

enum UrgencyLevel {
  critical,
  high,
  medium,
  low;

  String get dbValue {
    switch (this) {
      case UrgencyLevel.critical:
        return 'CRITICAL';
      case UrgencyLevel.high:
        return 'HIGH';
      case UrgencyLevel.medium:
        return 'MEDIUM';
      case UrgencyLevel.low:
        return 'LOW';
    }
  }

  static UrgencyLevel fromString(String val) {
    switch (val.toUpperCase()) {
      case 'CRITICAL':
        return UrgencyLevel.critical;
      case 'HIGH':
        return UrgencyLevel.high;
      case 'MEDIUM':
        return UrgencyLevel.medium;
      case 'LOW':
        return UrgencyLevel.low;
      default:
        return UrgencyLevel.medium;
    }
  }
}
