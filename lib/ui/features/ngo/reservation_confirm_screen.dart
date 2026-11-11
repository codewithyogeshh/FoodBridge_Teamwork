import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../../data/models/donation_model.dart';
import '../../../data/models/ngo_model.dart';
import '../../../data/repositories/app_repository.dart';
import 'pickup_tracking_screen.dart';

class ReservationConfirmScreen extends StatefulWidget {
  final DonationModel donation;
  final AppRepository repository;

  const ReservationConfirmScreen({
    super.key,
    required this.donation,
    required this.repository,
  });

  @override
  State<ReservationConfirmScreen> createState() =>
      _ReservationConfirmScreenState();
}

class _ReservationConfirmScreenState extends State<ReservationConfirmScreen> {
  bool _isLocking = false;
  String? _statusMessage;

  NGOModel _resolveCurrentNgo() {
    if (widget.repository.lastRegisteredNgo != null) {
      return widget.repository.lastRegisteredNgo!;
    }
    if (widget.repository.verifiedNGOs.isNotEmpty) {
      return widget.repository.verifiedNGOs.first;
    }
    if (widget.repository.ngos.isNotEmpty) {
      return widget.repository.ngos.first;
    }
    return NGOModel(
      id: 'ngo-1',
      organizationName:
          widget.repository.currentUser.organizationName ?? 'Hope Care Kitchen',
      registrationNumber: 'NGO-VERIFIED',
      contactPerson: widget.repository.currentUser.fullName,
      phone: widget.repository.currentUser.phone,
      address: 'Pune',
      latitude: 18.5204,
      longitude: 73.8567,
      verificationStatus: NGOVerificationStatus.verified,
      capacityMealsPerDay: 200,
      createdAt: DateTime.now(),
    );
  }

  void _confirmLock() async {
    setState(() {
      _isLocking = true;
      _statusMessage = 'Booking food for your NGO...';
    });

    final currentNgo = _resolveCurrentNgo();
    final distanceKm = currentNgo.distanceTo(
      widget.donation.pickupLatitude,
      widget.donation.pickupLongitude,
    );
    final hasOwnVolunteers = currentNgo.hasOwnVolunteers;
    final deliveryFee = currentNgo.calculateVolunteerDeliveryFee(distanceKm);

    final result = await widget.repository.reserveDonation(
      donationId: widget.donation.id,
      ngoId: currentNgo.id,
      ngoName: currentNgo.organizationName,
      requiresVolunteerDelivery: !hasOwnVolunteers,
      deliveryFee: deliveryFee,
    );

    if (mounted) {
      setState(() => _isLocking = false);

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
                Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.emerald,
                  size: 26,
                ),
                SizedBox(width: 10),
                Text('Food Booked!'),
              ],
            ),
            content: Text(
              hasOwnVolunteers
                  ? '${widget.donation.title} is booked for ${currentNgo.organizationName}.\n\n'
                        'Pickup: Your NGO team (₹0 fee).\n'
                        'Please pick up the food before time runs out.'
                  : '${widget.donation.title} is booked for ${currentNgo.organizationName}.\n\n'
                        'A delivery helper is requested (${distanceKm.toStringAsFixed(1)} km).\n'
                        'Delivery fee: ₹${deliveryFee.toStringAsFixed(0)} (pay helper on drop-off).',
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
            actions: [
              AppButton(
                label: 'Go to Pickup Map',
                icon: Icons.navigation_rounded,
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PickupTrackingScreen(
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
            content: Text(result['message'] ?? 'Could not book this food'),
            backgroundColor: AppTheme.statusCritical,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentNgo = _resolveCurrentNgo();
    final distanceKm = currentNgo.distanceTo(
      widget.donation.pickupLatitude,
      widget.donation.pickupLongitude,
    );
    final deliveryFee = currentNgo.calculateVolunteerDeliveryFee(distanceKm);
    final hasOwnVolunteers = currentNgo.hasOwnVolunteers;

    return Scaffold(
      backgroundColor: AppTheme.warmIvory,
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ready to Book?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppTheme.richCharcoal,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Once confirmed, this food is saved only for your NGO.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.charcoalMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Summary Card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.donation.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.richCharcoal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.donation.foodType} • ${widget.donation.quantityLabel}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.emeraldDark,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: AppTheme.borderColor),
                    const SizedBox(height: 10),
                    _buildRow(
                      'Plates',
                      '${widget.donation.quantityServings} Plates',
                    ),
                    _buildRow(
                      'Pick Up Within',
                      widget.donation.formattedTimeRemaining,
                    ),
                    _buildRow('Pickup Address', widget.donation.pickupAddress),
                    _buildRow(
                      'Storage',
                      widget.donation.storageRequirements ?? 'Keep Clean',
                    ),
                    _buildRow(
                      'Pickup By',
                      hasOwnVolunteers
                          ? 'Your NGO Team (Free)'
                          : 'Delivery Helper',
                    ),
                    if (!hasOwnVolunteers) ...[
                      _buildRow(
                        'Distance',
                        '${distanceKm.toStringAsFixed(1)} km',
                      ),
                      _buildRow(
                        'Delivery Fee',
                        '₹${deliveryFee.toStringAsFixed(0)} (Pay on delivery)',
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.emerald),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      color: AppTheme.forestGreen,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Booked only for your NGO — no other group can take this order.',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.richCharcoal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Confirm button
              AppButton(
                label: 'Confirm Booking',
                icon: Icons.check_circle_outline_rounded,
                isLoading: _isLocking,
                onPressed: _confirmLock,
              ),
              if (_statusMessage != null) ...[
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    _statusMessage!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.charcoalMuted,
                    ),
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

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppTheme.charcoalMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppTheme.richCharcoal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
