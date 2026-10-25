import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_card.dart';

class NGOSignInTab extends StatelessWidget {
  final TextEditingController controller;
  final bool isCheckingAccount;
  final String? errorText;
  final VoidCallback onSignIn;
  final VoidCallback onSwitchToRegister;

  const NGOSignInTab({
    super.key,
    required this.controller,
    required this.isCheckingAccount,
    this.errorText,
    required this.onSignIn,
    required this.onSwitchToRegister,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.emeraldLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.volunteer_activism_rounded,
              size: 28,
              color: AppTheme.forestGreen,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Sign In to Your NGO Account',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppTheme.richCharcoal,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'If your organization has already registered, enter your official phone number or 80G registration ID below. You do not need to register again.',
            style: TextStyle(
              fontSize: 13.5,
              color: AppTheme.charcoalMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  label: 'Official Phone Number or 80G Registration ID',
                  hint: 'e.g. +91 9XXXXXXXXX or NGO-KA-2024-XXXX',
                  controller: controller,
                  prefixIcon: Icons.badge_rounded,
                ),
                const SizedBox(height: 14),
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
                        Icons.shield_outlined,
                        size: 20,
                        color: AppTheme.forestGreen,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Your credentials are kept strictly private. Enter your registered mobile number or registration ID to access your account.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.charcoalMuted,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (errorText != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.statusCritical),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppTheme.statusCritical,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            errorText!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.statusCritical,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                AppButton(
                  label: 'Sign In & Verify Access',
                  icon: Icons.arrow_forward_rounded,
                  isLoading: isCheckingAccount,
                  onPressed: onSignIn,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              label: const Text(
                'New to FoodBridge? Register Organization here',
              ),
              onPressed: onSwitchToRegister,
            ),
          ),
        ],
      ),
    );
  }
}
