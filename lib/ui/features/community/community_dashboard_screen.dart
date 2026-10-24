import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_button.dart';
import '../../../data/models/community_donation_model.dart';
import '../../../data/repositories/app_repository.dart';

class CommunityDashboardScreen extends StatelessWidget {
  final AppRepository repository;
  final void Function(UserRole role) onSwitchRole;
  final VoidCallback onLogout;
  final VoidCallback onNavigateToDonate;

  const CommunityDashboardScreen({
    super.key,
    required this.repository,
    required this.onSwitchRole,
    required this.onLogout,
    required this.onNavigateToDonate,
  });

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppTheme.statusCritical),
            SizedBox(width: 8),
            Text('Confirm Sign Out'),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out of your Community Giver session?',
          style: TextStyle(fontSize: 13.5),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onLogout();
            },
            child: const Text('Sign Out'),
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
        final donations = repository.communityDonations;

        return Scaffold(
          backgroundColor: AppTheme.warmIvory,
          appBar: AppBar(
            title: const Text('Community Giving Hub'),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.logout_rounded,
                  color: AppTheme.statusCritical,
                ),
                tooltip: 'Sign Out',
                onPressed: () => _showLogoutConfirmation(context),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HERO IMPACT CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0A2E20), Color(0xFF065F46)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF4EDEA3).withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.forestGreen.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.emerald.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppTheme.limeLight.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.volunteer_activism_rounded,
                                    size: 13,
                                    color: AppTheme.limeLight,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'CITIZEN RELIEF NETWORK',
                                    style: TextStyle(
                                      color: AppTheme.limeLight,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              '80G Certified',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Your Generosity Shapes Lives',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Donate spare clothes, educational books, groceries, or sponsor hot meals for underprivileged shelters with transparent impact tracking.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _buildStatItem('142', 'Items Donated'),
                            _buildStatDivider(),
                            _buildStatItem('₹48.5k', '80G Relief'),
                            _buildStatDivider(),
                            _buildStatItem('6', 'Partner Shelters'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // WHAT WOULD YOU LIKE TO DONATE TODAY?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'What would you like to donate?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.richCharcoal,
                          letterSpacing: -0.4,
                        ),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: onNavigateToDonate,
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          size: 16,
                          color: AppTheme.forestGreen,
                        ),
                        label: const Text(
                          'All Options',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.forestGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 4 QUICK CATEGORY TILES
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.35,
                    children: [
                      _buildCategoryActionCard(
                        icon: Icons.checkroom_rounded,
                        title: 'Clothes & Blankets',
                        subtitle: 'Winter wear, uniforms, blankets',
                        color: const Color(0xFF38BDF8),
                        bgColor: const Color(
                          0xFF38BDF8,
                        ).withValues(alpha: 0.15),
                        onTap: onNavigateToDonate,
                      ),
                      _buildCategoryActionCard(
                        icon: Icons.menu_book_rounded,
                        title: 'Books & Stationery',
                        subtitle: 'School textbooks & notebooks',
                        color: const Color(0xFFF59E0B),
                        bgColor: const Color(
                          0xFFF59E0B,
                        ).withValues(alpha: 0.15),
                        onTap: onNavigateToDonate,
                      ),
                      _buildCategoryActionCard(
                        icon: Icons.currency_rupee_rounded,
                        title: 'Monetary 80G Relief',
                        subtitle: 'Sponsor hot meals (Instant receipt)',
                        color: const Color(0xFF4EDEA3),
                        bgColor: const Color(
                          0xFF10B981,
                        ).withValues(alpha: 0.15),
                        onTap: onNavigateToDonate,
                      ),
                      _buildCategoryActionCard(
                        icon: Icons.inventory_2_rounded,
                        title: 'Dry Essentials',
                        subtitle: 'Rice, dal, oil & hygiene kits',
                        color: const Color(0xFFA78BFA),
                        bgColor: const Color(
                          0xFF7C3AED,
                        ).withValues(alpha: 0.15),
                        onTap: onNavigateToDonate,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ACTIVE & RECENT COMMUNITY DONATIONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Community Contributions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.richCharcoal,
                          letterSpacing: -0.4,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.emeraldLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${donations.length} Active',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.forestGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: donations.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = donations[index];
                      return _buildDonationCard(context, item);
                    },
                  ),

                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Make a New Community Donation',
                    icon: Icons.favorite_rounded,
                    onPressed: onNavigateToDonate,
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

  Widget _buildStatItem(String val, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          val,
          style: const TextStyle(
            fontSize: 20,
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

  Widget _buildStatDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: 1,
      height: 28,
      color: Colors.white24,
    );
  }

  Widget _buildCategoryActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.richCharcoal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppTheme.charcoalMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(BuildContext context, CommunityDonationModel item) {
    Color statusColor;
    IconData statusIcon;

    switch (item.status) {
      case CommunityDonationStatus.distributed:
        statusColor = AppTheme.forestGreen;
        statusIcon = Icons.check_circle_rounded;
        break;
      case CommunityDonationStatus.inTransit:
        statusColor = const Color(0xFF0284C7);
        statusIcon = Icons.local_shipping_rounded;
        break;
      case CommunityDonationStatus.matchedWithNGO:
        statusColor = const Color(0xFFD97706);
        statusIcon = Icons.handshake_rounded;
        break;
      case CommunityDonationStatus.submitted:
        statusColor = AppTheme.charcoalMuted;
        statusIcon = Icons.schedule_rounded;
        break;
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.category.label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.forestGreen,
                  ),
                ),
              ),
              const Spacer(),
              Icon(statusIcon, size: 14, color: statusColor),
              const SizedBox(width: 4),
              Text(
                item.status.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.richCharcoal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.description,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.charcoalMuted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.warmIvoryDark,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            item.isAnonymous
                                ? Icons.visibility_off_rounded
                                : Icons.person_rounded,
                            size: 13,
                            color: AppTheme.charcoalMuted,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'By ${item.displayDonorName}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.richCharcoal,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (item.assignedNgoName != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          'Beneficiary: ${item.assignedNgoName}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.forestGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardSurfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Text(
                    item.quantityOrAmount,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.richCharcoal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (item.tax80GReceiptNumber != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.verified_rounded,
                  size: 14,
                  color: AppTheme.forestGreen,
                ),
                const SizedBox(width: 6),
                Text(
                  'Tax Exemption Certificate: ${item.tax80GReceiptNumber}',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.forestGreen,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
