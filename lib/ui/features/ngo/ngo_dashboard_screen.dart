import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/state_widgets.dart';
import '../../../data/repositories/app_repository.dart';
import 'food_discovery_screen.dart';
import 'pickup_tracking_screen.dart';
import 'ngo_impact_screen.dart';
import '../../core/widgets/notification_bell_button.dart';

class NGODashboardScreen extends StatelessWidget {
  final AppRepository repository;
  final void Function(UserRole role) onSwitchRole;
  final VoidCallback? onLogout;

  const NGODashboardScreen({
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
            Text('Log Out of NGO Hub?'),
          ],
        ),
        content: const Text(
          'Are you sure you want to end your current session and return to the login screen?',
        ),
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
        final available = repository.availableDonations;
        final reserved = repository.activeReservedDonations;

        return Scaffold(
          backgroundColor: AppTheme.warmIvory,
          appBar: AppBar(
            title: const Text('NGO Rescue Hub'),
            actions: [
              IconButton(
                icon: const Icon(Icons.analytics_outlined),
                tooltip: 'NGO Rescue Analytics',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NGOImpactScreen(repository: repository),
                    ),
                  );
                },
              ),
              NotificationBellButton(repository: repository),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Sync Live Feed',
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
                    // Organization Header Card
                    AppCard(
                      backgroundColor: AppTheme.cardSurface,
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppTheme.forestGreen,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.soup_kitchen_rounded,
                              color: AppTheme.restrainedLime,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  repository.currentUser.organizationName ??
                                      'Hope Care Foundation Kitchen',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.richCharcoal,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Coordinator: ${repository.currentUser.fullName}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.charcoalMuted,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const NGOVerifiedBadge(isVerified: true),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Primary Action: Discover Surplus Food
                    AppButton(
                      label:
                          'Discover Surplus Food & Live Map (${available.length})',
                      icon: Icons.travel_explore_rounded,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FoodDiscoveryScreen(repository: repository),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // NGO Quick Metrics
                    Row(
                      children: [
                        Expanded(
                          child: _buildTile(
                            label: 'Surplus Nearby',
                            value: '${available.length}',
                            icon: Icons.near_me_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTile(
                            label: 'Active Pickups',
                            value: '${reserved.length}',
                            icon: Icons.local_shipping_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTile(
                            label: 'Daily Capacity',
                            value: '350',
                            icon: Icons.people_alt_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Active Pickups Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your Active Pickups & Commitments',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: AppTheme.richCharcoal,
                          ),
                        ),
                        Text(
                          '${reserved.length} ongoing',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.charcoalMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (reserved.isEmpty)
                      const EmptyStateWidget(
                        icon: Icons.check_circle_outline_rounded,
                        title: 'All Pickups Completed',
                        message:
                            'You do not have any pending food pickups right now. Check available food to claim fresh surplus meals.',
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reserved.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = reserved[index];
                          return AppCard(
                            border: const BorderSide(
                              color: AppTheme.emerald,
                              width: 1.5,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PickupTrackingScreen(
                                    donation: item,
                                    repository: repository,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.emeraldLight,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'RESERVED FOR YOUR KITCHEN',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.forestGreen,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    StatusBadge(status: item.status),
                                  ],
                                ),
                                const SizedBox(height: 10),
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
                                  'From: ${item.donorName} • ${item.quantityLabel}',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppTheme.charcoalMuted,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.timer_outlined,
                                      size: 14,
                                      color: AppTheme.statusCritical,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      item.formattedTimeRemaining,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.statusCritical,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Text(
                                      'Tap to track route & verify',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.forestGreen,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      size: 16,
                                      color: AppTheme.forestGreen,
                                    ),
                                  ],
                                ),
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
          ),
        );
      },
    );
  }

  Widget _buildTile({
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
