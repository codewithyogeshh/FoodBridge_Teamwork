import 'package:flutter/material.dart';
import '../theme.dart';
import 'app_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.warmIvoryDark,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Icon(icon, size: 40, color: AppTheme.charcoalMuted),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.richCharcoal,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.charcoalMuted,
                height: 1.4,
              ),
            ),
            if (buttonLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              AppButton(label: buttonLabel!, onPressed: onAction, width: 180),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingStateWidget extends StatelessWidget {
  final String message;

  const LoadingStateWidget({
    super.key,
    this.message = 'Loading verified data...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 38,
              height: 38,
              child: CircularProgressIndicator(
                strokeWidth: 3.2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.forestGreen),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.charcoalMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 44,
              color: AppTheme.statusHigh,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to reach live cloud database',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.richCharcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.charcoalMuted,
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Retry Connection',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
              variant: AppButtonVariant.outline,
              width: 170,
            ),
          ],
        ),
      ),
    );
  }
}
