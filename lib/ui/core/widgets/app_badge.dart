import 'package:flutter/material.dart';
import '../theme.dart';
import '../constants.dart';

class UrgencyBadge extends StatelessWidget {
  final UrgencyLevel level;
  final bool compact;

  const UrgencyBadge({
    super.key,
    required this.level,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (level) {
      case UrgencyLevel.critical:
        bg = AppTheme.statusCriticalBg;
        fg = AppTheme.statusCritical;
        label = 'Critical (< 3h)';
        icon = Icons.local_fire_department_rounded;
        break;
      case UrgencyLevel.high:
        bg = AppTheme.statusHighBg;
        fg = AppTheme.statusHigh;
        label = 'High Priority';
        icon = Icons.access_time_filled_rounded;
        break;
      case UrgencyLevel.medium:
        bg = AppTheme.statusMediumBg;
        fg = AppTheme.statusMedium;
        label = 'Standard (12-24h)';
        icon = Icons.schedule_rounded;
        break;
      case UrgencyLevel.low:
        bg = const Color(0xFFF3F4F6);
        fg = AppTheme.charcoalMuted;
        label = 'Shelf Stable';
        icon = Icons.inventory_2_rounded;
        break;
    }

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
            Text(
              level.name.toUpperCase(),
              style: TextStyle(
                color: fg,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final DonationStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case DonationStatus.available:
        bg = AppTheme.statusSuccessBg;
        fg = AppTheme.statusSuccess;
        label = 'Available';
        break;
      case DonationStatus.reserved:
        bg = const Color(0xFFEEF2FF);
        fg = const Color(0xFF4F46E5);
        label = 'Reserved';
        break;
      case DonationStatus.pickupVerified:
        bg = AppTheme.statusHighBg;
        fg = AppTheme.statusHigh;
        label = 'Pickup Verified';
        break;
      case DonationStatus.delivered:
        bg = AppTheme.emeraldLight;
        fg = AppTheme.forestGreen;
        label = 'Delivered';
        break;
      case DonationStatus.cancelled:
        bg = const Color(0xFFF3F4F6);
        fg = AppTheme.charcoalMuted;
        label = 'Cancelled';
        break;
      case DonationStatus.expired:
        bg = AppTheme.statusCriticalBg;
        fg = AppTheme.statusCritical;
        label = 'Expired';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class NGOVerifiedBadge extends StatelessWidget {
  final bool isVerified;

  const NGOVerifiedBadge({super.key, required this.isVerified});

  @override
  Widget build(BuildContext context) {
    if (isVerified) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppTheme.emeraldLight,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_rounded, size: 13, color: AppTheme.forestGreen),
            SizedBox(width: 4),
            Text(
              'FSSAI Verified',
              style: TextStyle(
                color: AppTheme.forestGreen,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.statusHighBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_top_rounded, size: 13, color: AppTheme.statusHigh),
          SizedBox(width: 4),
          Text(
            'Verification Pending',
            style: TextStyle(
              color: AppTheme.statusHigh,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
