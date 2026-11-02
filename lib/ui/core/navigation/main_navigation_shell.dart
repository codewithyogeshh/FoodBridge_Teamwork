import 'package:flutter/material.dart';
import '../theme.dart';
import '../constants.dart';
import '../../../data/models/ngo_model.dart';
import '../../../data/repositories/app_repository.dart';
import '../../features/donor/donor_dashboard_screen.dart';
import '../../features/donor/create_donation_screen.dart';
import '../../features/donor/donor_impact_dashboard_screen.dart';
import '../../features/community/community_dashboard_screen.dart';
import '../../features/community/create_community_donation_screen.dart';
import '../../features/community/community_impact_ledger_screen.dart';
import '../../features/ngo/ngo_dashboard_screen.dart';
import '../../features/ngo/food_discovery_screen.dart';
import '../../features/ngo/ngo_impact_screen.dart';
import '../../features/admin/admin_dashboard_screen.dart';
import '../../features/admin/ngo_verification_queue_screen.dart';
import '../../features/admin/delivery_monitoring_screen.dart';
import '../../features/ai_allocation/ai_allocation_screen.dart';
import '../../features/auth/verification_status_screen.dart';
import '../../features/volunteer/volunteer_dashboard_screen.dart';
import '../../features/analytics/esg_impact_dashboard.dart';
import '../../features/community/community_leaderboard_screen.dart';
import '../../features/admin/supabase_console_screen.dart';
import '../../features/admin/reports_settings_screen.dart';
import '../../features/logistics/whatsapp_dispatch_dialog.dart';

class MainNavigationShell extends StatefulWidget {
  final AppRepository repository;
  final NGOModel? lastRegisteredNgo;
  final void Function(UserRole role) onChangeRole;
  final VoidCallback onResetOnboarding;
  final VoidCallback onLogout;

  const MainNavigationShell({
    super.key,
    required this.repository,
    this.lastRegisteredNgo,
    required this.onChangeRole,
    required this.onResetOnboarding,
    required this.onLogout,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repository,
      builder: (context, _) {
        final role = widget.repository.currentRole;

        Widget body;
        List<BottomNavigationBarItem> navItems;

        if (role == UserRole.donor) {
          navItems = const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline_rounded),
              label: 'Post Food',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_rounded),
              label: 'AI Allocation',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              label: 'Impact Ledger',
            ),
          ];

          switch (_currentNavIndex) {
            case 0:
              body = DonorDashboardScreen(
                repository: widget.repository,
                onSwitchRole: widget.onChangeRole,
                onLogout: widget.onLogout,
              );
              break;
            case 1:
              body = CreateDonationScreen(
                repository: widget.repository,
                onDonationCreated: (d) {
                  setState(() => _currentNavIndex = 0);
                },
              );
              break;
            case 2:
              body = AIAllocationScreen(repository: widget.repository);
              break;
            case 3:
            default:
              body = DonorImpactDashboardScreen(repository: widget.repository);
              break;
          }
        } else if (role == UserRole.community) {
          navItems = const [
            BottomNavigationBarItem(
              icon: Icon(Icons.volunteer_activism_rounded),
              label: 'Giving Hub',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_rounded),
              label: 'Donate Now',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: 'Impact & 80G',
            ),
          ];

          switch (_currentNavIndex) {
            case 0:
              body = CommunityDashboardScreen(
                repository: widget.repository,
                onSwitchRole: widget.onChangeRole,
                onLogout: widget.onLogout,
                onNavigateToDonate: () => setState(() => _currentNavIndex = 1),
              );
              break;
            case 1:
              body = CreateCommunityDonationScreen(
                repository: widget.repository,
                onDonationSubmitted: (d) {
                  setState(() => _currentNavIndex = 0);
                },
              );
              break;
            case 2:
            default:
              body = CommunityImpactLedgerScreen(repository: widget.repository);
              break;
          }
        } else if (role == UserRole.ngo) {
          // STRICT GATEKEEPING: Check if active NGO is verified
          final activeNgo = widget.lastRegisteredNgo != null
              ? widget.repository.ngos.firstWhere(
                  (n) => n.id == widget.lastRegisteredNgo!.id,
                  orElse: () => widget.lastRegisteredNgo!,
                )
              : widget.repository.ngos.first;

          if (!activeNgo.isVerified) {
            // Unverified NGO cannot access food rescue listings
            return Scaffold(
              drawer: _buildRoleSwitcherDrawer(),
              body: VerificationStatusScreen(
                ngo: activeNgo,
                repository: widget.repository,
                onEnterDashboard: () {
                  setState(() {});
                },
              ),
            );
          }

          navItems = const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Rescue Hub',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.travel_explore_rounded),
              label: 'Discover Food',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_rounded),
              label: 'AI Matching',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              label: 'Analytics',
            ),
          ];

          switch (_currentNavIndex) {
            case 0:
              body = NGODashboardScreen(
                repository: widget.repository,
                onSwitchRole: widget.onChangeRole,
                onLogout: widget.onLogout,
              );
              break;
            case 1:
              body = FoodDiscoveryScreen(repository: widget.repository);
              break;
            case 2:
              body = AIAllocationScreen(repository: widget.repository);
              break;
            case 3:
            default:
              body = NGOImpactScreen(repository: widget.repository);
              break;
          }
        } else if (role == UserRole.volunteer) {
          return Scaffold(
            drawer: _buildRoleSwitcherDrawer(),
            body: VolunteerDashboardScreen(
              repository: widget.repository,
              onSwitchRole: widget.onChangeRole,
              onLogout: widget.onLogout,
            ),
          );
        } else {
          // Admin Role
          navItems = const [
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_rounded),
              label: 'Admin Desk',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.verified_user_rounded),
              label: 'NGO Queue',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_rounded),
              label: 'Live Deliveries',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_rounded),
              label: 'AI Engine',
            ),
          ];

          switch (_currentNavIndex) {
            case 0:
              body = AdminDashboardScreen(
                repository: widget.repository,
                onSwitchRole: widget.onChangeRole,
                onLogout: widget.onLogout,
              );
              break;
            case 1:
              body = NGOVerificationQueueScreen(repository: widget.repository);
              break;
            case 2:
              body = DeliveryMonitoringScreen(repository: widget.repository);
              break;
            case 3:
            default:
              body = AIAllocationScreen(repository: widget.repository);
              break;
          }
        }

        return Scaffold(
          drawer: _buildRoleSwitcherDrawer(),
          body: body,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentNavIndex.clamp(0, navItems.length - 1),
            items: navItems,
            onTap: (index) {
              setState(() => _currentNavIndex = index);
            },
          ),
        );
      },
    );
  }

  Widget _buildRoleSwitcherDrawer() {
    final currentRole = widget.repository.currentRole;

    return Drawer(
      backgroundColor: AppTheme.warmIvory,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MODERN HEADER WITH APP LOGO & BRANDING
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.forestGreen, Color(0xFF047857)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => const Icon(
                          Icons.eco_rounded,
                          color: AppTheme.forestGreen,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      AppConstants.appName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ACTIVE: ${currentRole.name.toUpperCase()}',
                        style: const TextStyle(
                          color: AppTheme.limeLight,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ROLE SWITCHER
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 6),
                child: Text(
                  'SWITCH ACTIVE ROLE (DEMO & TESTING)',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.charcoalMuted,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.storefront_rounded,
                  color: AppTheme.forestGreen,
                ),
                title: const Text('Food Donor (Grand Orchid Banquet)'),
                selected: currentRole == UserRole.donor,
                selectedTileColor: AppTheme.emeraldLight,
                onTap: () {
                  Navigator.pop(context);
                  widget.onChangeRole(UserRole.donor);
                  setState(() => _currentNavIndex = 0);
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.card_giftcard_rounded,
                  color: Color(0xFF0284C7),
                ),
                title: const Text(
                  'Community Giver (Clothes, Books, 80G Funds)',
                ),
                selected: currentRole == UserRole.community,
                selectedTileColor: AppTheme.emeraldLight,
                onTap: () {
                  Navigator.pop(context);
                  widget.onChangeRole(UserRole.community);
                  setState(() => _currentNavIndex = 0);
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.soup_kitchen_rounded,
                  color: AppTheme.forestGreen,
                ),
                title: const Text('NGO Rescuer (Hope Care Foundation)'),
                selected: currentRole == UserRole.ngo,
                selectedTileColor: AppTheme.emeraldLight,
                onTap: () {
                  Navigator.pop(context);
                  widget.onChangeRole(UserRole.ngo);
                  setState(() => _currentNavIndex = 0);
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.delivery_dining_rounded,
                  color: Color(0xFFEA580C),
                ),
                title: const Text('Volunteer Courier (₹20-₹30 / Trip)'),
                selected: currentRole == UserRole.volunteer,
                selectedTileColor: AppTheme.emeraldLight,
                onTap: () {
                  Navigator.pop(context);
                  widget.onChangeRole(UserRole.volunteer);
                  setState(() => _currentNavIndex = 0);
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.security_rounded,
                  color: AppTheme.forestGreen,
                ),
                title: const Text('Platform Administrator'),
                selected: currentRole == UserRole.admin,
                selectedTileColor: AppTheme.emeraldLight,
                onTap: () {
                  Navigator.pop(context);
                  widget.onChangeRole(UserRole.admin);
                  setState(() => _currentNavIndex = 0);
                },
              ),

              const Divider(height: 24),

              // NEW PRODUCTION FEATURES: IMPACT & TRANSPARENCY
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 6),
                child: Text(
                  'IMPACT & ADVANCED REPORTING',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.charcoalMuted,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.eco_rounded,
                  color: AppTheme.forestGreen,
                ),
                title: const Text(
                  'ESG Carbon & Impact Hub',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text(
                  'Verified CO2, Water & CSR Audit Certificate',
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => ESGImpactDashboardScreen(
                        repository: widget.repository,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFFD97706),
                ),
                title: const Text(
                  'Community Impact Leaderboard',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text('Top Donors, Couriers & Rescue Kitchens'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => CommunityLeaderboardScreen(
                        repository: widget.repository,
                      ),
                    ),
                  );
                },
              ),

              const Divider(height: 24),

              // SYSTEM & BACKEND
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 6),
                child: Text(
                  'BACKEND & SYSTEM OPERATIONS',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.charcoalMuted,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.terminal_rounded,
                  color: Color(0xFF0284C7),
                ),
                title: const Text(
                  'Supabase Real-Time Console',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text(
                  'PostgreSQL health, WS ping & Concurrency RPC',
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) =>
                          SupabaseConsoleScreen(repository: widget.repository),
                    ),
                  );
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.chat_rounded,
                  color: Color(0xFF16A34A),
                ),
                title: const Text(
                  'WhatsApp & SMS Dispatch Bot',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text(
                  'Real-time courier alerts & WhatsApp webhooks',
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                onTap: () {
                  Navigator.pop(context);
                  WhatsAppDispatchDialog.show(context);
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.tune_rounded,
                  color: AppTheme.charcoalMuted,
                ),
                title: const Text('Reports & System Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) =>
                          ReportsSettingsScreen(repository: widget.repository),
                    ),
                  );
                },
              ),

              const Divider(height: 24),

              // SESSION MANAGEMENT
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.replay_rounded,
                  color: AppTheme.charcoalMuted,
                ),
                title: const Text('Restart Welcome & Onboarding'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onResetOnboarding();
                },
              ),
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.logout_rounded,
                  color: AppTheme.statusCritical,
                ),
                title: const Text(
                  'Log Out of FoodBridge',
                  style: TextStyle(
                    color: AppTheme.statusCritical,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onLogout();
                },
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  ' • \nSupabase PostgreSQL + Real-Time OTP & Verification Gate',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.charcoalLight,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
