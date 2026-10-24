import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/widgets/app_card.dart';
import '../../../data/repositories/app_repository.dart';
import 'ngo_verification_queue_screen.dart';
import 'donation_management_screen.dart';
import 'delivery_monitoring_screen.dart';
import 'reports_settings_screen.dart';
import '../ai_allocation/ai_allocation_screen.dart';
import '../../core/widgets/notification_bell_button.dart';

class AdminDashboardScreen extends StatelessWidget {
  final AppRepository repository;
  final void Function(UserRole role) onSwitchRole;
  final VoidCallback? onLogout;

  const AdminDashboardScreen({
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
            Text('Exit Admin Operations?'),
          ],
        ),
        content: const Text(
          'Are you sure you want to end your administrative session and return to the login screen?',
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
        final pendingCount = repository.pendingNGOs.length;
        final totalNgos = repository.ngos.length;
        final totalDonations = repository.donations.length;
        final totalMeals = repository.totalMealsRescued;

        return Scaffold(
          backgroundColor: AppTheme.warmIvory,
          appBar: AppBar(
            title: const Text('Admin Operations & Audit'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'System Settings',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ReportsSettingsScreen(repository: repository),
                    ),
                  );
                },
              ),
              NotificationBellButton(repository: repository),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh Platform Metrics',
                onPressed: () => repository.refreshAllData(),
              ),
              IconButton(
                icon: const Icon(
                  Icons.logout_rounded,
                  color: AppTheme.statusCritical,
                ),
                tooltip: 'Log Out of Admin Operations',
                onPressed: () => _confirmLogout(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Operations Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F2B20), Color(0xFF064E3B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF4EDEA3).withValues(alpha: 0.35),
                      ),
                      boxShadow: AppTheme.cardElevation,
                    ),
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
                                color: AppTheme.restrainedLime,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'CENTRAL OPERATIONS COMMAND',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.forestGreen,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.security_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'FoodBridge Network Operations',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Supervising regional food allocations, food safety chain-of-custody, and NGO compliance.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white70,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Platform KPIs Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildKpiCard(
                          label: 'Rescued Meals',
                          value: '$totalMeals',
                          icon: Icons.soup_kitchen_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildKpiCard(
                          label: 'Partner NGOs',
                          value: '$totalNgos',
                          icon: Icons.volunteer_activism_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildKpiCard(
                          label: 'Active Donations',
                          value: '$totalDonations',
                          icon: Icons.fastfood_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildKpiCard(
                          label: 'CO2e Diverted',
                          value:
                              '${(repository.totalCo2OffsetKg / 1000).toStringAsFixed(1)} Tons',
                          icon: Icons.eco_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Navigation Modules
                  const Text(
                    'Administrative Workflows',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: AppTheme.richCharcoal,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // NGO Verification Queue Card
                  _buildNavCard(
                    title: 'NGO Verification Queue',
                    subtitle: pendingCount > 0
                        ? '$pendingCount organization application(s) awaiting audit'
                        : 'All regional NGOs verified and licensed',
                    icon: Icons.verified_user_rounded,
                    badgeCount: pendingCount,
                    isAlert: pendingCount > 0,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NGOVerificationQueueScreen(
                            repository: repository,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Signature AI Experience Launcher
                  _buildNavCard(
                    title: 'Signature AI Food Allocation Engine',
                    subtitle:
                        'Neural demand optimization, decay simulation & smart routing',
                    icon: Icons.auto_awesome_rounded,
                    badgeText: 'CORE AI FEATURE',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AIAllocationScreen(repository: repository),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Donation Batch Moderation
                  _buildNavCard(
                    title: 'Donation Batch Moderation',
                    subtitle:
                        'Inspect and manage all $totalDonations active food batches',
                    icon: Icons.inventory_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DonationManagementScreen(repository: repository),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Live Delivery Monitoring
                  _buildNavCard(
                    title: 'Live Delivery & Transit Map',
                    subtitle:
                        'Monitor active couriers, ETAs, and handoff passcodes',
                    icon: Icons.map_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DeliveryMonitoringScreen(repository: repository),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Reports and Settings
                  _buildNavCard(
                    title: 'Environmental Audit & Platform Settings',
                    subtitle:
                        'Export CSV audit trail and tune safety threshold rules',
                    icon: Icons.tune_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ReportsSettingsScreen(repository: repository),
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

  Widget _buildKpiCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppTheme.forestGreen),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppTheme.richCharcoal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.charcoalMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavCard({
    required String title,
    required String subtitle,
    required IconData icon,
    int? badgeCount,
    String? badgeText,
    bool isAlert = false,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isAlert ? const Color(0xFFFEF3C7) : AppTheme.warmIvoryDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isAlert ? const Color(0xFFD97706) : AppTheme.forestGreen,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.richCharcoal,
                        ),
                      ),
                    ),
                    if (badgeCount != null && badgeCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.statusCritical,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$badgeCount PENDING',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    if (badgeText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.emeraldLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.forestGreen,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.charcoalMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.charcoalLight,
          ),
        ],
      ),
    );
  }
}
