import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/terms_dialog.dart';
import '../widgets/notification_banner_overlay.dart';
import '../../../data/models/ngo_model.dart';
import '../../../data/repositories/app_repository.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/onboarding_screen.dart';
import '../../features/auth/role_selection_screen.dart';
import '../../features/auth/donor_otp_screen.dart';
import '../../features/auth/secure_auth_screen.dart';
import '../../features/auth/ngo_register_screen.dart';
import '../../features/auth/verification_status_screen.dart';
import 'main_navigation_shell.dart';

enum AppFlowStep {
  splash,
  onboarding,
  roleSelection,
  donorAuth,
  communityAuth,
  volunteerAuth,
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
    } else if (role == UserRole.volunteer) {
      setState(() => _currentStep = AppFlowStep.volunteerAuth);
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
        return RoleSelectionScreen(onRoleSelected: _onRoleSelected);

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

      case AppFlowStep.volunteerAuth:
        return SecureAuthScreen(
          role: UserRole.volunteer,
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
        return RealtimeNotificationOverlay(
          repository: widget.repository,
          child: MainNavigationShell(
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
          ),
        );
    }
  }
}
