import 'package:flutter/foundation.dart';

class OfflineAction {
  final String id;
  final String actionType; // 'OTP_VERIFIED', 'THERMAL_LOG', 'CLAIM_PICKUP'
  final Map<String, dynamic> payload;
  final DateTime recordedAt;

  OfflineAction({
    required this.id,
    required this.actionType,
    required this.payload,
    required this.recordedAt,
  });
}

class OfflineSyncService extends ChangeNotifier {
  static final OfflineSyncService instance = OfflineSyncService._internal();
  OfflineSyncService._internal();

  bool _isOnline = true;
  final List<OfflineAction> _pendingQueue = [];
  DateTime? _lastSyncTime;
  int _retryCount = 0;
  static const int maxRetries = 3;

  bool get isOnline => _isOnline;
  int get pendingCount => _pendingQueue.length;
  bool get hasPendingActions => _pendingQueue.isNotEmpty;
  List<OfflineAction> get pendingQueue => List.unmodifiable(_pendingQueue);
  DateTime? get lastSyncTime => _lastSyncTime;
  int get retryCount => _retryCount;

  void toggleConnectivity([bool? forceStatus]) {
    _isOnline = forceStatus ?? !_isOnline;
    _retryCount = 0; // Reset retries on connectivity change
    if (_isOnline && _pendingQueue.isNotEmpty) {
      syncNow();
    } else {
      notifyListeners();
    }
  }

  void enqueueAction(String actionType, Map<String, dynamic> payload) {
    final action = OfflineAction(
      id: 'act-${DateTime.now().millisecondsSinceEpoch}',
      actionType: actionType,
      payload: payload,
      recordedAt: DateTime.now(),
    );
    _pendingQueue.add(action);
    if (_isOnline) {
      syncNow();
    } else {
      notifyListeners();
    }
  }

  void enqueueAll(List<Map<String, dynamic>> actions) {
    final now = DateTime.now();
    for (int i = 0; i < actions.length; i++) {
      final item = actions[i];
      _pendingQueue.add(
        OfflineAction(
          id: 'act-${now.millisecondsSinceEpoch}-$i',
          actionType: item['actionType'] as String? ?? 'GENERIC_ACTION',
          payload: item['payload'] as Map<String, dynamic>? ?? item,
          recordedAt: now,
        ),
      );
    }
    if (_isOnline) {
      syncNow();
    } else {
      notifyListeners();
    }
  }

  Future<void> syncNow() async {
    if (!_isOnline) return;
    if (_retryCount >= maxRetries) {
      debugPrint('⚠️ [SYNC] Max retries ($maxRetries) reached. Waiting for manual retry.');
      return;
    }
    // Simulate cloud sync processing
    await Future.delayed(const Duration(milliseconds: 600));
    _pendingQueue.clear();
    _retryCount = 0;
    _lastSyncTime = DateTime.now();
    notifyListeners();
  }

  void clearQueue() {
    _pendingQueue.clear();
    _retryCount = 0;
    notifyListeners();
  }

  void resetRetries() {
    _retryCount = 0;
    notifyListeners();
  }
}

