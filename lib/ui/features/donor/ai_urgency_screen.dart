import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_badge.dart';
import '../../../data/models/donation_model.dart';
import '../../../data/models/ai_recommendation_model.dart';
import '../../../data/repositories/app_repository.dart';
import 'suggested_ngos_screen.dart';

class AIUrgencyScreen extends StatefulWidget {
  final DonationModel donation;
  final AppRepository repository;
  final VoidCallback onConfirmed;

  const AIUrgencyScreen({
    super.key,
    required this.donation,
    required this.repository,
    required this.onConfirmed,
  });

  @override
  State<AIUrgencyScreen> createState() => _AIUrgencyScreenState();
}

class _AIUrgencyScreenState extends State<AIUrgencyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _isProcessing = true;
  late AIAllocationAnalysis _analysis;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _runAnalysis();
  }

  void _runAnalysis() async {
    // Run real allocation logic
    _analysis = widget.repository.runAIAllocation(widget.donation);

    // Simulate animated neural matching
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmIvory,
      appBar: AppBar(title: const Text('AI Allocation & Urgency Engine')),
      body: SafeArea(
        child: _isProcessing
            ? _buildProcessingAnimation()
            : _buildAnalysisResults(),
      ),
    );
  }

  Widget _buildProcessingAnimation() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _animController,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.forestGreen,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.forestGreen.withValues(alpha: 0.3),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: AppTheme.restrainedLime,
                    size: 42,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Analyzing Thermal & Routing Dynamics',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: AppTheme.richCharcoal,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Running multi-variable optimization: perishability decay rate, traffic travel corridors, and verified NGO kitchen capacities...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.charcoalMuted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.warmIvoryDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 15,
                    color: AppTheme.forestGreen,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'FSSAI Safe Food Chain Protocol Active',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.forestGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResults() {
    final urgency = _analysis.computedUrgency;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Urgency Card
          AppCard(
            backgroundColor: urgency == UrgencyLevel.critical
                ? AppTheme.statusCriticalBg.withValues(alpha: 0.4)
                : AppTheme.emeraldLight.withValues(alpha: 0.4),
            border: BorderSide(
              color: urgency == UrgencyLevel.critical
                  ? AppTheme.statusCritical
                  : AppTheme.emerald,
              width: 1.5,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: urgency == UrgencyLevel.critical
                        ? AppTheme.statusCritical
                        : AppTheme.forestGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    urgency == UrgencyLevel.critical
                        ? Icons.local_fire_department_rounded
                        : Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Urgency Score',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.charcoalMuted,
                            ),
                          ),
                          UrgencyBadge(level: urgency),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_analysis.urgencyScore} / 100',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: urgency == UrgencyLevel.critical
                              ? AppTheme.statusCritical
                              : AppTheme.forestGreen,
                        ),
                      ),
                      Text(
                        'Safe consumption window: ${widget.donation.formattedTimeRemaining}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.richCharcoal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Perishability & Guidelines
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.thermostat_rounded,
                      color: AppTheme.forestGreen,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Perishability & Cold-Chain Directive',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.richCharcoal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _analysis.perishabilitySummary,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.charcoalMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warmIvoryDark,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: AppTheme.forestGreen,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _analysis.temperatureGuideline,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.richCharcoal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Transparent Reasoning Summary
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.psychology_alt_rounded,
                      color: AppTheme.emeraldDark,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'AI Transparent Allocation Logic',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.richCharcoal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _analysis.transparentReasoning,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.charcoalMuted,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Mandatory Safety Disclaimer Guardrail
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.gavel_rounded, size: 18, color: Color(0xFFB45309)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AIAllocationAnalysis.safetyNotice,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF78350F),
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Proceed to view suggested NGOs
          AppButton(
            label: 'View ${_analysis.matches.length} Recommended NGOs',
            icon: Icons.volunteer_activism_rounded,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SuggestedNGOsScreen(
                    donation: widget.donation,
                    analysis: _analysis,
                    onConfirmed: widget.onConfirmed,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
