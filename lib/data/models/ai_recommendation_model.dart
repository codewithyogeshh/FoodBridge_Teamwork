import 'package:flutter/foundation.dart';
import 'ngo_model.dart';
import '../../ui/core/constants.dart';

@immutable
class AIRecommendationMatch {
  final NGOModel ngo;
  final double matchScore; // 0.0 to 100.0
  final double distanceKm;
  final int estimatedTravelMinutes;
  final int currentRequestedCapacity;
  final List<String> matchReasons;
  final bool capacitySufficient;

  const AIRecommendationMatch({
    required this.ngo,
    required this.matchScore,
    required this.distanceKm,
    required this.estimatedTravelMinutes,
    required this.currentRequestedCapacity,
    required this.matchReasons,
    required this.capacitySufficient,
  });
}

@immutable
class AIAllocationAnalysis {
  final String donationId;
  final UrgencyLevel computedUrgency;
  final int urgencyScore; // 1-100
  final String perishabilitySummary;
  final String temperatureGuideline;
  final Duration safeConsumptionWindow;
  final List<AIRecommendationMatch> matches;
  final String transparentReasoning;
  final DateTime analyzedAt;

  const AIAllocationAnalysis({
    required this.donationId,
    required this.computedUrgency,
    required this.urgencyScore,
    required this.perishabilitySummary,
    required this.temperatureGuideline,
    required this.safeConsumptionWindow,
    required this.matches,
    required this.transparentReasoning,
    required this.analyzedAt,
  });

  /// Explicit guardrail requirement:
  static const String safetyNotice =
      'AI Recommendation Notice: FoodBridge AI assists logistics routing and demand matching. '
      'AI cannot physically inspect or certify microbiological food safety. '
      'Donors and receiving NGOs must visually and thermally verify food freshness before consumption.';

  @override
  String toString() =>
      'AIAllocationAnalysis(donationId: $donationId, urgency: ${computedUrgency.name}, '
      'score: $urgencyScore, matches: ${matches.length})';
}
