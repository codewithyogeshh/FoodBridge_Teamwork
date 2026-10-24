import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_badge.dart';
import '../../../data/repositories/app_repository.dart';

class NGOImpactScreen extends StatelessWidget {
  final AppRepository repository;

  const NGOImpactScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final completed = repository.completedDonations;

        return Scaffold(
          backgroundColor: AppTheme.warmIvory,
          appBar: AppBar(title: const Text('NGO Rescue Analytics')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppTheme.forestGreen,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.cardElevation,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NGO FOOD RESCUE FOOTPRINT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.restrainedLime,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '4,920',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Community Portions Rescued & Served',
                          style: TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                        const SizedBox(height: 18),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildHeroStat('12.3 Tons', 'CO2e Diverted'),
                            _buildHeroStat('184 Hours', 'Transit Vol. Log'),
                            _buildHeroStat('100%', 'Safe Handoff Rate'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Beneficiary Demographics
                  const Text(
                    'Beneficiary Distribution Breakdown',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.richCharcoal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      children: [
                        _buildDemographicBar(
                          label: 'Orphanages & Children Shelters',
                          percentage: 0.45,
                          count: '2,214 meals (45%)',
                          color: AppTheme.forestGreen,
                        ),
                        const SizedBox(height: 14),
                        _buildDemographicBar(
                          label: 'Night Shelters & Community Diners',
                          percentage: 0.35,
                          count: '1,722 meals (35%)',
                          color: AppTheme.emerald,
                        ),
                        const SizedBox(height: 14),
                        _buildDemographicBar(
                          label: 'Senior Care & Day Centers',
                          percentage: 0.20,
                          count: '984 meals (20%)',
                          color: AppTheme.restrainedLime,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Rescued Batches List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Verified Rescues Ledger',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.richCharcoal,
                        ),
                      ),
                      Text(
                        '${completed.length} batches',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.charcoalMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: completed.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = completed[index];
                      return AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.emeraldLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.task_alt_rounded,
                                color: AppTheme.forestGreen,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.richCharcoal,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.donorName} • ${item.quantityLabel}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.charcoalMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            StatusBadge(status: item.status),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroStat(String val, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          val,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildDemographicBar({
    required String label,
    required double percentage,
    required String count,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.richCharcoal,
              ),
            ),
            Text(
              count,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.charcoalMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: AppTheme.warmIvoryDark,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
