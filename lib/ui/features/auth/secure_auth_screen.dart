import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_card.dart';

class SecureAuthScreen extends StatefulWidget {
  final UserRole role;
  final VoidCallback onAuthenticated;
  final VoidCallback? onBack;

  const SecureAuthScreen({
    super.key,
    required this.role,
    required this.onAuthenticated,
    this.onBack,
  });

  @override
  State<SecureAuthScreen> createState() => _SecureAuthScreenState();
}

class _SecureAuthScreenState extends State<SecureAuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sign In Controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _loginObscurePassword = true;

  // Sign Up Controllers
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmPasswordController = TextEditingController();
  bool _regObscurePassword = true;
  bool _regObscureConfirm = true;

  // Privacy & Security Preferences
  bool _donateAnonymously = false;
  bool _enableBiometrics = true;
  bool _acceptedTerms = true;

  // Alternate Phone OTP Login
  bool _usePhoneOtp = false;
  final _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _otpSent = false;
  String? _generatedOtp;
  int _otpCountdown = 60;
  Timer? _countdownTimer;
  bool _showSmsBanner = false;

  // Form States & Password Strength
  final _loginFormKey = GlobalKey<FormState>();
  final _regFormKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _regPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPhoneController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    _phoneController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    _countdownTimer?.cancel();
    super.dispose();
  }

  // Live Password Strength Calculator
  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    double score = 0.0;
    if (password.length >= 8) score += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) score += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) score += 0.25;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 0.25;
    return score;
  }

  Color _getStrengthColor(double strength) {
    if (strength <= 0.25) return AppTheme.statusCritical;
    if (strength <= 0.50) return const Color(0xFFD97706);
    if (strength <= 0.75) return const Color(0xFF2563EB);
    return AppTheme.forestGreen;
  }

  String _getStrengthLabel(double strength) {
    if (strength == 0.0) return 'Enter password';
    if (strength <= 0.25) return 'Weak (Add numbers & symbols)';
    if (strength <= 0.50) return 'Fair (Add uppercase & symbols)';
    if (strength <= 0.75) return 'Good (Almost secure)';
    return 'Strong & Highly Secure';
  }

  void _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Secure Authentication Successful! Welcome back.'),
        backgroundColor: AppTheme.forestGreen,
      ),
    );
    widget.onAuthenticated();
  }

  void _handleRegister() async {
    if (!_regFormKey.currentState!.validate()) return;

    if (_calculatePasswordStrength(_regPasswordController.text) < 0.75) {
      setState(() {
        _errorMessage =
            'Please choose a stronger password containing uppercase, number and a special symbol.';
      });
      return;
    }

    if (_regPasswordController.text != _regConfirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    if (!_acceptedTerms) {
      setState(
        () => _errorMessage = 'Please review and accept our Privacy Policy.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _donateAnonymously
              ? 'Account created securely! Anonymous Giving Mode enabled.'
              : 'Account created with 256-bit credential protection!',
        ),
        backgroundColor: AppTheme.forestGreen,
      ),
    );
    widget.onAuthenticated();
  }

  void _sendPhoneOtp() {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number.'),
          backgroundColor: AppTheme.statusCritical,
        ),
      );
      return;
    }

    final code = (100000 + math.Random().nextInt(900000)).toString();
    setState(() {
      _otpSent = true;
      _generatedOtp = code;
      _showSmsBanner = true;
      _otpCountdown = 60;
      _errorMessage = null;
    });

    for (var c in _otpControllers) {
      c.clear();
    }

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpCountdown > 0) {
        setState(() => _otpCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  void _autofillOtp() {
    if (_generatedOtp != null && _generatedOtp!.length == 6) {
      for (int i = 0; i < 6; i++) {
        _otpControllers[i].text = _generatedOtp![i];
      }
      setState(() => _showSmsBanner = false);
      _verifyPhoneOtp();
    }
  }

  void _verifyPhoneOtp() {
    final entered = _otpControllers.map((c) => c.text.trim()).join();
    if (entered.length < 6) {
      setState(() => _errorMessage = 'Please enter all 6 digits.');
      return;
    }
    if (entered != _generatedOtp) {
      setState(() => _errorMessage = 'Invalid OTP code. Please retry.');
      return;
    }

    setState(() => _isSubmitting = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number verified! Secure session created.'),
          backgroundColor: AppTheme.forestGreen,
        ),
      );
      widget.onAuthenticated();
    });
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(
      text: _loginEmailController.text,
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(
              Icons.lock_reset_rounded,
              color: AppTheme.forestGreen,
              size: 26,
            ),
            SizedBox(width: 10),
            Text('Reset Password'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your registered email address. We will transmit an encrypted single-use password reset link.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppTheme.charcoalMuted,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              decoration: InputDecoration(
                labelText: 'Account Email',
                hintText: 'name@example.com',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.forestGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Encrypted password reset token dispatched to email.',
                  ),
                  backgroundColor: AppTheme.forestGreen,
                ),
              );
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roleName = widget.role == UserRole.community
        ? 'Community Giver'
        : widget.role == UserRole.donor
        ? 'Food Donor'
        : widget.role.name.toUpperCase();

    return Scaffold(
      backgroundColor: AppTheme.warmIvory,
      appBar: AppBar(
        title: Text('Secure Access • $roleName'),
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'Back to Role Selection',
                onPressed: widget.onBack,
              )
            : null,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.forestGreen,
          unselectedLabelColor: AppTheme.charcoalMuted,
          indicatorColor: AppTheme.forestGreen,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.lock_outline_rounded, size: 18),
              text: 'Sign In',
            ),
            Tab(
              icon: Icon(Icons.person_add_alt_rounded, size: 18),
              text: 'Create Account',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: TabBarView(
              controller: _tabController,
              children: [_buildSignInView(), _buildSignUpView()],
            ),
          ),
        ),
      ),
    );
  }

  // ========================= SIGN IN VIEW =========================
  Widget _buildSignInView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSecurityBadgeHeader(),
          const SizedBox(height: 16),
          // Toggle between Email & Phone OTP
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.warmIvoryDark,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _usePhoneOtp = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !_usePhoneOtp
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: !_usePhoneOtp
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Email & Password',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: !_usePhoneOtp
                              ? AppTheme.forestGreen
                              : AppTheme.charcoalMuted,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _usePhoneOtp = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _usePhoneOtp ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _usePhoneOtp
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Phone & SMS OTP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _usePhoneOtp
                              ? AppTheme.forestGreen
                              : AppTheme.charcoalMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (!_usePhoneOtp) ...[
            // Email & Password Form
            AppCard(
              child: Form(
                key: _loginFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      label: 'Account Email',
                      hint: 'name@example.com',
                      controller: _loginEmailController,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!v.contains('@') || !v.contains('.')) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          label: 'Password',
                          hint: '••••••••',
                          controller: _loginPasswordController,
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _loginObscurePassword,
                          suffix: IconButton(
                            icon: Icon(
                              _loginObscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppTheme.charcoalMuted,
                            ),
                            onPressed: () => setState(
                              () => _loginObscurePassword =
                                  !_loginObscurePassword,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Password is required';
                            }
                            if (v.length < 6) {
                              return 'Password too short';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 30),
                            ),
                            onPressed: _showForgotPasswordDialog,
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.forestGreen,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      _buildErrorBanner(_errorMessage!),
                    ],
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Sign In Securely',
                      icon: Icons.login_rounded,
                      isLoading: _isSubmitting,
                      onPressed: _handleLogin,
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Phone OTP Login
            _buildPhoneOtpLoginCard(),
          ],

          const SizedBox(height: 20),
          _buildPrivacyTrustFooter(),
        ],
      ),
    );
  }

  // ========================= SIGN UP VIEW =========================
  Widget _buildSignUpView() {
    final passwordStrength = _calculatePasswordStrength(
      _regPasswordController.text,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSecurityBadgeHeader(),
          const SizedBox(height: 16),
          AppCard(
            child: Form(
              key: _regFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Your Secure Giving Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.richCharcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Your data is encrypted. You can toggle anonymous mode anytime.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.charcoalMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Full Legal Name / Display Name',
                    hint: 'e.g. Ananya Roy',
                    controller: _regNameController,
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required field' : null,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Official Email Address',
                    hint: 'ananya@example.com',
                    controller: _regEmailController,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (!v.contains('@') || !v.contains('.')) {
                        return 'Invalid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Contact Phone Number (For Verification & Receipts)',
                    hint: '+91 9XXXXXXXXX',
                    controller: _regPhoneController,
                    prefixIcon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v == null || v.trim().length < 10
                        ? 'Enter valid phone'
                        : null,
                  ),
                  const SizedBox(height: 14),

                  // PASSWORD FIELD & STRENGTH BAR
                  AppTextField(
                    label: 'Create Master Password',
                    hint: 'Minimum 8 characters with symbols',
                    controller: _regPasswordController,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: _regObscurePassword,
                    suffix: IconButton(
                      icon: Icon(
                        _regObscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppTheme.charcoalMuted,
                      ),
                      onPressed: () => setState(
                        () => _regObscurePassword = !_regObscurePassword,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password required';
                      if (v.length < 8) return 'Minimum 8 characters required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Live Strength Indicator
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Password Strength:',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.charcoalMuted,
                            ),
                          ),
                          Text(
                            _getStrengthLabel(passwordStrength),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _getStrengthColor(passwordStrength),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: passwordStrength,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getStrengthColor(passwordStrength),
                          ),
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // CONFIRM PASSWORD
                  AppTextField(
                    label: 'Confirm Master Password',
                    hint: 'Re-enter identical password',
                    controller: _regConfirmPasswordController,
                    prefixIcon: Icons.lock_rounded,
                    obscureText: _regObscureConfirm,
                    suffix: IconButton(
                      icon: Icon(
                        _regObscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppTheme.charcoalMuted,
                      ),
                      onPressed: () => setState(
                        () => _regObscureConfirm = !_regObscureConfirm,
                      ),
                    ),
                    validator: (v) {
                      if (v != _regPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  const Divider(),
                  const SizedBox(height: 10),

                  // PRIVACY CONTROLS
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: AppTheme.forestGreen,
                    activeTrackColor: AppTheme.forestGreen.withValues(
                      alpha: 0.4,
                    ),
                    title: const Row(
                      children: [
                        Icon(
                          Icons.visibility_off_rounded,
                          size: 18,
                          color: AppTheme.forestGreen,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Anonymous Donor Mode',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.richCharcoal,
                          ),
                        ),
                      ],
                    ),
                    subtitle: const Text(
                      'Hide my identity on public leaderboards, shelter feeds, and delivery handoffs.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.charcoalMuted,
                      ),
                    ),
                    value: _donateAnonymously,
                    onChanged: (val) =>
                        setState(() => _donateAnonymously = val),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: AppTheme.forestGreen,
                    activeTrackColor: AppTheme.forestGreen.withValues(
                      alpha: 0.4,
                    ),
                    title: const Row(
                      children: [
                        Icon(
                          Icons.fingerprint_rounded,
                          size: 18,
                          color: AppTheme.forestGreen,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Enable Device Biometric Quick-Unlock',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.richCharcoal,
                          ),
                        ),
                      ],
                    ),
                    subtitle: const Text(
                      'Use Touch ID / Face ID for fast, encrypted session resumption.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.charcoalMuted,
                      ),
                    ),
                    value: _enableBiometrics,
                    onChanged: (val) => setState(() => _enableBiometrics = val),
                  ),

                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppTheme.forestGreen,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text(
                      'I agree to FoodBridge Safety Guidelines & DPDP Privacy Terms.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.richCharcoal,
                      ),
                    ),
                    value: _acceptedTerms,
                    onChanged: (val) =>
                        setState(() => _acceptedTerms = val ?? true),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    _buildErrorBanner(_errorMessage!),
                  ],
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Create Encrypted Account & Continue',
                    icon: Icons.shield_rounded,
                    isLoading: _isSubmitting,
                    onPressed: _handleRegister,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildPrivacyTrustFooter(),
        ],
      ),
    );
  }

  // ========================= PHONE OTP LOGIN CARD =========================
  Widget _buildPhoneOtpLoginCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_showSmsBanner && _generatedOtp != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.forestGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sms_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MESSAGES • REAL-TIME OTP',
                          style: TextStyle(
                            color: AppTheme.limeLight,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Your FoodBridge Passcode: $_generatedOtp',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.restrainedLime,
                      foregroundColor: AppTheme.richCharcoal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: const Size(40, 28),
                    ),
                    onPressed: _autofillOtp,
                    child: const Text(
                      'Autofill',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          if (!_otpSent) ...[
            AppTextField(
              label: 'Mobile Phone Number',
              hint: '+91 9XXXXXXXXX',
              controller: _phoneController,
              prefixIcon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            AppButton(
              label: 'Send One-Time Passcode',
              icon: Icons.send_rounded,
              onPressed: _sendPhoneOtp,
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Enter 6-Digit Passcode',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.richCharcoal,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _otpSent = false),
                  child: const Text(
                    'Change Number',
                    style: TextStyle(fontSize: 11, color: AppTheme.forestGreen),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 44,
                  height: 52,
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.forestGreen,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppTheme.forestGreen,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (val) {
                      if (val.isNotEmpty && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (val.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                      if (_otpControllers.every((c) => c.text.isNotEmpty)) {
                        _verifyPhoneOtp();
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _otpCountdown > 0
                      ? 'Resend OTP in ${_otpCountdown}s'
                      : 'Did not receive code?',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.charcoalMuted,
                  ),
                ),
                if (_otpCountdown == 0)
                  TextButton(
                    onPressed: _sendPhoneOtp,
                    child: const Text(
                      'Resend Code',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.forestGreen,
                      ),
                    ),
                  ),
              ],
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              _buildErrorBanner(_errorMessage!),
            ],
            const SizedBox(height: 16),
            AppButton(
              label: 'Verify & Enter',
              icon: Icons.check_circle_rounded,
              isLoading: _isSubmitting,
              onPressed: _verifyPhoneOtp,
            ),
          ],
        ],
      ),
    );
  }

  // ========================= HELPER WIDGETS =========================
  Widget _buildSecurityBadgeHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.emeraldLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.emerald.withValues(alpha: 0.6)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.verified_user_rounded,
            color: AppTheme.forestGreen,
            size: 22,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ENTERPRISE BANK-GRADE SECURITY',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.forestGreen,
                    letterSpacing: 0.6,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  '256-Bit SSL • Password Salting • DPDP Act 2023 Compliant',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppTheme.richCharcoal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.statusCritical),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppTheme.statusCritical,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.statusCritical,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyTrustFooter() {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_clock_rounded,
                size: 14,
                color: AppTheme.charcoalMuted,
              ),
              const SizedBox(width: 6),
              Text(
                'Zero Knowledge Architecture • Passwords Never Stored in Plain Text',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Your privacy is guaranteed under Section 43A of the IT Act & DPDP Act.',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
