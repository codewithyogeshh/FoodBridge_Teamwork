import 'package:flutter/material.dart';
import '../theme.dart';
import '../constants.dart';

class StatusStepperWidget extends StatelessWidget {
  final DonationStatus currentStatus;

  const StatusStepperWidget({super.key, required this.currentStatus});

  int get _currentStepIndex {
    switch (currentStatus) {
      case DonationStatus.available:
        return 0;
      case DonationStatus.reserved:
        return 1;
      case DonationStatus.pickupVerified:
        return 2;
      case DonationStatus.delivered:
        return 3;
      case DonationStatus.cancelled:
      case DonationStatus.expired:
        return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentStatus == DonationStatus.cancelled ||
        currentStatus == DonationStatus.expired) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.statusCriticalBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppTheme.statusCritical, size: 20),
            const SizedBox(width: 8),
            Text(
              'This donation is currently ${currentStatus.dbValue}',
              style: const TextStyle(
                color: AppTheme.statusCritical,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    final steps = [
      {'title': 'Available', 'icon': Icons.inventory_2_outlined},
      {'title': 'Reserved', 'icon': Icons.lock_clock_outlined},
      {'title': 'Picked Up', 'icon': Icons.local_shipping_outlined},
      {'title': 'Delivered', 'icon': Icons.check_circle_outline_rounded},
    ];

    final currentIndex = _currentStepIndex;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.warmIvoryDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final lineIndex = index ~/ 2;
            final isPassed = currentIndex > lineIndex;
            return Expanded(
              child: Container(
                height: 3,
                color: isPassed
                    ? AppTheme.forestGreen
                    : Colors.grey.shade300,
              ),
            );
          }

          final stepIdx = index ~/ 2;
          final isCompleted = currentIndex >= stepIdx;
          final isCurrent = currentIndex == stepIdx;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AppTheme.forestGreen
                      : Colors.white,
                  border: Border.all(
                    color: isCompleted
                        ? AppTheme.forestGreen
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isCompleted && !isCurrent
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Icon(
                          steps[stepIdx]['icon'] as IconData,
                          size: 15,
                          color: isCompleted ? Colors.white : AppTheme.charcoalLight,
                        ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                steps[stepIdx]['title'] as String,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  color: isCompleted
                      ? AppTheme.richCharcoal
                      : AppTheme.charcoalLight,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
