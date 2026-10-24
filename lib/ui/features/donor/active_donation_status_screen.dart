import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/status_stepper_widget.dart';
import '../../core/widgets/map_preview_widget.dart';
import '../../../data/models/donation_model.dart';
import 'pickup_verification_screen.dart';

class ActiveDonationStatusScreen extends StatelessWidget {
  final DonationModel donation;

  const ActiveDonationStatusScreen({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    final isReserved = donation.status == DonationStatus.reserved;
    final isPickedUp = donation.status == DonationStatus.pickupVerified;
    final isDelivered = donation.status == DonationStatus.delivered;

    return Scaffold(
      backgroundColor: AppTheme.warmIvory,
      appBar: AppBar(
        title: const Text('Live Donation Tracking'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food Title & Status Stepper
              Row(
                children: [
                  Expanded(
                    child: Text(
                      donation.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppTheme.richCharcoal,
                      ),
                    ),
                  ),
                  StatusBadge(status: donation.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${donation.foodType} • ${donation.quantityLabel}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.emeraldDark,
                ),
              ),
              if (donation.imageUrl != null && donation.imageUrl!.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      Image.network(
                        donation.imageUrl!,
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.photo_camera_rounded, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'Uploaded Batch Photo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              StatusStepperWidget(currentStatus: donation.status),
              const SizedBox(height: 20),

              // Live Transit Map
              MapPreviewWidget(
                height: 200,
                locationTitle: donation.pickupAddress,
                subtitle: isReserved
                    ? 'Robin Hood Food Rescue vehicle in transit (ETA: 14 mins)'
                    : 'Awaiting local verified NGO reservation',
                showRoute: isReserved || isPickedUp,
                destinationTitle: 'Robin Hood Rescue Kitchen',
              ),
              const SizedBox(height: 20),

              // Reserved Organization Card (if reserved or picked up)
              if (isReserved || isPickedUp || isDelivered) ...[
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.directions_car_rounded,
                              size: 20, color: AppTheme.forestGreen),
                          SizedBox(width: 8),
                          Text(
                            'Assigned Rescuer',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.richCharcoal,
                            ),
                          ),
                          Spacer(),
                          NGOVerifiedBadge(isVerified: true),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Robin Hood Food Rescue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.richCharcoal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Driver: Arjun Verma (Volunteer Van • KA-03-MM-4491)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.charcoalMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppTheme.warmIvoryDark,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.timer_outlined,
                                    size: 14, color: AppTheme.forestGreen),
                                const SizedBox(width: 5),
                                Text(
                                  isPickedUp ? 'In Transit to Kitchen' : 'ETA: 14 mins',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.forestGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          IconButton.filled(
                            style: IconButton.styleFrom(
                              backgroundColor: AppTheme.forestGreen,
                            ),
                            icon: const Icon(Icons.phone_rounded,
                                size: 18, color: Colors.white),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Connecting call to Arjun Verma (+91 98450 67890)...'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Pickup Passcode Card
              AppCard(
                backgroundColor: AppTheme.emeraldLight.withValues(alpha: 0.2),
                border: const BorderSide(color: AppTheme.emerald, width: 1.5),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppTheme.forestGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.qr_code_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'One-Time Pickup Passcode',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.richCharcoal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Display code or QR when driver arrives',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      donation.pickupOtp,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.forestGreen,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action button to open full QR
              AppButton(
                label: 'Open Fullscreen Pickup QR & Passcode',
                icon: Icons.fullscreen_rounded,
                variant: AppButtonVariant.primary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PickupVerificationScreen(
                        donation: donation,
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
}
