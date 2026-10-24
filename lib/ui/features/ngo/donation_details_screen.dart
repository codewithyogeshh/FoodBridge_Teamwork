import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/map_preview_widget.dart';
import '../../../data/models/donation_model.dart';
import '../../../data/repositories/app_repository.dart';
import 'reservation_confirm_screen.dart';

class DonationDetailsScreen extends StatelessWidget {
  final DonationModel donation;
  final AppRepository repository;

  const DonationDetailsScreen({
    super.key,
    required this.donation,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = donation.status == DonationStatus.available;

    return Scaffold(
      backgroundColor: AppTheme.warmIvory,
      appBar: AppBar(
        title: const Text('Donation Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card with Image (or Food Graphic)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.forestGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      if (donation.imageUrl != null)
                        Image.network(
                          donation.imageUrl!,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Center(
                            child: Icon(Icons.restaurant_rounded,
                                size: 56, color: Colors.white54),
                          ),
                        )
                      else
                        const Center(
                          child: Icon(Icons.restaurant_rounded,
                              size: 56, color: Colors.white54),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.75),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                UrgencyBadge(level: donation.urgencyLevel),
                                const Spacer(),
                                StatusBadge(status: donation.status),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              donation.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Quantity & Time Limit
              Row(
                children: [
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Portions Available',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.charcoalMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${donation.quantityServings} Portions',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.forestGreen,
                            ),
                          ),
                          Text(
                            donation.quantityLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.richCharcoal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Safe Window',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.charcoalMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            donation.formattedTimeRemaining,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: donation.urgencyLevel == UrgencyLevel.critical
                                  ? AppTheme.statusCritical
                                  : AppTheme.forestGreen,
                            ),
                          ),
                          Text(
                            'Prep: ${donation.foodType}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.richCharcoal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Storage and Handling
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.ac_unit_rounded,
                            size: 18, color: AppTheme.forestGreen),
                        SizedBox(width: 8),
                        Text(
                          'Thermal & Handling Protocol',
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
                      donation.storageRequirements ?? 'Ambient Food-Safe Storage',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.richCharcoal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Allergens Declared by Donor:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.charcoalMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (donation.allergens.isEmpty)
                      const Text(
                        'None reported by commercial kitchen.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.charcoalMuted,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: donation.allergens.map((allergen) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.warmIvoryDark,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppTheme.borderColor),
                            ),
                            child: Text(
                              allergen,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.richCharcoal,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Pickup Location & Map
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 18, color: AppTheme.forestGreen),
                        SizedBox(width: 8),
                        Text(
                          'Pickup Location & Gate Access',
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
                      donation.pickupAddress,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.richCharcoal,
                      ),
                    ),
                    if (donation.pickupInstructions != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Gate Note: ${donation.pickupInstructions}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.charcoalMuted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    MapPreviewWidget(
                      height: 160,
                      locationTitle: donation.pickupAddress,
                      subtitle: 'Donor Kitchen Pickup Bay',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action button (Reserve if available)
              if (isAvailable)
                AppButton(
                  label: 'Reserve This Food Batch (Atomic Lock)',
                  icon: Icons.lock_clock_rounded,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReservationConfirmScreen(
                          donation: donation,
                          repository: repository,
                        ),
                      ),
                    );
                  },
                )
              else
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.warmIvoryDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'This food batch is currently ${donation.status.dbValue}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.charcoalMuted,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
