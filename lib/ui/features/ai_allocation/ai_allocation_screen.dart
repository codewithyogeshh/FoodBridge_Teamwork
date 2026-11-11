import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/state_widgets.dart';
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
  DonationModel? _selectedDonation;
  late AnimationController _animController;
  bool _isComputing = false;
  AIAllocationAnalysis? _analysis;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    final safeList = _safeDonations();
    if (safeList.isNotEmpty) {
      _selectedDonation = safeList.first;
      _runAIAnalysis();
    }
  }

  List<DonationModel> _safeDonations() {
    return widget.repository.donations.where((d) => d.isSafeToConsume).toList();
  }

  void _runAIAnalysis() async {
    final target = _selectedDonation;
    if (target == null) return;

    setState(() {
      _isComputing = true;
      _analysis = widget.repository.runAIAllocation(target);
    });

    await Future.delayed(const Duration(milliseconds: 700));
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
        final safeDonations = _safeDonations();
        final DonationModel? currentSelected = safeDonations.isEmpty
            ? null
            : safeDonations.firstWhere(
                (d) => d.id == _selectedDonation?.id,
                orElse: () => safeDonations.first,
              );

        final AIAllocationAnalysis? activeAnalysis = currentSelected == null
            ? null
            : (_analysis != null && _analysis!.donationId == currentSelected.id)
            ? _analysis
            : widget.repository.runAIAllocation(currentSelected);

        return Scaffold(
          backgroundColor: AppTheme.warmIvory,
          appBar: AppBar(
            title: const Text('Smart NGO Match'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh Match',
                onPressed: currentSelected == null ? null : _runAIAnalysis,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: safeDonations.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.auto_awesome_outlined,
                    title: 'No Active Food Orders',
                    message:
                        'Post extra food first to see the best nearby NGO matches.',
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.restrainedLime,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'SMART MATCHING',
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
                                'Find the Best NGO',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Matches each food batch with the closest verified NGO that has enough kitchen space.',
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

                        const Text(
                          'Choose Food Order:',
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
                              value: currentSelected!.id,
                              isExpanded: true,
                              items: safeDonations.map((d) {
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
                                    _selectedDonation = safeDonations
                                        .firstWhere((d) => d.id == newId);
                                  });
                                  _runAIAnalysis();
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        if (_isComputing || activeAnalysis == null)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.forestGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Finding best nearby NGOs for ${currentSelected.title}...',
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
                          AppCard(
                            backgroundColor:
                                activeAnalysis.computedUrgency ==
                                    UrgencyLevel.critical
                                ? AppTheme.statusCriticalBg.withValues(
                                    alpha: 0.3,
                                  )
                                : AppTheme.emeraldLight.withValues(alpha: 0.3),
                            border: BorderSide(
                              color:
                                  activeAnalysis.computedUrgency ==
                                      UrgencyLevel.critical
                                  ? AppTheme.statusCritical
                                  : AppTheme.emerald,
                              width: 1.5,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    UrgencyBadge(
                                      level: activeAnalysis.computedUrgency,
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Priority: ${activeAnalysis.urgencyScore}/100',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color:
                                            activeAnalysis.computedUrgency ==
                                                UrgencyLevel.critical
                                            ? AppTheme.statusCritical
                                            : AppTheme.forestGreen,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  currentSelected.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.richCharcoal,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${currentSelected.foodType} • ${currentSelected.quantityLabel} (${currentSelected.quantityServings} plates)',
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
                                  'Storage Tip: ${activeAnalysis.temperatureGuideline}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.richCharcoal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Top Nearby NGOs',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                  color: AppTheme.richCharcoal,
                                ),
                              ),
                              Text(
                                '${activeAnalysis.matches.length} matched',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.charcoalMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          ...activeAnalysis.matches.map((match) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AppCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        NGOVerifiedBadge(
                                          isVerified: match.ngo.isVerified,
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.limeLight,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
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
                                        const Icon(
                                          Icons.near_me_rounded,
                                          size: 13,
                                          color: AppTheme.charcoalMuted,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${match.distanceKm} km (~${match.estimatedTravelMinutes} mins)',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.charcoalMuted,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(
                                          Icons.soup_kitchen_rounded,
                                          size: 13,
                                          color: AppTheme.charcoalMuted,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Space: ${match.ngo.capacityMealsPerDay} plates/day',
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
                                      'Why this NGO:',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.richCharcoal,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ...match.matchReasons.map(
                                      (r) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 2,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Icons
                                                  .check_circle_outline_rounded,
                                              size: 13,
                                              color: AppTheme.emerald,
                                            ),
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
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 16),

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
                                Icon(
                                  Icons.gavel_rounded,
                                  size: 18,
                                  color: Color(0xFFB45309),
                                ),
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
