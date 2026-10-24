import 'package:flutter/material.dart';
import '../theme.dart';

/// Clean Modern Light Input Field (UberEats / Airbnb Style)
class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.maxLines = 1,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.richCharcoal,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          obscureText: obscureText,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.richCharcoal,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppTheme.charcoalMuted, size: 20)
                : null,
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.forestGreen,
                width: 1.8,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.statusCritical,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.statusCritical,
                width: 1.8,
              ),
            ),
            hintStyle: const TextStyle(
              color: AppTheme.charcoalLight,
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    );
  }
}
