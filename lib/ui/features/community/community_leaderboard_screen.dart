import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../../data/repositories/app_repository.dart';

class CommunityLeaderboardScreen extends StatefulWidget {
  final AppRepository repository;

  const CommunityLeaderboardScreen({super.key, required this.repository});

  @override
  State<CommunityLeaderboardScreen> createState() =>
      _CommunityLeaderboardScreenState();
}

class _CommunityLeaderboardScreenState extends State<CommunityLeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isMonthly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmIvory,
      appBar: AppBar(
        title: const Text('Community Heroes Leaderboard'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.forestGreen,
          unselectedLabelColor: AppTheme.charcoalMuted,
          indicatorColor: AppTheme.forestGreen,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: const [
            Tab(text: 'Top Donors', icon: Icon(Icons.storefront_rounded, size: 20)),
            Tab(
              text: 'Hero Couriers',
              icon: Icon(Icons.delivery_dining_rounded, size: 20),
            ),
            Tab(
              text: 'Relief Kitchens',
              icon: Icon(Icons.soup_kitchen_rounded, size: 20),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // TIME HORIZON TOGGLE & STAT BANNER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rankings & Verified Impact',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.richCharcoal,
                    ),
                  ),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('All Time', style: TextStyle(fontSize: 11)),
                        selected: !_isMonthly,
                        selectedColor: AppTheme.emeraldLight,
                        onSelected: (val) => setState(() => _isMonthly = false),
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('This Month', style: TextStyle(fontSize: 11)),
                        selected: _isMonthly,
                        selectedColor: AppTheme.emeraldLight,
                        onSelected: (val) => setState(() => _isMonthly = true),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // TAB CONTENT
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDonorsTab(),
                  _buildCouriersTab(),
                  _buildKitchensTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonorsTab() {
    final donors = [
      {
        'rank': 1,
        'name': 'Grand Orchid Banquet & Convention',
        'type': 'Banquet & Caterer',
        'score': _isMonthly ? '340 Meals' : '1,250 Meals',
        'co2': _isMonthly ? '382 kg CO₂' : '1,406 kg CO₂',
        'badge': 'Zero Waste Champion',
      },
      {
        'rank': 2,
        'name': 'Spice Garden Fine Dine Restaurant',
        'type': 'Restaurant Partner',
        'score': _isMonthly ? '210 Meals' : '820 Meals',
        'co2': _isMonthly ? '236 kg CO₂' : '922 kg CO₂',
        'badge': 'Gold Donor',
      },
      {
        'rank': 3,
        'name': 'FreshHarvest Agro Mart',
        'type': 'Wholesale Produce',
        'score': _isMonthly ? '180 kg' : '650 kg Produce',
        'co2': _isMonthly ? '190 kg CO₂' : '690 kg CO₂',
        'badge': 'Fresh Produce Hero',
      },
      {
        'rank': 4,
        'name': 'The Royal Treat Confectionery',
        'type': 'Bakery & Patisserie',
        'score': _isMonthly ? '95 Boxes' : '410 Boxes',
        'co2': _isMonthly ? '106 kg CO₂' : '460 kg CO₂',
        'badge': 'Perishable Saver',
      },
      {
        'rank': 5,
        'name': 'Dr. Ananya Roy & Community Circle',
        'type': 'Community Individual',
        'score': _isMonthly ? '48 Kits' : '180 Aid Kits',
        'co2': 'Social Care',
        'badge': 'Kindness Star',
      },
    ];

    return _buildLeaderboardView(
      items: donors,
      podiumTitle: 'Top Food Rescuers',
      scoreLabel: 'Meals Rescued',
    );
  }

  Widget _buildCouriersTab() {
    final couriers = [
      {
        'rank': 1,
        'name': 'Ramesh Rider',
        'type': 'Electric Scooter',
        'score': _isMonthly ? '28 Trips' : '94 Deliveries',
        'co2': 'Avg. 22 min',
        'badge': 'Lightning Courier',
      },
      {
        'rank': 2,
        'name': 'Pooja Patil',
        'type': 'Motorcycle',
        'score': _isMonthly ? '22 Trips' : '76 Deliveries',
        'co2': 'Avg. 25 min',
        'badge': 'Rapid Responder',
      },
      {
        'rank': 3,
        'name': 'Sameer Khan',
        'type': 'Bicycle',
        'score': _isMonthly ? '18 Trips' : '58 Deliveries',
        'co2': 'Avg. 29 min',
        'badge': 'Eco Hero',
      },
      {
        'rank': 4,
        'name': 'Arun Verma',
        'type': 'Compact Car',
        'score': _isMonthly ? '12 Trips' : '42 Deliveries',
        'co2': 'Bulk Dispatch',
        'badge': 'Heavy Courier',
      },
    ];

    return _buildLeaderboardView(
      items: couriers,
      podiumTitle: 'Hero Couriers',
      scoreLabel: 'Deliveries Completed',
    );
  }

  Widget _buildKitchensTab() {
    final kitchens = [
      {
        'rank': 1,
        'name': 'Hope Care Foundation Kitchen',
        'type': 'Verified Shelter Kitchen',
        'score': _isMonthly ? '520 Portions' : '2,100 Portions',
        'co2': '100% Safe Intake',
        'badge': 'FSSAI Certified',
      },
      {
        'rank': 2,
        'name': 'Annam Child & Elder Relief Trust',
        'type': 'Registered Charity Trust',
        'score': _isMonthly ? '410 Portions' : '1,680 Portions',
        'co2': 'Cold Chain Verified',
        'badge': 'Master Distributor',
      },
      {
        'rank': 3,
        'name': 'Akshaya Seva Community Kitchen',
        'type': 'Community Food Pantry',
        'score': _isMonthly ? '290 Portions' : '1,120 Portions',
        'co2': 'Rapid Turnaround',
        'badge': 'Community Lifeline',
      },
    ];

    return _buildLeaderboardView(
      items: kitchens,
      podiumTitle: 'Top Relief Kitchens',
      scoreLabel: 'Servings Distributed',
    );
  }

  Widget _buildLeaderboardView({
    required List<Map<String, dynamic>> items,
    required String podiumTitle,
    required String scoreLabel,
  }) {
    final top3 = items.take(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP 3 PODIUM
          if (top3.length >= 3) _buildPodium(top3),

          const SizedBox(height: 20),

          // BADGES SHOWCASE
          _buildBadgesBanner(),

          const SizedBox(height: 20),

          // REMAINING LEADERBOARD RANKS
          const Text(
            'Complete Community Rankings',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: AppTheme.richCharcoal,
            ),
          ),
          const SizedBox(height: 10),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final item = items[i];
              final rank = item['rank'] as int;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: rank <= 3
                        ? AppTheme.forestGreen.withValues(alpha: 0.3)
                        : AppTheme.borderColor,
                  ),
                  boxShadow: AppTheme.subtleShadow,
                ),
                child: Row(
                  children: [
                    // RANK BADGE
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getRankColor(rank).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$rank',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: _getRankColor(rank),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // DETAILS
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.richCharcoal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                item['type'] as String,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: AppTheme.charcoalMuted,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: const BoxDecoration(
                                  color: AppTheme.charcoalLight,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item['badge'] as String,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.forestGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // SCORE
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item['score'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.richCharcoal,
                          ),
                        ),
                        Text(
                          item['co2'] as String,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.charcoalMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // INCENTIVE BANNER
          AppCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: AppTheme.forestGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unlock Monthly Hero Recognition',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.richCharcoal,
                        ),
                      ),
                      Text(
                        'Top 3 donors and couriers receive official CSR and sustainability badges displayed on city relief directories.',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: AppTheme.charcoalMuted,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(List<Map<String, dynamic>> top3) {
    final rank1 = top3[0];
    final rank2 = top3[1];
    final rank3 = top3[2];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F392B), Color(0xFF1E5B45)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F392B).withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events_rounded, color: Color(0xFFFBBF24), size: 20),
              SizedBox(width: 6),
              Text(
                'COMMUNITY HEROES PODIUM',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: Color(0xFFFDE68A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 2ND PLACE
              _podiumColumn(rank2, 2, 85, const Color(0xFF94A3B8)),

              // 1ST PLACE (CENTER ELEVATED)
              _podiumColumn(rank1, 1, 110, const Color(0xFFFBBF24)),

              // 3RD PLACE
              _podiumColumn(rank3, 3, 70, const Color(0xFFD97706)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _podiumColumn(
    Map<String, dynamic> item,
    int rank,
    double height,
    Color color,
  ) {
    return Column(
      children: [
        // CROWN / MEDAL
        if (rank == 1)
          const Icon(Icons.military_tech_rounded, color: Color(0xFFFBBF24), size: 26)
        else
          Icon(
            rank == 2 ? Icons.looks_two_rounded : Icons.looks_3_rounded,
            color: color,
            size: 20,
          ),
        const SizedBox(height: 4),

        // NAME
        SizedBox(
          width: 85,
          child: Text(
            (item['name'] as String).split(' ').first,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          item['score'] as String,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 6),

        // PODIUM BLOCK
        Container(
          width: 75,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                rank == 1 ? 'GOLD' : rank == 2 ? 'SILVER' : 'BRONZE',
                style: const TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadgesBanner() {
    final badges = [
      {'title': 'Zero Waste', 'icon': Icons.eco_rounded, 'color': AppTheme.forestGreen},
      {'title': 'Lightning', 'icon': Icons.flash_on_rounded, 'color': const Color(0xFFD97706)},
      {'title': 'FSSAI Safe', 'icon': Icons.security_rounded, 'color': const Color(0xFF0284C7)},
      {'title': '80G Star', 'icon': Icons.volunteer_activism_rounded, 'color': const Color(0xFF9333EA)},
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: badges.map((b) {
          final color = b['color'] as Color;
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(b['icon'] as IconData, color: color, size: 20),
              ),
              const SizedBox(height: 4),
              Text(
                b['title'] as String,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.richCharcoal,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFD97706);
      case 2:
        return const Color(0xFF64748B);
      case 3:
        return const Color(0xFFB45309);
      default:
        return AppTheme.forestGreen;
    }
  }
}
