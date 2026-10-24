import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../../data/models/donation_model.dart';
import '../../../data/repositories/app_repository.dart';
import 'delivery_confirm_screen.dart';

class PickupVerifyActionScreen extends StatefulWidget {
  final DonationModel donation;
  final AppRepository repository;

  const PickupVerifyActionScreen({
    super.key,
    required this.donation,
    required this.repository,
  });

  @override
  State<PickupVerifyActionScreen> createState() =>
      _PickupVerifyActionScreenState();
}

class _PickupVerifyActionScreenState extends State<PickupVerifyActionScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  late AnimationController _scannerAnim;
  bool _isVerifying = false;
  bool _isScannerMode = true;

  @override
  void initState() {
    super.initState();
    _scannerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scannerAnim.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _verifyCode(String enteredOtp) async {
    setState(() => _isVerifying = true);

    final ngoId = widget.repository.verifiedNGOs.isNotEmpty
        ? widget.repository.verifiedNGOs.first.id
        : widget.repository.ngos.first.id;

    final result = await widget.repository.verifyPickup(
      donationId: widget.donation.id,
      enteredOtp: enteredOtp,
      ngoId: ngoId,
    );

    if (mounted) {
      setState(() => _isVerifying = false);

      if (result['success'] == true) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Row(
              children: [
                Icon(Icons.verified_rounded,
                    color: AppTheme.emerald, size: 26),
                SizedBox(width: 10),
                Text('Pickup Authenticated!'),
              ],
            ),
            content: const Text(
              'One-time hand-off verified. Custody transferred to your NGO team.\n\n'
              'Proceed to deliver meals to community beneficiaries and log the distribution count.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            actions: [
              AppButton(
                label: 'Proceed to Delivery Confirmation',
                icon: Icons.check_circle_outline_rounded,
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeliveryConfirmScreen(
                        donation: widget.donation,
                        repository: widget.repository,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Invalid OTP code'),
            backgroundColor: AppTheme.statusCritical,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmIvory,
      appBar: AppBar(
        title: const Text('Verify Hand-Off'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.donation.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.richCharcoal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pickup from ${widget.donation.donorName} (${widget.donation.quantityLabel})',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.emeraldDark,
                ),
              ),
              const SizedBox(height: 20),

              // Mode Switcher Tabs
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _isScannerMode
                            ? AppTheme.forestGreen
                            : Colors.white,
                        foregroundColor:
                            _isScannerMode ? Colors.white : AppTheme.forestGreen,
                      ),
                      onPressed: () => setState(() => _isScannerMode = true),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_scanner_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('Scan Donor QR'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: !_isScannerMode
                            ? AppTheme.forestGreen
                            : Colors.white,
                        foregroundColor:
                            !_isScannerMode ? Colors.white : AppTheme.forestGreen,
                      ),
                      onPressed: () => setState(() => _isScannerMode = false),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pin_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('Enter 4-Digit OTP'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (_isScannerMode) ...[
                // Simulated Scanner Viewfinder
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.cardElevation,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.qr_code_2_rounded,
                            size: 150,
                            color: Colors.white24,
                          ),
                          AnimatedBuilder(
                            animation: _scannerAnim,
                            builder: (context, _) {
                              return Positioned(
                                top: 20 + (200 * _scannerAnim.value),
                                left: 20,
                                right: 20,
                                child: Container(
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: AppTheme.restrainedLime,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.restrainedLime
                                            .withValues(alpha: 0.8),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white70,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            width: 180,
                            height: 180,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Point camera at donor phone screen to scan passcode',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppTheme.charcoalMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Simulate Camera Scan (Code: ${widget.donation.pickupOtp})',
                  icon: Icons.camera_alt_rounded,
                  isLoading: _isVerifying,
                  onPressed: () => _verifyCode(widget.donation.pickupOtp),
                ),
              ] else ...[
                // Manual OTP Form
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enter 4-Digit Hand-Off Code',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.richCharcoal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Ask the donor for their 4-digit pickup code displayed on their active listing.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppTheme.charcoalMuted,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) {
                          return SizedBox(
                            width: 56,
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
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onChanged: (val) {
                                if (val.isNotEmpty && index < 3) {
                                  _focusNodes[index + 1].requestFocus();
                                }
                              },
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton.icon(
                          icon: const Icon(Icons.flash_on_rounded, size: 16),
                          label: Text(
                              'Autofill Donor Code: ${widget.donation.pickupOtp}'),
                          onPressed: () {
                            final code = widget.donation.pickupOtp;
                            for (int i = 0; i < 4 && i < code.length; i++) {
                              _otpControllers[i].text = code[i];
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'Submit Code for Verification',
                        icon: Icons.check_circle_outline_rounded,
                        isLoading: _isVerifying,
                        onPressed: () {
                          final code = _otpControllers.map((c) => c.text).join();
                          _verifyCode(code);
                        },
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
