import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_badge.dart';
import '../../../data/models/donation_model.dart';
import '../../../data/models/ai_recommendation_model.dart';
import '../../../data/repositories/app_repository.dart';

class AIAllocationScreen extends StatefulWidget {
  final AppRepository repository;

  const AIAllocationScreen({super.key, required this.repository});

  @override
  State<AIAllocationScreen> createState() => _AIAllocationScreenState();
}

class _AIAllocationScreenState extends State<AIAllocationScreen>
    with SingleTickerProviderStateMixin {
  late DonationModel _selectedDonation;
  late AnimationController _animController;
  bool _isComputing = false;
  late AIAllocationAnalysis _analysis;

  @override
  void initState() {
    super.initState();
    _selectedDonation = widget.repository.donations.first;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _runAIAnalysis();
  }

  void _runAIAnalysis() async {
    setState(() => _isComputing = true);
    _analysis = widget.repository.runAIAllocation(_selectedDonation);

    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      setState(() => _isComputing = false);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repository,
      builder: (context, _) {
        final allDonations = widget.repository.donations;

        return Scaffold(
          backgroundColor: AppTheme.warmIvory,
          appBar: AppBar(
            title: const Text('Signature AI Allocation Engine'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Re-run Neural Match',
                onPressed: _runAIAnalysis,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Neural Network Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.forestGreen,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: AppTheme.cardElevation,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.restrainedLime,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'INTELLIGENT SURPLUS ALLOCATION',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.forestGreen,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            const Spacer(),
                            RotationTransition(
                              turns: _animController,
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: AppTheme.restrainedLime,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Multi-Factor Surplus Routing',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Dynamically balances food perishability kinetics, traffic transit corridors, and verified community kitchen capacities to maximize zero-waste rescue.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Select Batch to Analyze
                  const Text(
                    'Select Food Batch to Analyze:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.richCharcoal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedDonation.id,
                        isExpanded: true,
                        items: allDonations.map((d) {
                          return DropdownMenuItem(
                            value: d.id,
                            child: Text(
                              '${d.title} (${d.quantityLabel})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.richCharcoal,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (newId) {
                          if (newId != null) {
                            setState(() {
                              _selectedDonation = allDonations
                                  .firstWhere((d) => d.id == newId);
                            });
                            _runAIAnalysis();
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (_isComputing)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.forestGreen),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Evaluating verified regional recipient network for ${_selectedDonation.title}...',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.charcoalMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    // Perishability Assessment Card
                    AppCard(
                      backgroundColor:
                          _analysis.computedUrgency == UrgencyLevel.critical
                              ? AppTheme.statusCriticalBg.withValues(alpha: 0.3)
                              : AppTheme.emeraldLight.withValues(alpha: 0.3),
                      border: BorderSide(
                        color: _analysis.computedUrgency == UrgencyLevel.critical
                            ? AppTheme.statusCritical
                            : AppTheme.emerald,
                        width: 1.5,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              UrgencyBadge(level: _analysis.computedUrgency),
                              const Spacer(),
                              Text(
                                'Match Score: ${_analysis.urgencyScore}/100',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: _analysis.computedUrgency ==
                                          UrgencyLevel.critical
                                      ? AppTheme.statusCritical
                                      : AppTheme.forestGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _selectedDonation.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.richCharcoal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Category: ${_selectedDonation.foodType} • Quantity: ${_selectedDonation.quantityLabel} (${_selectedDonation.quantityServings} servings)',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppTheme.charcoalMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: AppTheme.borderColor),
                          const SizedBox(height: 8),
                          Text(
                            'Thermal Handling: ${_analysis.temperatureGuideline}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.richCharcoal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Perishability: ${_analysis.perishabilitySummary}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.charcoalMuted,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Ranked Recommended Verified NGOs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ranked Verified Recipient NGOs',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: AppTheme.richCharcoal,
                          ),
                        ),
                        Text(
                          '${_analysis.matches.length} matched',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.charcoalMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    ..._analysis.matches.map((match) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  NGOVerifiedBadge(
                                      isVerified: match.ngo.isVerified),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppTheme.limeLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${match.matchScore}% Match',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.limeDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                match.ngo.organizationName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.richCharcoal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.near_me_rounded,
                                      size: 13, color: AppTheme.charcoalMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${match.distanceKm} km (~${match.estimatedTravelMinutes} mins travel)',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.charcoalMuted,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.soup_kitchen_rounded,
                                      size: 13, color: AppTheme.charcoalMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Cap: ${match.ngo.capacityMealsPerDay} meals/day',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.charcoalMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Clear Allocation Rationale:',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.richCharcoal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ...match.matchReasons.map((r) => Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                            Icons.check_circle_outline_rounded,
                                            size: 13,
                                            color: AppTheme.emerald),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            r,
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color: AppTheme.charcoalMuted,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),

                    // Transparent Summary Card
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.psychology_alt_rounded,
                                  color: AppTheme.forestGreen, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Recommendation Summary',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.richCharcoal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _analysis.transparentReasoning,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppTheme.charcoalMuted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Explicit Food Safety Guardrail
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
                          Icon(Icons.gavel_rounded,
                              size: 18, color: Color(0xFFB45309)),
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
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
