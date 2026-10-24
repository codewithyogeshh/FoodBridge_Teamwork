import 'package:flutter/material.dart';
import '../theme.dart';

/// Clean Modern Light Card Container (UberEats / Airbnb style)
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final BorderSide? border;
  final bool isElevated;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.backgroundColor,
    this.border,
    this.isElevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveBg = backgroundColor ?? AppTheme.cardSurface;

    return Container(
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.fromBorderSide(
          border ?? const BorderSide(color: AppTheme.borderColor, width: 1),
        ),
        boxShadow: isElevated ? AppTheme.cardElevation : AppTheme.subtleShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
