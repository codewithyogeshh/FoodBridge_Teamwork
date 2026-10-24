import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/qr_code_widget.dart';
import '../../../data/models/donation_model.dart';

class PickupVerificationScreen extends StatelessWidget {
  final DonationModel donation;

  const PickupVerificationScreen({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmIvory,
      appBar: AppBar(title: const Text('Digital Pickup Passcode')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              Text(
                donation.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.richCharcoal,
                ),
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
              const SizedBox(height: 24),

              // Visual QR Code Card
              QRCodeWidget(
                otpCode: donation.pickupOtp,
                donationTitle: donation.title,
                size: 220,
              ),
              const SizedBox(height: 28),

              // Chain-of-Custody Instructions
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.security_rounded,
                          size: 18,
                          color: AppTheme.forestGreen,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Chain of Custody Protocol',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.richCharcoal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildStep(
                      num: '1',
                      text:
                          'Verify the arriving driver represents the registered NGO.',
                    ),
                    const SizedBox(height: 8),
                    _buildStep(
                      num: '2',
                      text:
                          'Ask the driver to scan this QR code or input the 4-digit OTP.',
                    ),
                    const SizedBox(height: 8),
                    _buildStep(
                      num: '3',
                      text:
                          'Hand off insulated food pans only after driver phone shows verified confirmation.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Verification Safety Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.emerald),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      size: 16,
                      color: AppTheme.forestGreen,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Cryptographic Handoff Secured by Supabase RLS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.forestGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep({required String num, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.warmIvoryDark,
          ),
          child: Center(
            child: Text(
              num,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.forestGreen,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppTheme.charcoalMuted,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
