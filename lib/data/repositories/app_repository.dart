import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/donation_model.dart';
import '../models/ngo_model.dart';
import '../models/user_profile_model.dart';
import '../models/ai_recommendation_model.dart';
import '../models/community_donation_model.dart';
import '../models/notification_model.dart';
import '../services/supabase_service.dart';
import '../services/ai_allocation_service.dart';
import '../../ui/core/constants.dart';

class AppRepository extends ChangeNotifier {
  final SupabaseService _supabaseService;
  final AIAllocationService _aiService;

  StreamSubscription<NotificationModel>? _notifSubscription;
  StreamSubscription<DonationModel>? _donationSubscription;
  StreamSubscription<NGOModel>? _ngoSubscription;

  UserRole _currentRole = UserRole.donor;
  UserProfileModel _currentUser = UserProfileModel(
    id: 'u-demo-donor-001',
    phone: '+91 98860 12345',
    fullName: 'Rahul Sharma (Grand Orchid)',
    role: UserRole.donor,
    organizationName: 'Grand Orchid Banquet',
    createdAt: DateTime.now().subtract(const Duration(days: 90)),
  );

  final List<DonationModel> _donations = [];
  final List<NGOModel> _ngos = [];
  final List<NotificationModel> _notifications = [];

  final List<CommunityDonationModel> _communityDonations = [
    CommunityDonationModel(
      id: 'cd-101',
      category: CommunityDonationCategory.clothes,
      title: 'Warm Winter Blankets & Jackets (18 pcs)',
      description:
          'Clean wool sweaters, thermal wear and blankets for children & seniors.',
      quantityOrAmount: '18 Items',
      donorName: 'Dr. Ananya Roy',
      donorPhone: '+91 98450 11223',
      isAnonymous: false,
      pickupAddress: 'Indiranagar 100ft Road, Bengaluru',
      status: CommunityDonationStatus.distributed,
      assignedNgoName: 'Hope Care Foundation Kitchen',
      conditionRating: 'Gently Used (Cleaned)',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    CommunityDonationModel(
      id: 'cd-102',
      category: CommunityDonationCategory.books,
      title: 'NCERT Grade 6-10 Textbooks & Stationery Sets',
      description:
          'Science, Math & English books along with 30 unruled notebooks and pen kits.',
      quantityOrAmount: '24 Books + 30 Notebooks',
      donorName: 'Anonymous Well-Wisher',
      donorPhone: '+91 99000 88776',
      isAnonymous: true,
      pickupAddress: 'Koramangala 4th Block, Bengaluru',
      status: CommunityDonationStatus.matchedWithNGO,
      assignedNgoName: 'Annam Kitchen & Child Shelter',
      conditionRating: 'Like New',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    CommunityDonationModel(
      id: 'cd-103',
      category: CommunityDonationCategory.monetary,
      title: 'Hot Meals Relief Sponsorship (100 Meals)',
      description:
          'Sponsored fresh hot lunch packets for migratory workers and shelter ward.',
      quantityOrAmount: '₹2,500',
      donorName: 'Vikramaditya Sengupta',
      donorPhone: '+91 98110 99887',
      isAnonymous: false,
      pickupAddress: 'Online Contribution (UPI / Razorpay)',
      status: CommunityDonationStatus.distributed,
      assignedNgoName: 'Annam Kitchen Trust',
      tax80GReceiptNumber: '80G-FB-2026-90412',
      paymentTransactionId: 'PAY-UPI-9844210984',
      createdAt: DateTime.now().subtract(const Duration(hours: 14)),
    ),
    CommunityDonationModel(
      id: 'cd-104',
      category: CommunityDonationCategory.essentials,
      title: 'Sealed Dry Rations (Rice, Lentils, Cooking Oil)',
      description:
          'Two 20kg bags of Sona Masoori Rice and 10kg Toor Dal in manufacturer sealed bags.',
      quantityOrAmount: '50 kg Grains',
      donorName: 'Citizens Care Collective',
      donorPhone: '+91 97410 33445',
      isAnonymous: false,
      pickupAddress: 'HSR Layout Sector 2, Bengaluru',
      status: CommunityDonationStatus.inTransit,
      assignedNgoName: 'Hope Care Foundation Kitchen',
      conditionRating: 'Factory Sealed',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];
  bool _isLoading = false;
  String? _errorMessage;

  AppRepository({
    SupabaseService? supabaseService,
    AIAllocationService? aiService,
  }) : _supabaseService = supabaseService ?? SupabaseService(),
       _aiService = aiService ?? AIAllocationService() {
    _initRealtimeListeners();
    refreshAllData();
  }

  void _initRealtimeListeners() {
    // 1. Reactive Realtime Notification Stream
    _notifSubscription = _supabaseService.notificationStream.listen((notif) {
      if (!_notifications.any((n) => n.id == notif.id)) {
        _notifications.insert(0, notif);
        notifyListeners();
      }
    });

    // 2. Reactive Realtime Donation Stream
    _donationSubscription = _supabaseService.donationStream.listen((donation) {
      final idx = _donations.indexWhere((d) => d.id == donation.id);
      if (idx != -1) {
        _donations[idx] = donation;
      } else {
        _donations.insert(0, donation);
      }
      notifyListeners();
    });

    // 3. Reactive Realtime NGO Stream
    _ngoSubscription = _supabaseService.ngoStream.listen((ngo) {
      final idx = _ngos.indexWhere(
        (n) => n.id == ngo.id || n.phone == ngo.phone,
      );
      if (idx != -1) {
        _ngos[idx] = ngo;
      } else {
        _ngos.insert(0, ngo);
      }
      notifyListeners();
    });
  }

  // Getters
  UserRole get currentRole => _currentRole;
  UserProfileModel get currentUser => _currentUser;
  List<DonationModel> get donations => List.unmodifiable(_donations);
  List<NGOModel> get ngos => List.unmodifiable(_ngos);
  List<NotificationModel> get notifications {
    final roleStr = _currentRole.name.toLowerCase();
    return List.unmodifiable(
      _notifications.where(
        (n) => n.recipientRole == roleStr || n.recipientRole == 'all',
      ),
    );
  }

  List<CommunityDonationModel> get communityDonations =>
      List.unmodifiable(_communityDonations);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Stream<NotificationModel> get onNotificationStream =>
      _supabaseService.notificationStream;

  int get unreadNotificationCount {
    final roleStr = _currentRole.name.toLowerCase();
    return _notifications
        .where(
          (n) =>
              !n.isRead &&
              (n.recipientRole == roleStr || n.recipientRole == 'all'),
        )
        .length;
  }

  List<DonationModel> get availableDonations =>
      _donations.where((d) => d.status == DonationStatus.available).toList();

  List<DonationModel> get activeReservedDonations =>
      _donations.where((d) => d.status == DonationStatus.reserved).toList();

  List<DonationModel> get completedDonations => _donations
      .where(
        (d) =>
            d.status == DonationStatus.delivered ||
            d.status == DonationStatus.pickupVerified,
      )
      .toList();

  List<NGOModel> get verifiedNGOs => _ngos
      .where((n) => n.verificationStatus == NGOVerificationStatus.verified)
      .toList();

  List<NGOModel> get pendingNGOs => _ngos
      .where((n) => n.verificationStatus == NGOVerificationStatus.pending)
      .toList();

  // Metrics
  int get totalMealsRescued {
    int count = 0;
    for (final d in _donations) {
      if (d.status == DonationStatus.delivered ||
          d.status == DonationStatus.pickupVerified) {
        count += d.quantityServings;
      }
    }
    return count + 12840;
  }

  double get totalCo2OffsetKg =>
      totalMealsRescued * AppConstants.co2SavedPerMealKg;
  double get totalWaterConservedL =>
      totalMealsRescued * AppConstants.waterSavedPerMealL;

  void setRole(UserRole role, [UserProfileModel? customProfile]) {
    _currentRole = role;
    if (customProfile != null) {
      _currentUser = customProfile;
    } else if (role == UserRole.donor) {
      _currentUser = UserProfileModel(
        id: 'u-demo-donor-001',
        phone: '+91 98860 12345',
        fullName: 'Rahul Sharma (Grand Orchid)',
        role: UserRole.donor,
        organizationName: 'Grand Orchid Banquet',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      );
    } else if (role == UserRole.community) {
      _currentUser = UserProfileModel(
        id: 'u-community-user-004',
        phone: '+91 97110 54321',
        fullName: 'Citizen Contributor',
        role: UserRole.community,
        organizationName: 'Community Giving Network',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );
    } else if (role == UserRole.ngo) {
      _currentUser = UserProfileModel(
        id: 'u-demo-ngo-002',
        phone: '+91 98450 12345',
        fullName: 'Sister Agnes (Hope Care)',
        role: UserRole.ngo,
        organizationName: 'Hope Care Foundation Kitchen',
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
      );
    } else {
      _currentUser = UserProfileModel(
        id: 'u-demo-admin-003',
        phone: '+91 98000 00001',
        fullName: 'Aaditya Mehta (Chief Auditor)',
        role: UserRole.admin,
        organizationName: 'FoodBridge Operations',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      );
    }
    // Instantly sync user profile with Supabase and refresh data
    syncCurrentUserProfile();
    refreshAllData();
    notifyListeners();
  }

  /// Syncs current user profile to Supabase and fetches real-time updates
  Future<void> syncCurrentUserProfile() async {
    try {
      final synced = await _supabaseService.syncUserProfile(_currentUser);
      _currentUser = synced;
      notifyListeners();
    } catch (e) {
      debugPrint('Supabase syncCurrentUserProfile notice: $e');
    }
  }

  Future<void> refreshNotifications() async {
    try {
      final roleStr = _currentRole.name.toLowerCase();
      final notifs = await _supabaseService.getNotifications(role: roleStr);
      for (final n in notifs) {
        if (!_notifications.any((existing) => existing.id == n.id)) {
          _notifications.add(n);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing notifications: $e');
    }
  }

  Future<void> markNotificationRead(String id) async {
    await _supabaseService.markNotificationAsRead(id);
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  Future<void> markAllNotificationsRead() async {
    final roleStr = _currentRole.name.toLowerCase();
    await _supabaseService.markAllNotificationsAsRead(roleStr);
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  Future<CommunityDonationModel> createCommunityDonation(
    CommunityDonationModel donation,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      _communityDonations.insert(0, donation);
      return donation;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAllData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedDonations = await _supabaseService.getDonations();
      final fetchedNGOs = await _supabaseService.getNGOs();
      final fetchedNotifs = await _supabaseService.getNotifications(
        role: _currentRole.name.toLowerCase(),
      );

      // Synchronize donations list directly with Supabase
      if (fetchedDonations.isNotEmpty) {
        _donations.clear();
        _donations.addAll(fetchedDonations);
      }
      for (final n in fetchedNGOs) {
        final idx = _ngos.indexWhere((x) => x.id == n.id);
        if (idx != -1) {
          _ngos[idx] = n;
        } else {
          _ngos.add(n);
        }
      }
      for (final n in fetchedNotifs) {
        if (!_notifications.any((existing) => existing.id == n.id)) {
          _notifications.add(n);
        }
      }
    } catch (e) {
      _errorMessage = 'Network connection notice: using offline cache';
      debugPrint('AppRepository fetch notice: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<DonationModel> createDonation(DonationModel donation) async {
    _isLoading = true;
    notifyListeners();
    try {
      final created = await _supabaseService.createDonation(donation);
      final existingIndex = _donations.indexWhere((d) => d.id == created.id);
      if (existingIndex >= 0) {
        _donations[existingIndex] = created;
      } else {
        _donations.insert(0, created);
      }
      return created;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> uploadImage(
    Uint8List bytes,
    String filename, {
    String bucket = 'donation-images',
  }) async {
    return await _supabaseService.uploadImage(
      bytes: bytes,
      filename: filename,
      bucket: bucket,
    );
  }

  Future<Map<String, dynamic>> reserveDonation({
    required String donationId,
    required String ngoId,
    required String ngoName,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _supabaseService.reserveDonationAtomic(
        donationId: donationId,
        ngoId: ngoId,
        ngoName: ngoName,
      );

      if (res['success'] == true) {
        final idx = _donations.indexWhere((d) => d.id == donationId);
        if (idx != -1) {
          _donations[idx] = _donations[idx].copyWith(
            status: DonationStatus.reserved,
          );
        }
      }
      return res;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> verifyPickup({
    required String donationId,
    required String enteredOtp,
    required String ngoId,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _supabaseService.verifyPickupOtp(
        donationId: donationId,
        enteredOtp: enteredOtp,
        ngoId: ngoId,
      );

      if (res['success'] == true) {
        final idx = _donations.indexWhere((d) => d.id == donationId);
        if (idx != -1) {
          _donations[idx] = _donations[idx].copyWith(
            status: DonationStatus.pickupVerified,
          );
        }
      }
      return res;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> confirmDelivery({
    required String donationId,
    required int distributionCount,
    String? deliveryNotes,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _supabaseService.confirmDelivery(
        donationId: donationId,
        distributionCount: distributionCount,
        deliveryNotes: deliveryNotes,
      );
      if (success) {
        final idx = _donations.indexWhere((d) => d.id == donationId);
        if (idx != -1) {
          _donations[idx] = _donations[idx].copyWith(
            status: DonationStatus.delivered,
          );
        }
      }
      return success;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<NGOModel> registerNGO(NGOModel ngo) async {
    _isLoading = true;
    notifyListeners();
    try {
      final created = await _supabaseService.registerNGO(ngo);
      _ngos.insert(0, created);
      return created;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateNGOVerification(
    String ngoId,
    NGOVerificationStatus status,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _supabaseService.updateNGOVerificationStatus(
        ngoId,
        status,
      );
      if (success) {
        final idx = _ngos.indexWhere((n) => n.id == ngoId);
        if (idx != -1) {
          _ngos[idx] = _ngos[idx].copyWith(verificationStatus: status);
        }
      }
      return success;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  AIAllocationAnalysis runAIAllocation(DonationModel donation) {
    return _aiService.analyzeDonationAllocation(
      donation: donation,
      availableNGOs: _ngos,
    );
  }

  /// Looks up an existing registered NGO by phone number or registration number
  NGOModel? findNGOByPhoneOrReg(String query) {
    final cleanQuery = query
        .replaceAll(RegExp(r'[\s\-\+\(\)]'), '')
        .toLowerCase();
    if (cleanQuery.isEmpty) return null;

    for (final ngo in _ngos) {
      final cleanPhone = ngo.phone
          .replaceAll(RegExp(r'[\s\-\+\(\)]'), '')
          .toLowerCase();
      final cleanReg = ngo.registrationNumber
          .replaceAll(RegExp(r'[\s\-\+\(\)]'), '')
          .toLowerCase();

      if (cleanPhone == cleanQuery ||
          cleanReg == cleanQuery ||
          cleanPhone.endsWith(cleanQuery) ||
          cleanQuery.endsWith(cleanPhone) ||
          cleanReg.contains(cleanQuery)) {
        return ngo;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _notifSubscription?.cancel();
    _donationSubscription?.cancel();
    _ngoSubscription?.cancel();
    _supabaseService.dispose();
    super.dispose();
  }
}
