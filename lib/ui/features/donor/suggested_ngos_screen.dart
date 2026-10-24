import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_badge.dart';
import '../../../data/models/donation_model.dart';
import '../../../data/models/ai_recommendation_model.dart';

class SuggestedNGOsScreen extends StatelessWidget {
  final DonationModel donation;
  final AIAllocationAnalysis analysis;
  final VoidCallback onConfirmed;

  const SuggestedNGOsScreen({
    super.key,
    required this.donation,
    required this.analysis,
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    final matches = analysis.matches;

    return Scaffold(
      backgroundColor: AppTheme.warmIvory,
      appBar: AppBar(
        title: const Text('AI Suggested Receivers'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Summary Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.emeraldLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.hub_rounded,
                        size: 20, color: AppTheme.forestGreen),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${matches.length} Verified NGOs Available',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.richCharcoal,
                          ),
                        ),
                        Text(
                          'Ranked by distance, capacity & ${donation.foodType} suitability',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.charcoalMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.borderColor),

            // Matches List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: matches.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final match = matches[index];
                  final isTopMatch = index == 0;

                  return AppCard(
                    backgroundColor: isTopMatch
                        ? AppTheme.emeraldLight.withValues(alpha: 0.15)
                        : Colors.white,
                    border: BorderSide(
                      color: isTopMatch ? AppTheme.emerald : AppTheme.borderColor,
                      width: isTopMatch ? 1.5 : 1,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (isTopMatch)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.forestGreen,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'TOP MATCH',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            NGOVerifiedBadge(
                              isVerified: match.ngo.isVerified,
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.limeLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${match.matchScore}% Match',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.limeDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          match.ngo.organizationName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.richCharcoal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.near_me_rounded,
                                size: 14, color: AppTheme.charcoalMuted),
                            const SizedBox(width: 4),
                            Text(
                              '${match.distanceKm} km away (${match.estimatedTravelMinutes} mins travel)',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.charcoalMuted,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.soup_kitchen_rounded,
                                size: 14, color: AppTheme.charcoalMuted),
                            const SizedBox(width: 4),
                            Text(
                              '${match.ngo.capacityMealsPerDay} meals/day capacity',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.charcoalMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Why this recommendation?',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.richCharcoal,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...match.matchReasons.map((reason) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_outline_rounded,
                                    size: 14, color: AppTheme.emerald),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    reason,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.charcoalMuted,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Confirm Broadcast Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: AppTheme.subtleShadow,
                border: const Border(top: BorderSide(color: AppTheme.borderColor)),
              ),
              child: AppButton(
                label: 'Confirm Listing & Broadcast to NGOs',
                icon: Icons.cell_tower_rounded,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Donation broadcasted to ${matches.length} verified regional NGOs!'),
                      backgroundColor: AppTheme.forestGreen,
                    ),
                  );
                  onConfirmed();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
