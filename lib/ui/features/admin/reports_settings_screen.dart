import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../../data/repositories/app_repository.dart';

class ReportsSettingsScreen extends StatefulWidget {
  final AppRepository repository;

  const ReportsSettingsScreen({super.key, required this.repository});

  @override
  State<ReportsSettingsScreen> createState() => _ReportsSettingsScreenState();
}

class _ReportsSettingsScreenState extends State<ReportsSettingsScreen> {
  bool _enforceFSSAI = true;
  bool _autoNotifyNearby = true;
  final int _reservationExpiryMinutes = 180;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmIvory,
      appBar: AppBar(title: const Text('Reports & Settings')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Download Reports',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: AppTheme.richCharcoal,
                ),
              ),
              const SizedBox(height: 12),

              // Export Card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Food Shared & Impact Report',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.richCharcoal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Download records of shared meals, CO2 saved, and NGO receipts.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.charcoalMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Export CSV',
                            icon: Icons.table_view_rounded,
                            variant: AppButtonVariant.outline,
                            height: 42,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'FoodBridge_Impact_Report_2026.csv downloaded!',
                                  ),
                                  backgroundColor: AppTheme.forestGreen,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            label: 'Export PDF',
                            icon: Icons.picture_as_pdf_rounded,
                            variant: AppButtonVariant.primary,
                            height: 42,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'FoodBridge_Impact_Report_2026.pdf downloaded!',
                                  ),
                                  backgroundColor: AppTheme.forestGreen,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Platform Parameters Card
              const Text(
                'App Rules',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: AppTheme.richCharcoal,
                ),
              ),
              const SizedBox(height: 12),

              AppCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: AppTheme.forestGreen,
                      title: const Text(
                        'Require Food License (FSSAI)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.richCharcoal,
                        ),
                      ),
                      subtitle: const Text(
                        'Only verified NGOs can book cooked food.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.charcoalMuted,
                        ),
                      ),
                      value: _enforceFSSAI,
                      onChanged: (val) => setState(() => _enforceFSSAI = val),
                    ),
                    const Divider(color: AppTheme.borderColor),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: AppTheme.forestGreen,
                      title: const Text(
                        'Auto-Alert Nearby NGOs',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.richCharcoal,
                        ),
                      ),
                      subtitle: const Text(
                        'Notify NGOs within 5 km when urgent food (< 3h) is posted.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.charcoalMuted,
                        ),
                      ),
                      value: _autoNotifyNearby,
                      onChanged: (val) =>
                          setState(() => _autoNotifyNearby = val),
                    ),
                    const Divider(color: AppTheme.borderColor),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Booking Hold Time:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.richCharcoal,
                          ),
                        ),
                        Text(
                          '$_reservationExpiryMinutes mins',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.forestGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Connected Backend Info Card
              AppCard(
                backgroundColor: AppTheme.cardSurface,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppTheme.emeraldLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_done_rounded,
                        color: AppTheme.forestGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Supabase Cloud Connected',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.forestGreen,
                            ),
                          ),
                          Text(
                            AppConstants.supabaseUrl,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.charcoalMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.emerald,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
