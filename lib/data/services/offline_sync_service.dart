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

  bool get isOnline => _isOnline;
  int get pendingCount => _pendingQueue.length;
  List<OfflineAction> get pendingQueue => List.unmodifiable(_pendingQueue);
  DateTime? get lastSyncTime => _lastSyncTime;

  void toggleConnectivity([bool? forceStatus]) {
    _isOnline = forceStatus ?? !_isOnline;
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

  Future<void> syncNow() async {
    if (!_isOnline) return;
    // Simulate cloud sync processing
    await Future.delayed(const Duration(milliseconds: 600));
    _pendingQueue.clear();
    _lastSyncTime = DateTime.now();
    notifyListeners();
  }
}
