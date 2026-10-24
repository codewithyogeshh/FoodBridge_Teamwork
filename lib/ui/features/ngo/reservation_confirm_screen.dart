import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../../data/models/donation_model.dart';
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

  void _confirmLock() async {
    setState(() {
      _isLocking = true;
      _statusMessage = 'Executing PostgreSQL atomic lock...';
    });

    final currentNgo = widget.repository.verifiedNGOs.isNotEmpty
        ? widget.repository.verifiedNGOs.first
        : widget.repository.ngos.first;

    final result = await widget.repository.reserveDonation(
      donationId: widget.donation.id,
      ngoId: currentNgo.id,
      ngoName: currentNgo.organizationName,
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
                Text('Reservation Locked!'),
              ],
            ),
            content: Text(
              'Atomic lock acquired on donation #${widget.donation.id.substring(0, 8)}.\n\n'
              'No other organization can reserve this batch. Please dispatch your vehicle for pickup before safe window ends.',
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
            actions: [
              AppButton(
                label: 'Track Pickup Route Now',
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
            content: Text(result['message'] ?? 'Failed to lock reservation'),
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
      appBar: AppBar(title: const Text('Confirm Food Reservation')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Confirm Batch Commitment',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppTheme.richCharcoal,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Once locked, this surplus batch is committed exclusively to your organization to prevent food waste and double-dispatch.',
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
                      'Portions Committed',
                      '${widget.donation.quantityServings} Meals',
                    ),
                    _buildRow(
                      'Pickup Deadline',
                      widget.donation.formattedTimeRemaining,
                    ),
                    _buildRow('Pickup Address', widget.donation.pickupAddress),
                    _buildRow(
                      'Handling Condition',
                      widget.donation.storageRequirements ?? 'Standard Safe',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Atomic Locking Technical Guarantee Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.emerald),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_clock_rounded,
                      color: AppTheme.forestGreen,
                      size: 22,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Atomic Locking Active',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.forestGreen,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Uses row-level PostgreSQL transaction locking (SELECT FOR UPDATE). Prevents race conditions and multiple reservations across concurrent NGO requests.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.richCharcoal,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Confirm button
              AppButton(
                label: 'Confirm & Lock Reservation Now',
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
