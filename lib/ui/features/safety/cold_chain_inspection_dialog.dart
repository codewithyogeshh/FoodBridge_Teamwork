import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_button.dart';
import '../../../data/services/offline_sync_service.dart';

class ColdChainInspectionDialog extends StatefulWidget {
  final String donationTitle;
  final void Function(double temperature, bool isPassed)? onVerified;

  const ColdChainInspectionDialog({
    super.key,
    required this.donationTitle,
    this.onVerified,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String donationTitle,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ColdChainInspectionDialog(donationTitle: donationTitle),
    );
  }

  @override
  State<ColdChainInspectionDialog> createState() =>
      _ColdChainInspectionDialogState();
}

class _ColdChainInspectionDialogState extends State<ColdChainInspectionDialog> {
  double _temperature = 65.0; // Default safe hot zone
  bool _odorFreshness = true;
  bool _sealedContainer = true;
  bool _fssaiCompliance = true;

  Color get _zoneColor {
    if (_temperature >= 60.0) return const Color(0xFF16A34A); // Safe Hot
    if (_temperature <= 5.0) return const Color(0xFF0284C7); // Safe Cold
    return const Color(0xFFDC2626); // Danger Zone
  }

  String get _zoneLabel {
    if (_temperature >= 60.0) return 'SAFE HOT ZONE (>60°C) • FSSAI COMPLIANT';
    if (_temperature <= 5.0) return 'SAFE CHILLED ZONE (<5°C) • FSSAI COMPLIANT';
    return '⚠️ BACTERIAL DANGER ZONE (5°C - 60°C)';
  }

  String get _zoneExplanation {
    if (_temperature >= 60.0) {
      return 'Microbiological proliferation is effectively halted. Suitable for direct distribution to shelter inmates.';
    }
    if (_temperature <= 5.0) {
      return 'Chilled preservation maintained. Must be kept refrigerated until reheating.';
    }
    return 'CRITICAL WARNING: Pathogenic bacteria proliferate rapidly between 5°C and 60°C. Food must be consumed within 90 minutes or discarded under Section 16 of Food Safety Regulations.';
  }

  @override
  Widget build(BuildContext context) {
    final bool passesInspection =
        (_temperature >= 60.0 || _temperature <= 5.0) &&
            _odorFreshness &&
            _sealedContainer &&
            _fssaiCompliance;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppTheme.cardSurface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _zoneColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.thermostat_rounded,
                        color: _zoneColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FSSAI Cold Chain Thermal Audit',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.richCharcoal),
                        ),
                        Text(
                          'Mandatory Food Safety & Standards Handoff Protocol',
                          style: TextStyle(
                              fontSize: 11, color: AppTheme.charcoalMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                'Manifest: ${widget.donationTitle}',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.forestGreen),
              ),
              const SizedBox(height: 14),

              // TEMPERATURE GAUGE CARD
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _zoneColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _zoneColor.withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Digital Thermal Probe:',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.richCharcoal)),
                        Text(
                          '${_temperature.toStringAsFixed(1)} °C',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: _zoneColor),
                        ),
                      ],
                    ),
                    Slider(
                      value: _temperature,
                      min: -5.0,
                      max: 95.0,
                      divisions: 100,
                      activeColor: _zoneColor,
                      inactiveColor: Colors.grey.shade300,
                      label: '${_temperature.toStringAsFixed(1)} °C',
                      onChanged: (val) => setState(() => _temperature = val),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _zoneColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _zoneLabel,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _zoneExplanation,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 10,
                          color: _zoneColor,
                          fontWeight: FontWeight.w500,
                          height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // FSSAI CHECKLIST
              const Text(
                'Physical Inspection Protocol',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.richCharcoal),
              ),
              const SizedBox(height: 6),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeColor: AppTheme.forestGreen,
                title: const Text(
                  'Visual & Odor Verification: No off-smell, foam, or discoloration',
                  style: TextStyle(fontSize: 12, color: AppTheme.richCharcoal),
                ),
                value: _odorFreshness,
                onChanged: (v) => setState(() => _odorFreshness = v ?? false),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeColor: AppTheme.forestGreen,
                title: const Text(
                  'Insulated Packaging: Food packed in sealed, food-grade containers',
                  style: TextStyle(fontSize: 12, color: AppTheme.richCharcoal),
                ),
                value: _sealedContainer,
                onChanged: (v) => setState(() => _sealedContainer = v ?? false),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeColor: AppTheme.forestGreen,
                title: const Text(
                  'Good Samaritan Protection: Donor certified surplus from licensed kitchen',
                  style: TextStyle(fontSize: 12, color: AppTheme.richCharcoal),
                ),
                value: _fssaiCompliance,
                onChanged: (v) => setState(() => _fssaiCompliance = v ?? false),
              ),
              const SizedBox(height: 18),

              // SUBMIT BUTTON
              AppButton(
                label: passesInspection
                    ? 'Certify & Record Handoff'
                    : 'Inspection Incomplete / Safety Alert',
                icon: passesInspection
                    ? Icons.verified_user_rounded
                    : Icons.warning_rounded,
                onPressed: passesInspection
                    ? () {
                        OfflineSyncService.instance.enqueueAction(
                          'THERMAL_LOG',
                          {
                            'donation': widget.donationTitle,
                            'temperature': _temperature,
                            'timestamp': DateTime.now().toIso8601String(),
                            'certified': true,
                          },
                        );
                        widget.onVerified?.call(_temperature, true);
                        Navigator.pop(context, true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'FSSAI Thermal Audit Certified (${_temperature.toStringAsFixed(1)}°C). Handoff synchronized!'),
                            backgroundColor: AppTheme.forestGreen,
                          ),
                        );
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
