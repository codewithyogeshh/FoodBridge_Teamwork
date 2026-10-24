import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

class DonorOtpScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;
  final VoidCallback? onBack;

  const DonorOtpScreen({super.key, required this.onAuthenticated, this.onBack});

  @override
  State<DonorOtpScreen> createState() => _DonorOtpScreenState();
}

class _DonorOtpScreenState extends State<DonorOtpScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _otpSent = false;
  bool _isSubmitting = false;
  String? _generatedOtp;
  String? _errorMessage;

  Timer? _resendTimer;
  int _secondsRemaining = 60;
  bool _showSmsBanner = false;

  void _sendRealtimeOtp() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid mobile number.'),
          backgroundColor: AppTheme.statusCritical,
        ),
      );
      return;
    }

    // Generate real 6-digit dynamic OTP
    final randomOtp = (100000 + math.Random().nextInt(900000)).toString();

    setState(() {
      _otpSent = true;
      _generatedOtp = randomOtp;
      _errorMessage = null;
      _showSmsBanner = true;
      _secondsRemaining = 60;
    });

    // Clear input controllers
    for (var c in _otpControllers) {
      c.clear();
    }

    // Start 60-second resend countdown
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });

    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes[0].canRequestFocus) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  void _autofillOtp() {
    if (_generatedOtp != null && _generatedOtp!.length == 6) {
      for (int i = 0; i < 6; i++) {
        _otpControllers[i].text = _generatedOtp![i];
      }
      setState(() {
        _showSmsBanner = false;
        _errorMessage = null;
      });
      _verifyOtp();
    }
  }

  void _verifyOtp() {
    final enteredOtp = _otpControllers.map((c) => c.text.trim()).join();

    if (enteredOtp.length < 6) {
      setState(() => _errorMessage = 'Please enter all 6 digits of the OTP.');
      return;
    }

    if (enteredOtp != _generatedOtp) {
      setState(() {
        _errorMessage =
            'Invalid OTP code ($enteredOtp). Please check the 6-digit SMS code.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect OTP! Please check the SMS banner or resend.'),
          backgroundColor: AppTheme.statusCritical,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP Verified Successfully! Welcome to FoodBridge.'),
            backgroundColor: AppTheme.forestGreen,
          ),
        );
        widget.onAuthenticated();
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _phoneController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmIvory,
      appBar: AppBar(
        title: const Text('Donor Sign-In'),
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'Back to Role Selection',
                onPressed: widget.onBack,
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // REAL-TIME SIMULATED SMS BANNER
              if (_showSmsBanner && _generatedOtp != null) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.forestGreen,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.emerald,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.sms_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'MESSAGES • NOW',
                                  style: TextStyle(
                                    color: AppTheme.limeLight,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'FoodBridge OTP: $_generatedOtp',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Sent to ${_phoneController.text}. Valid for 10 min.',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
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
                              horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _autofillOtp,
                        child: const Text('Autofill',
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.phone_iphone_rounded,
                  size: 28,
                  color: AppTheme.forestGreen,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome Food Donor',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: AppTheme.richCharcoal,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter your mobile number to receive a real-time verification passcode. Once verified, you will enter FoodBridge.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.charcoalMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              if (!_otpSent) ...[
                AppTextField(
                  label: 'Mobile Number',
                  hint: 'e.g. +91 98860 12345',
                  controller: _phoneController,
                  prefixIcon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warmIvoryDark,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock_outline_rounded,
                          size: 18, color: AppTheme.forestGreen),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'A 6-digit real-time verification code will be sent to your phone. Your information is kept strictly private.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.charcoalMuted,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Send One-Time Passcode',
                  icon: Icons.send_rounded,
                  onPressed: _sendRealtimeOtp,
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Enter 6-Digit Verification Code',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.richCharcoal,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => _otpSent = false);
                      },
                      child: const Text('Change Phone',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 6-digit OTP fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 46,
                      height: 56,
                      child: TextFormField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.forestGreen,
                        ),
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: _errorMessage != null
                                  ? AppTheme.statusCritical
                                  : AppTheme.borderColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppTheme.forestGreen, width: 2),
                          ),
                        ),
                        onChanged: (val) {
                          if (val.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else if (val.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                          if (_otpControllers
                              .every((c) => c.text.trim().isNotEmpty)) {
                            _verifyOtp();
                          }
                        },
                      ),
                    );
                  }),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppTheme.statusCritical, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppTheme.statusCritical,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),
                AppButton(
                  label: 'Verify & Enter Dashboard',
                  isLoading: _isSubmitting,
                  icon: Icons.login_rounded,
                  onPressed: _verifyOtp,
                ),
                const SizedBox(height: 16),
                Center(
                  child: _secondsRemaining > 0
                      ? Text(
                          'Resend code in $_secondsRemaining seconds',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.charcoalMuted,
                          ),
                        )
                      : TextButton.icon(
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Resend Code via SMS'),
                          onPressed: _sendRealtimeOtp,
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
