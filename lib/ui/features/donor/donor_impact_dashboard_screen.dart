import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_badge.dart';
import '../../../data/repositories/app_repository.dart';

class DonorImpactDashboardScreen extends StatelessWidget {
  final AppRepository repository;

  const DonorImpactDashboardScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final meals = repository.totalMealsRescued;
        final co2 = (repository.totalCo2OffsetKg).toStringAsFixed(1);
        final water = (repository.totalWaterConservedL / 1000).toStringAsFixed(1);
        final donations = repository.donations;

        return Scaffold(
          backgroundColor: AppTheme.warmIvory,
          appBar: AppBar(
            title: const Text('Impact & Environmental Ledger'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Fintech Card
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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.emerald,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'VERIFIED IMPACT LEDGER',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.verified_rounded,
                              color: AppTheme.restrainedLime,
                              size: 18,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          '$meals',
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Total Meals Rescued & Redistributed',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildHeroMetric(
                              label: 'CO2e Offset',
                              value: '$co2 kg',
                              icon: Icons.cloud_done_rounded,
                            ),
                            _buildHeroMetric(
                              label: 'Water Conserved',
                              value: '$water kL',
                              icon: Icons.water_drop_rounded,
                            ),
                            _buildHeroMetric(
                              label: 'Active NGOs',
                              value: '${repository.verifiedNGOs.length}',
                              icon: Icons.handshake_rounded,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Monthly Trend Visualizer
                  const Text(
                    'Monthly Surplus Reduction Trajectory',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: AppTheme.richCharcoal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Meals Diverted from Landfills',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.richCharcoal,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.emeraldLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '+32.4% vs last month',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.forestGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Bar Histogram
                        SizedBox(
                          height: 120,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildBar('May', 0.45, '450'),
                              _buildBar('Jun', 0.60, '680'),
                              _buildBar('Jul', 0.55, '610'),
                              _buildBar('Aug', 0.80, '940'),
                              _buildBar('Sep', 0.72, '890'),
                              _buildBar('Oct', 0.95, '1,280', isHighlight: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Chronological History List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Donation History Log',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: AppTheme.richCharcoal,
                        ),
                      ),
                      Text(
                        '${donations.length} records',
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
                    itemCount: donations.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = donations[index];
                      return AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.warmIvoryDark,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.restaurant_rounded,
                                color: AppTheme.forestGreen,
                                size: 22,
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
                                    '${item.foodType} • ${item.quantityLabel}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.charcoalMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusBadge(status: item.status),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroMetric({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppTheme.restrainedLime),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBar(String month, double pct, String value,
      {bool isHighlight = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: isHighlight ? AppTheme.forestGreen : AppTheme.charcoalLight,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 28,
          height: 70 * pct,
          decoration: BoxDecoration(
            color: isHighlight ? AppTheme.forestGreen : AppTheme.emeraldLight,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          month,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
            color: isHighlight ? AppTheme.richCharcoal : AppTheme.charcoalMuted,
          ),
        ),
      ],
    );
  }
}
