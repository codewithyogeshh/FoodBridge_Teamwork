import 'package:flutter/material.dart';
import 'ui/core/theme.dart';
import 'ui/core/constants.dart';
import 'ui/core/widgets/terms_dialog.dart';
import 'data/repositories/app_repository.dart';
import 'data/models/ngo_model.dart';
import 'ui/features/auth/splash_screen.dart';
import 'ui/features/auth/onboarding_screen.dart';
import 'ui/features/auth/role_selection_screen.dart';
import 'ui/features/auth/donor_otp_screen.dart';
import 'ui/features/auth/secure_auth_screen.dart';
import 'ui/features/auth/ngo_register_screen.dart';
import 'ui/features/auth/verification_status_screen.dart';
import 'ui/features/donor/donor_dashboard_screen.dart';
import 'ui/features/donor/create_donation_screen.dart';
import 'ui/features/donor/donor_impact_dashboard_screen.dart';
import 'ui/features/community/community_dashboard_screen.dart';
import 'ui/features/community/create_community_donation_screen.dart';
import 'ui/features/community/community_impact_ledger_screen.dart';
import 'ui/features/ngo/ngo_dashboard_screen.dart';
import 'ui/features/ngo/food_discovery_screen.dart';
import 'ui/features/ngo/ngo_impact_screen.dart';
import 'ui/features/admin/admin_dashboard_screen.dart';
import 'ui/features/admin/ngo_verification_queue_screen.dart';
import 'ui/features/admin/delivery_monitoring_screen.dart';
import 'ui/features/ai_allocation/ai_allocation_screen.dart';
import 'ui/core/widgets/notification_banner_overlay.dart';
import 'ui/core/widgets/notification_center_sheet.dart';
import 'ui/features/ngo/donation_details_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = AppRepository();
  runApp(FoodBridgeApp(repository: repository));
}

class FoodBridgeApp extends StatelessWidget {
  final AppRepository repository;
  final AppFlowStep initialStep;

  const FoodBridgeApp({
    super.key,
    required this.repository,
    this.initialStep = AppFlowStep.splash,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return RealtimeNotificationOverlay(
          repository: repository,
          onActionTap: (notif) {
            final donationId = notif.metadata['donation_id'] ?? notif.entityId;
            if (donationId != null && donationId.toString().isNotEmpty) {
              final donations = repository.donations;
              final found = donations.where((d) => d.id == donationId.toString()).toList();
              final donation = found.isNotEmpty
                  ? found.first
                  : (repository.availableDonations.isNotEmpty
                      ? repository.availableDonations.first
                      : (donations.isNotEmpty ? donations.first : null));
              if (donation != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => DonationDetailsScreen(
                      donation: donation,
                      repository: repository,
                    ),
                  ),
                );
                return;
              }
            }
            NotificationCenterSheet.show(context, repository: repository);
          },
          child: child ?? const SizedBox(),
        );
      },
      home: AppRootFlow(repository: repository, initialStep: initialStep),
    );
  }
}

enum AppFlowStep {
  splash,
  onboarding,
  roleSelection,
  donorAuth,
  communityAuth,
  ngoRegister,
  ngoVerificationPending,
  authenticatedMain,
}

class AppRootFlow extends StatefulWidget {
  final AppRepository repository;
  final AppFlowStep initialStep;

  const AppRootFlow({
    super.key,
    required this.repository,
    this.initialStep = AppFlowStep.splash,
  });

  @override
  State<AppRootFlow> createState() => _AppRootFlowState();
}

class _AppRootFlowState extends State<AppRootFlow> {
  late AppFlowStep _currentStep;
  NGOModel? _lastRegisteredNgo;
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
  }

  void _proceedWithTerms(BuildContext ctx, VoidCallback onGranted) async {
    if (_termsAccepted) {
      onGranted();
      return;
    }

    final accepted = await TermsAndConditionsDialog.show(ctx);
    if (accepted == true) {
      setState(() => _termsAccepted = true);
      onGranted();
    } else {
      // User declined terms, return to role selection
      setState(() => _currentStep = AppFlowStep.roleSelection);
    }
  }

  void _onRoleSelected(UserRole role) {
    widget.repository.setRole(role);
    if (role == UserRole.donor) {
      setState(() => _currentStep = AppFlowStep.donorAuth);
    } else if (role == UserRole.community) {
      setState(() => _currentStep = AppFlowStep.communityAuth);
    } else if (role == UserRole.ngo) {
      setState(() => _currentStep = AppFlowStep.ngoRegister);
    } else {
      // Admin role requires Terms acceptance before entering
      _proceedWithTerms(context, () {
        setState(() => _currentStep = AppFlowStep.authenticatedMain);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentStep) {
      case AppFlowStep.splash:
        return SplashScreen(
          onContinue: () {
            setState(() => _currentStep = AppFlowStep.onboarding);
          },
        );

      case AppFlowStep.onboarding:
        return OnboardingScreen(
          onFinish: () {
            setState(() => _currentStep = AppFlowStep.roleSelection);
          },
        );

      case AppFlowStep.roleSelection:
        return RoleSelectionScreen(
          onRoleSelected: _onRoleSelected,
        );

      case AppFlowStep.donorAuth:
        return DonorOtpScreen(
          onBack: () {
            setState(() => _currentStep = AppFlowStep.roleSelection);
          },
          onAuthenticated: () {
            _proceedWithTerms(context, () {
              setState(() => _currentStep = AppFlowStep.authenticatedMain);
            });
          },
        );

      case AppFlowStep.communityAuth:
        return SecureAuthScreen(
          role: UserRole.community,
          onBack: () {
            setState(() => _currentStep = AppFlowStep.roleSelection);
          },
          onAuthenticated: () {
            _proceedWithTerms(context, () {
              setState(() => _currentStep = AppFlowStep.authenticatedMain);
            });
          },
        );

      case AppFlowStep.ngoRegister:
        return NGORegisterScreen(
          repository: widget.repository,
          onBackToRoles: () {
            setState(() => _currentStep = AppFlowStep.roleSelection);
          },
          onRegistered: (ngo) {
            _lastRegisteredNgo = ngo;
            setState(() => _currentStep = AppFlowStep.ngoVerificationPending);
          },
          onExistingSignedIn: (ngo) {
            _lastRegisteredNgo = ngo;
            if (ngo.isVerified) {
              _proceedWithTerms(context, () {
                setState(() => _currentStep = AppFlowStep.authenticatedMain);
              });
            } else {
              setState(() => _currentStep = AppFlowStep.ngoVerificationPending);
            }
          },
        );

      case AppFlowStep.ngoVerificationPending:
        return VerificationStatusScreen(
          ngo: _lastRegisteredNgo ?? widget.repository.ngos.first,
          repository: widget.repository,
          onBackToSignIn: () {
            setState(() => _currentStep = AppFlowStep.ngoRegister);
          },
          onEnterDashboard: () {
            _proceedWithTerms(context, () {
              setState(() => _currentStep = AppFlowStep.authenticatedMain);
            });
          },
        );

      case AppFlowStep.authenticatedMain:
        return MainNavigationShell(
          repository: widget.repository,
          lastRegisteredNgo: _lastRegisteredNgo,
          onChangeRole: (newRole) {
            widget.repository.setRole(newRole);
          },
          onResetOnboarding: () {
            setState(() => _currentStep = AppFlowStep.roleSelection);
          },
          onLogout: () {
            setState(() {
              _currentStep = AppFlowStep.roleSelection;
            });
          },
        );
    }
  }
}

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: AppTheme.forestGreen,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.eco_rounded,
                        color: AppTheme.forestGreen, size: 26),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Active Role: ${currentRole.name.toUpperCase()}',
                    style: const TextStyle(
                      color: AppTheme.limeLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Text(
                'SWITCH ACTIVE ROLE (HACKATHON DEMO)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.charcoalMuted,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.storefront_rounded,
                  color: AppTheme.forestGreen),
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
              leading: const Icon(Icons.card_giftcard_rounded,
                  color: Color(0xFF0284C7)),
              title: const Text('Community Giver (Clothes, Books, 80G Funds)'),
              selected: currentRole == UserRole.community,
              selectedTileColor: AppTheme.emeraldLight,
              onTap: () {
                Navigator.pop(context);
                widget.onChangeRole(UserRole.community);
                setState(() => _currentNavIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.soup_kitchen_rounded,
                  color: AppTheme.forestGreen),
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
              leading: const Icon(Icons.security_rounded,
                  color: AppTheme.forestGreen),
              title: const Text('Platform Administrator'),
              selected: currentRole == UserRole.admin,
              selectedTileColor: AppTheme.emeraldLight,
              onTap: () {
                Navigator.pop(context);
                widget.onChangeRole(UserRole.admin);
                setState(() => _currentNavIndex = 0);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.replay_rounded,
                  color: AppTheme.charcoalMuted),
              title: const Text('Restart Welcome & Onboarding'),
              onTap: () {
                Navigator.pop(context);
                widget.onResetOnboarding();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded,
                  color: AppTheme.statusCritical),
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
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                '${AppConstants.appName} • ${AppConstants.appVersion}\nSupabase PostgreSQL + Real-Time OTP & Verification Gate',
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
    );
  }
}
