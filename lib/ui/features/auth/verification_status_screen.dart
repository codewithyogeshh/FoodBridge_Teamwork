import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_badge.dart';
import '../../../data/models/ngo_model.dart';
import '../../../data/repositories/app_repository.dart';

class VerificationStatusScreen extends StatefulWidget {
  final NGOModel ngo;
  final AppRepository repository;
  final VoidCallback onEnterDashboard;
  final VoidCallback? onBackToSignIn;

  const VerificationStatusScreen({
    super.key,
    required this.ngo,
    required this.repository,
    required this.onEnterDashboard,
    this.onBackToSignIn,
  });

  @override
  State<VerificationStatusScreen> createState() =>
      _VerificationStatusScreenState();
}

class _VerificationStatusScreenState extends State<VerificationStatusScreen> {
  late NGOModel _ngo;
  bool _isApproving = false;

  @override
  void initState() {
    super.initState();
    _ngo = widget.ngo;
    widget.repository.addListener(_onRepoChanged);
  }

  void _onRepoChanged() {
    final updated = widget.repository.findNGOByPhoneOrReg(_ngo.phone) ??
        widget.repository.findNGOByPhoneOrReg(_ngo.registrationNumber);
    if (updated != null && mounted) {
      setState(() {
        _ngo = updated;
      });
    }
  }

  @override
  void dispose() {
    widget.repository.removeListener(_onRepoChanged);
    super.dispose();
  }

  void _simulateApproval() async {
    setState(() => _isApproving = true);
    await widget.repository
        .updateNGOVerification(_ngo.id, NGOVerificationStatus.verified);
    if (mounted) {
      setState(() {
        _ngo = _ngo.copyWith(
            verificationStatus: NGOVerificationStatus.verified);
        _isApproving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NGO Verification Approved! Access granted to live food rescue feed.'),
          backgroundColor: AppTheme.forestGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVerified = _ngo.isVerified;

    return Scaffold(
      backgroundColor: AppTheme.warmIvory,
      appBar: AppBar(
        title: const Text('Compliance Verification Status'),
        leading: widget.onBackToSignIn != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'Back to Sign In / Register',
                onPressed: widget.onBackToSignIn,
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Status Card
              AppCard(
                backgroundColor: isVerified
                    ? AppTheme.emeraldLight.withValues(alpha: 0.3)
                    : const Color(0xFFFEF3C7).withValues(alpha: 0.3),
                border: BorderSide(
                  color: isVerified ? AppTheme.emerald : const Color(0xFFD97706),
                  width: 1.5,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isVerified
                            ? AppTheme.forestGreen
                            : const Color(0xFFD97706),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isVerified
                            ? Icons.verified_rounded
                            : Icons.hourglass_top_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _ngo.organizationName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.richCharcoal,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Reg: ${_ngo.registrationNumber}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.charcoalMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          NGOVerifiedBadge(isVerified: isVerified),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Verification Pipeline',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.richCharcoal,
                ),
              ),
              const SizedBox(height: 12),
              _buildTimelineStep(
                title: 'Application & Registration Details',
                desc: 'Government 80G/12A registration documents received.',
                isDone: true,
                isCurrent: false,
              ),
              _buildTimelineStep(
                title: 'FSSAI Food Safety Compliance Audit',
                desc: 'Food handler hygiene certification verified by FoodBridge compliance team.',
                isDone: isVerified,
                isCurrent: !isVerified,
              ),
              _buildTimelineStep(
                title: 'Kitchen Daily Meal Capacity Check',
                desc: 'Verified facility capacity: ${_ngo.capacityMealsPerDay} meals/day.',
                isDone: isVerified,
                isCurrent: false,
              ),
              _buildTimelineStep(
                title: 'Live Rescue Network Authorization',
                desc: 'Authorized to lock atomic reservations and execute secure OTP handoffs.',
                isDone: isVerified,
                isCurrent: false,
                isLast: true,
              ),
              const SizedBox(height: 28),
              if (!isVerified) ...[
                // Access Locked Warning Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.statusCritical, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.statusCritical.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.lock_rounded,
                                color: AppTheme.statusCritical, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'LOGIN LOCKED: PENDING ADMIN APPROVAL',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.statusCritical,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Aadhaar / PAN & FSSAI credentials under audit.',
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
                      const SizedBox(height: 10),
                      const Text(
                        'To prevent counterfeit claims and protect public food safety, FoodBridge strictly blocks unverified entities from accessing surplus food listings. Once an administrator approves your uploaded identity documents in the Admin Panel, your login will automatically unlock.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppTheme.charcoalMuted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                AppButton(
                  label: 'Check for Admin Approval',
                  icon: Icons.sync_rounded,
                  variant: AppButtonVariant.primary,
                  onPressed: () {
                    final updated = widget.repository.ngos.firstWhere(
                      (n) => n.id == _ngo.id,
                      orElse: () => _ngo,
                    );
                    setState(() => _ngo = updated);
                    if (_ngo.isVerified) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Congratulations! Your organization is verified by Admin. Access unlocked.'),
                          backgroundColor: AppTheme.forestGreen,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Still pending administrator audit. Please wait or approve in Admin Desk.'),
                          backgroundColor: Color(0xFFD97706),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                AppButton(
                  label: 'Simulate Admin Approval (Hackathon Demo)',
                  icon: Icons.verified_user_outlined,
                  isLoading: _isApproving,
                  variant: AppButtonVariant.secondary,
                  onPressed: _simulateApproval,
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Standard verification turnaround is within 4 business hours.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.emerald, width: 1.5),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: AppTheme.forestGreen, size: 28),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CREDENTIALS VERIFIED & APPROVED',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.forestGreen,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'You are authorized to discover and claim surplus food.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.richCharcoal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                AppButton(
                  label: 'Enter NGO Food Discovery Dashboard',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: widget.onEnterDashboard,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String desc,
    required bool isDone,
    required bool isCurrent,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? AppTheme.forestGreen
                    : (isCurrent ? const Color(0xFFD97706) : Colors.grey.shade300),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : (isCurrent
                        ? const Icon(Icons.more_horiz, size: 14, color: Colors.white)
                        : null),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: isDone ? AppTheme.forestGreen : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isCurrent || isDone
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isCurrent || isDone
                        ? AppTheme.richCharcoal
                        : AppTheme.charcoalLight,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.charcoalMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
