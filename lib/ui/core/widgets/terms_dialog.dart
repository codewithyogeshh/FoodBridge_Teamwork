import 'package:flutter/material.dart';
import '../theme.dart';
import 'app_button.dart';

class TermsAndConditionsDialog extends StatefulWidget {
  final VoidCallback onAccepted;
  final VoidCallback onDeclined;

  const TermsAndConditionsDialog({
    super.key,
    required this.onAccepted,
    required this.onDeclined,
  });

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => TermsAndConditionsDialog(
        onAccepted: () => Navigator.of(ctx).pop(true),
        onDeclined: () => Navigator.of(ctx).pop(false),
      ),
    );
  }

  @override
  State<TermsAndConditionsDialog> createState() =>
      _TermsAndConditionsDialogState();
}

class _TermsAndConditionsDialogState extends State<TermsAndConditionsDialog> {
  bool _agreedToTerms = false;
  bool _agreedToSafetyCharter = false;

  bool get _canProceed => _agreedToTerms && _agreedToSafetyCharter;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppTheme.cardSurface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 680),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.gavel_rounded,
                    color: AppTheme.forestGreen,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Food Safety & App Rules',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.richCharcoal,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Please read and agree before continuing',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.charcoalMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),

            // Terms Content (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      icon: Icons.shield_outlined,
                      title: '1. Share Only Fresh Food',
                      body:
                          'Donors share extra food in good faith to help people in need. Make sure food is clean, fresh, and safe to eat.',
                    ),
                    const SizedBox(height: 12),
                    _buildSection(
                      icon: Icons.thermostat_rounded,
                      title: '2. Keep Food Hot or Cold',
                      body:
                          'NGOs and helpers must store food properly and serve cooked meals before the Best Before time.',
                    ),
                    const SizedBox(height: 12),
                    _buildSection(
                      icon: Icons.auto_awesome_rounded,
                      title: '3. Always Check Before Serving',
                      body:
                          'App estimates help pick the fastest match, but NGOs and helpers must always check food freshness by smell and look before serving.',
                    ),
                    const SizedBox(height: 12),
                    _buildSection(
                      icon: Icons.money_off_rounded,
                      title: '4. Always Free of Cost',
                      body:
                          'Food shared on FoodBridge must be given free to shelters and people in need. Selling donated food is strictly not allowed.',
                    ),
                  ],
                ),
              ),
            ),

            const Divider(),
            const SizedBox(height: 10),

            // Checkboxes
            InkWell(
              onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      activeColor: AppTheme.forestGreen,
                      onChanged: (v) =>
                          setState(() => _agreedToTerms = v ?? false),
                    ),
                    const Expanded(
                      child: Text(
                        'I accept the Terms of Service & Privacy Policy.',
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
            ),
            InkWell(
              onTap: () => setState(
                () => _agreedToSafetyCharter = !_agreedToSafetyCharter,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Checkbox(
                      value: _agreedToSafetyCharter,
                      activeColor: AppTheme.forestGreen,
                      onChanged: (v) =>
                          setState(() => _agreedToSafetyCharter = v ?? false),
                    ),
                    const Expanded(
                      child: Text(
                        'I agree to check food freshness before serving.',
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
            ),
            const SizedBox(height: 14),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.charcoalMuted,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: widget.onDeclined,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    label: 'I Agree & Continue',
                    icon: Icons.check_rounded,
                    onPressed: _canProceed ? widget.onAccepted : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warmIvoryDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.forestGreen),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.richCharcoal,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.charcoalMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
