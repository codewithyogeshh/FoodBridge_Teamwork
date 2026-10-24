import 'package:flutter/material.dart';
import '../theme.dart';

enum AppButtonVariant { primary, secondary, outline, text, danger }

/// Clean Modern Ergonomic Button (UberEats / Airbnb Style)
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;
    List<BoxShadow>? shadow;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = AppTheme.forestGreen; // #059669
        fg = Colors.white;
        shadow = [
          BoxShadow(
            color: const Color(0xFF059669).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];
        break;
      case AppButtonVariant.secondary:
        bg = AppTheme.emeraldLight; // #ECFDF5
        fg = AppTheme.forestGreen; // #059669
        border = BorderSide(
          color: AppTheme.forestGreen.withValues(alpha: 0.25),
          width: 1.2,
        );
        break;
      case AppButtonVariant.outline:
        bg = Colors.transparent;
        fg = AppTheme.forestGreen;
        border = const BorderSide(
          color: AppTheme.forestGreen,
          width: 1.5,
        );
        break;
      case AppButtonVariant.text:
        bg = Colors.transparent;
        fg = AppTheme.forestGreen;
        break;
      case AppButtonVariant.danger:
        bg = AppTheme.statusCritical;
        fg = Colors.white;
        shadow = [
          BoxShadow(
            color: AppTheme.statusCritical.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ];
        break;
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ],
    );

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: onPressed == null ? null : shadow,
      ),
      child: Material(
        color: onPressed == null ? Colors.grey.shade300 : bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: border,
        ),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(child: content),
        ),
      ),
    );
  }
}
