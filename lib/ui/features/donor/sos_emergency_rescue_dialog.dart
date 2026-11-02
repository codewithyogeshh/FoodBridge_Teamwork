import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../../data/models/donation_model.dart';
import '../../../data/repositories/app_repository.dart';
import '../../../data/services/dispatch_webhook_service.dart';

class SOSEmergencyRescueDialog extends StatefulWidget {
  final AppRepository repository;
  final void Function(DonationModel created)? onDonationCreated;

  const SOSEmergencyRescueDialog({
    super.key,
    required this.repository,
    this.onDonationCreated,
  });

  static Future<void> show(
    BuildContext context, {
    required AppRepository repository,
    void Function(DonationModel created)? onDonationCreated,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SOSEmergencyRescueDialog(
        repository: repository,
        onDonationCreated: onDonationCreated,
      ),
    );
  }

  @override
  State<SOSEmergencyRescueDialog> createState() =>
      _SOSEmergencyRescueDialogState();
}

class _SOSEmergencyRescueDialogState extends State<SOSEmergencyRescueDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _sirenController;
  late Animation<double> _sirenAnimation;

  final _foodDescController = TextEditingController(
    text:
        'Full Wedding Feast: Shahi Paneer, Jeera Rice, Dal Makhani & 150 Naans',
  );
  int _selectedPortions = 300;
  bool _isBroadcasting = false;

  @override
  void initState() {
    super.initState();
    _sirenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _sirenAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _sirenController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _sirenController.dispose();
    _foodDescController.dispose();
    super.dispose();
  }

  void _triggerEmergencyBlast() async {
    setState(() => _isBroadcasting = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final now = DateTime.now();
    final donor = widget.repository.currentUser;

    final sosDonation = DonationModel(
      id: 'sos-${now.millisecondsSinceEpoch}',
      donorName: donor.organizationName ?? donor.fullName,
      donorPhone: donor.phone,
      title:
          '🚨 MASS SOS: ${_foodDescController.text.trim()} ($_selectedPortions portions)',
      foodType: 'Cooked Meals',
      quantityLabel: '$_selectedPortions Plates (Wedding Banquet)',
      quantityServings: _selectedPortions,
      preparedAt: now.subtract(const Duration(hours: 1)),
      safeUntil: now.add(const Duration(hours: 3)),
      storageRequirements: 'Hot Insulated Containers (>65°C)',
      allergens: const ['Dairy', 'Gluten', 'Nuts'],
      pickupAddress: 'Grand Orchid Convention Hall, MG Road Corridor',
      pickupLatitude: 12.9716,
      pickupLongitude: 77.5946,
      pickupInstructions:
          'Enter Gate 2 Banquet Kitchen. Security notified for immediate courier access.',
      pickupOtp: '${(1000 + (now.millisecondsSinceEpoch % 9000))}',
      urgencyLevel: UrgencyLevel.critical,
      aiUrgencyScore: 99,
      aiRecommendationSummary:
          '🚨 EMERGENCY ALLOCATION: Dispatched to Hope Care Foundation, Annam Kitchen & 14 verified 24x7 relief shelters within 10 km.',
      status: DonationStatus.available,
      requiresVolunteerDelivery: true,
      deliveryFee: 45.0,
      createdAt: now,
      updatedAt: now,
    );

    // Persist to repository
    final created = await widget.repository.createDonation(sosDonation);

    // Queue WhatsApp Dispatch Webhook Alert
    DispatchWebhookService.instance.triggerSurplusAlert(
      donationTitle: sosDonation.title,
      donorName: sosDonation.donorName,
      location: sosDonation.pickupAddress,
      safeUntilText: 'In 2.5 hours (Late-Night SOS)',
      servings: _selectedPortions,
      ngoName: 'Emergency Relief Network (10km Radius)',
    );

    setState(() => _isBroadcasting = false);

    if (!mounted) return;
    widget.onDonationCreated?.call(created);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🚨 SOS BROADCAST ACTIVE: $_selectedPortions meals broadcasted to 14 shelters & all online couriers!',
        ),
        backgroundColor: const Color(0xFFDC2626),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      backgroundColor: AppTheme.cardSurface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // EMERGENCY SIREN BANNER
              AnimatedBuilder(
                animation: _sirenAnimation,
                builder: (ctx, child) {
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(
                            0xFF991B1B,
                          ).withValues(alpha: _sirenAnimation.value),
                          const Color(0xFFDC2626),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFFDC2626,
                          ).withValues(alpha: 0.4 * _sirenAnimation.value),
                          blurRadius: 14,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.emergency_rounded,
                            color: Color(0xFFDC2626),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LATE-NIGHT EMERGENCY SOS RESCUE',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Instant priority alert to all 24x7 shelters & relief kitchens in 10 km',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),

              // QUANTITY CHIPS
              const Text(
                'Select Mass Surplus Batch Size',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.richCharcoal,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [150, 300, 500].map((count) {
                  final isSel = _selectedPortions == count;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(
                          '$count Plates',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isSel
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                        selected: isSel,
                        selectedColor: const Color(0xFFFFE4E6),
                        onSelected: (val) =>
                            setState(() => _selectedPortions = count),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // DESCRIPTION FIELD
              const Text(
                'Menu Details & Food State',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.richCharcoal,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _foodDescController,
                maxLines: 2,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Enter banquet feast details...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
              const SizedBox(height: 14),

              // 10 KM BLAST PROTOCOL NOTICE
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.radar_rounded,
                      color: Color(0xFFDC2626),
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '10 km Radius Radar Blast: Bypasses standard queues to wake on-call couriers and emergency shelter drivers.',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF991B1B),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ACTION BUTTONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _isBroadcasting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.campaign_rounded, size: 20),
                      label: Text(
                        _isBroadcasting
                            ? 'Broadcasting SOS...'
                            : 'Broadcast 10km SOS',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      onPressed: _isBroadcasting
                          ? null
                          : _triggerEmergencyBlast,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
