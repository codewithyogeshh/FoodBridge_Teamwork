import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/status_stepper_widget.dart';
import '../../core/widgets/map_preview_widget.dart';
import '../../../data/models/donation_model.dart';
import '../../../data/repositories/app_repository.dart';
import 'pickup_verify_action_screen.dart';

class PickupTrackingScreen extends StatelessWidget {
  final DonationModel donation;
  final AppRepository repository;

  const PickupTrackingScreen({
    super.key,
    required this.donation,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmIvory,
      appBar: AppBar(title: const Text('Active Pickup Tracking')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                donation.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.richCharcoal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pickup from: ${donation.donorName}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.emeraldDark,
                ),
              ),
              const SizedBox(height: 14),
              StatusStepperWidget(currentStatus: donation.status),
              const SizedBox(height: 18),

              // Full vector map with route
              MapPreviewWidget(
                height: 240,
                locationTitle: donation.pickupAddress,
                subtitle: 'Transit Route Active (ETA: 11 mins • 1.8 km)',
                showRoute: true,
                destinationTitle: 'Donor Kitchen Bay',
              ),
              const SizedBox(height: 18),

              // Turn-by-turn & Bay Directions
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.alt_route_rounded,
                          size: 18,
                          color: AppTheme.forestGreen,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Route & Bay Access Directive',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.richCharcoal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildRouteInstruction(
                      icon: Icons.turn_right_rounded,
                      instruction: 'Turn right onto Residency Rd (600m)',
                    ),
                    _buildRouteInstruction(
                      icon: Icons.straight_rounded,
                      instruction:
                          'Continue straight past Mayo Hall intersection (1.1 km)',
                    ),
                    _buildRouteInstruction(
                      icon: Icons.door_sliding_rounded,
                      instruction:
                          donation.pickupInstructions ??
                          'Enter via Service Gate 3 at rear. Thermal insulated food pans provided for transfer.',
                      isHighlight: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Donor Contact Card
              AppCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppTheme.warmIvoryDark,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 20,
                        color: AppTheme.forestGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            donation.donorName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.richCharcoal,
                            ),
                          ),
                          Text(
                            donation.donorPhone,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.charcoalMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.forestGreen,
                      ),
                      icon: const Icon(
                        Icons.phone_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Dialing donor kitchen at ${donation.donorPhone}...',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action button to verify pickup
              AppButton(
                label: 'Arrived at Donor Bay • Verify Hand-Off',
                icon: Icons.qr_code_scanner_rounded,
                variant: AppButtonVariant.primary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PickupVerifyActionScreen(
                        donation: donation,
                        repository: repository,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteInstruction({
    required IconData icon,
    required String instruction,
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: isHighlight ? AppTheme.forestGreen : AppTheme.charcoalMuted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              instruction,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
                color: isHighlight
                    ? AppTheme.forestGreen
                    : AppTheme.richCharcoal,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
