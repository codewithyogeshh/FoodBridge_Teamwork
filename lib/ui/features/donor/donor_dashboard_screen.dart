import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/state_widgets.dart';
import '../../../data/repositories/app_repository.dart';
import 'create_donation_screen.dart';
import 'active_donation_status_screen.dart';
import 'donor_impact_dashboard_screen.dart';
import '../../core/widgets/notification_bell_button.dart';
import 'sos_emergency_rescue_dialog.dart';
import 'predictive_waste_forecast_card.dart';

class DonorDashboardScreen extends StatelessWidget {
  final AppRepository repository;
  final void Function(UserRole role) onSwitchRole;
  final VoidCallback? onLogout;

  const DonorDashboardScreen({
    super.key,
    required this.repository,
    required this.onSwitchRole,
    this.onLogout,
  });

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppTheme.statusCritical),
            SizedBox(width: 10),
            Text('Log Out?'),
          ],
        ),
        content: const Text('Do you want to log out of this account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusCritical,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onLogout?.call();
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final donations = repository.donations;
        final activeListings = donations
            .where(
              (d) =>
                  d.isSafeToConsume &&
                  (d.status == DonationStatus.available ||
                      d.status == DonationStatus.reserved),
            )
            .toList();

        return Scaffold(
          backgroundColor: AppTheme.warmIvory,
          appBar: AppBar(
            title: const Text('Food Donor'),
            actions: [
              IconButton(
                icon: const Icon(Icons.analytics_outlined),
                tooltip: 'Impact Report',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DonorImpactDashboardScreen(repository: repository),
                    ),
                  );
                },
              ),
              NotificationBellButton(repository: repository),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh',
                onPressed: () => repository.refreshAllData(),
              ),
              IconButton(
                icon: const Icon(
                  Icons.logout_rounded,
                  color: AppTheme.statusCritical,
                ),
                tooltip: 'Log Out',
                onPressed: () => _confirmLogout(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => repository.refreshAllData(),
              color: AppTheme.forestGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Commercial Donor Profile Banner
                    AppCard(
                      backgroundColor: AppTheme.cardSurface,
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppTheme.emeraldLight,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.storefront_rounded,
                              color: AppTheme.forestGreen,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  repository.currentUser.fullName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.richCharcoal,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  repository.currentUser.organizationName ??
                                      'Hotel & Catering',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.charcoalMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.forestGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Quick Post Button
                    AppButton(
                      label: 'Post Extra Food',
                      icon: Icons.add_circle_outline_rounded,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateDonationScreen(
                              repository: repository,
                              onDonationCreated: (newDonation) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Food posted! Nearby NGOs can see it now.',
                                    ),
                                    backgroundColor: AppTheme.forestGreen,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Metrics Strip
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            label: 'Active Orders',
                            value: '${activeListings.length}',
                            icon: Icons.campaign_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricTile(
                            label: 'Meals Shared',
                            value: '${repository.totalMealsRescued}',
                            icon: Icons.volunteer_activism_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricTile(
                            label: 'CO₂ Saved',
                            value:
                                '${(repository.totalCo2OffsetKg / 1000).toStringAsFixed(1)}t',
                            icon: Icons.eco_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // BULK SOS RESCUE BUTTON
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        SOSEmergencyRescueDialog.show(
                          context,
                          repository: repository,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFDC2626),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.emergency_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bulk Food Alert (100–500+ Plates)',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF991B1B),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Wedding or event food left? Alert nearby 24/7 shelters.',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: Color(0xFFB91C1C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: Color(0xFFDC2626),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // PREDICTIVE WASTE FORECAST ENGINE
                    PredictiveWasteForecastCard(repository: repository),

                    const SizedBox(height: 20),

                    // Active Listings Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Active Orders',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: AppTheme.richCharcoal,
                          ),
                        ),
                        Text(
                          '${activeListings.length} active',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.charcoalMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (activeListings.isEmpty)
                      const EmptyStateWidget(
                        icon: Icons.inventory_2_outlined,
                        title: 'No Active Orders',
                        message: 'Tap "Post Extra Food" above to add new food.',
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: activeListings.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = activeListings[index];
                          return AppCard(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ActiveDonationStatusScreen(
                                        donation: item,
                                      ),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    UrgencyBadge(
                                      level: item.urgencyLevel,
                                      compact: true,
                                    ),
                                    const Spacer(),
                                    StatusBadge(status: item.status),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (item.imageUrl != null &&
                                        item.imageUrl!.isNotEmpty) ...[
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          item.imageUrl!,
                                          width: 72,
                                          height: 72,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (
                                                context,
                                                error,
                                                stackTrace,
                                              ) => Container(
                                                width: 72,
                                                height: 72,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.emeraldLight,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Icon(
                                                  Icons.fastfood_rounded,
                                                  color: AppTheme.forestGreen,
                                                  size: 28,
                                                ),
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: AppTheme.richCharcoal,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${item.foodType} • ${item.quantityLabel}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.charcoalMuted,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.warmIvoryDark,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.timer_outlined,
                                        size: 14,
                                        color: AppTheme.forestGreen,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        item.formattedTimeRemaining,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.richCharcoal,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Text(
                                        'Pickup PIN: ',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.charcoalMuted,
                                        ),
                                      ),
                                      Text(
                                        item.pickupOtp,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.forestGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
          ),
        );
      },
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.forestGreen),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppTheme.richCharcoal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.charcoalMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
