import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_card.dart';
import '../../../data/models/donation_model.dart';
import '../../../data/repositories/app_repository.dart';
import 'ngo_impact_screen.dart';

class DeliveryConfirmScreen extends StatefulWidget {
  final DonationModel donation;
  final AppRepository repository;

  const DeliveryConfirmScreen({
    super.key,
    required this.donation,
    required this.repository,
  });

  @override
  State<DeliveryConfirmScreen> createState() => _DeliveryConfirmScreenState();
}

class _DeliveryConfirmScreenState extends State<DeliveryConfirmScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _portionsController;
  final _beneficiaryTypeController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _portionsController = TextEditingController(
      text: widget.donation.quantityServings.toString(),
    );
  }

  @override
  void dispose() {
    _portionsController.dispose();
    _beneficiaryTypeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitDelivery() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final count =
        int.tryParse(_portionsController.text.trim()) ??
        widget.donation.quantityServings;

    final success = await widget.repository.confirmDelivery(
      donationId: widget.donation.id,
      distributionCount: count,
      deliveryNotes: _notesController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);

      if (success) {
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
                  Icons.celebration_rounded,
                  color: AppTheme.emerald,
                  size: 28,
                ),
                SizedBox(width: 10),
                Text('Meals Delivered!'),
              ],
            ),
            content: Text(
              '$count plates shared with people in need!\n\n'
              'You saved ${(count * 2.5).toStringAsFixed(1)} kg CO2 and kept good food out of the bin.',
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
            actions: [
              AppButton(
                label: 'See Total Meals Shared',
                icon: Icons.analytics_outlined,
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NGOImpactScreen(repository: widget.repository),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmIvory,
      appBar: AppBar(title: const Text('Confirm Delivery')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How many plates did you share?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppTheme.richCharcoal,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Save the meal count so the donor knows the food reached people.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.charcoalMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.donation.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.richCharcoal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order: ${widget.donation.quantityLabel}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.emeraldDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Plates Shared',
                        controller: _portionsController,
                        prefixIcon: Icons.restaurant_menu_rounded,
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required field' : null,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Where was it shared?',
                        hint: 'e.g. Night Shelter, Old Age Home',
                        controller: _beneficiaryTypeController,
                        prefixIcon: Icons.groups_rounded,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required field' : null,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Notes (Optional)',
                        hint: 'e.g. Everyone ate warm meals',
                        controller: _notesController,
                        prefixIcon: Icons.notes_rounded,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.warmIvoryDark,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.add_a_photo_rounded,
                              color: AppTheme.forestGreen,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Delivery Photo Attached',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.richCharcoal,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.check_circle_rounded,
                              color: AppTheme.emerald,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Complete Delivery',
                  icon: Icons.task_alt_rounded,
                  isLoading: _isSubmitting,
                  onPressed: _submitDelivery,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
