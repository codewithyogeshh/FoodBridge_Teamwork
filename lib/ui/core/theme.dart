import 'package:flutter/material.dart';

/// FoodBridge 2.0 Design System Tokens
/// Clean Modern Light & Fresh Emerald (UberEats / Airbnb Inspired Aesthetic)
///
/// Visual Architecture:
/// - Base Canvas: Warm Fresh Ivory (#F8FAF9)
/// - Surface Cards: Crisp Pure White (#FFFFFF)
/// - Surface Elevated: Pure White with Soft Subtle Shadow
/// - Primary Accent: Vibrant Fresh Emerald (#059669)
/// - Secondary Accent: Living Emerald (#10B981)
/// - Warm Accent: Sunflower Gold (#D97706)
/// - Mint Tint / Fill: Soft Fresh Mint (#ECFDF5)
/// - Text High-Contrast: Deep Charcoal (#111827)
/// - Text Muted / Body: Refined Slate (#4B5563)
/// - Text Light / Hints: Soft Gray (#9CA3AF)
class AppTheme {
  // Brand Canvas & Surfaces
  static const Color botanicalCanvas = Color(0xFFF8FAF9);
  static const Color warmIvory = Color(0xFFF8FAF9); // Seamless canvas mapping
  static const Color warmIvoryDark = Color(0xFFF0F3F1);
  static const Color cardSurface = Color(0xFFFFFFFF); // Crisp white cards
  static const Color cardSurfaceElevated = Color(0xFFFFFFFF);

  // Fresh Living Emeralds & Mints
  static const Color forestGreen = Color(
    0xFF059669,
  ); // Primary deep fresh emerald
  static const Color forestGreenLight = Color(0xFF10B981);
  static const Color forestGreenDark = Color(0xFF047857);

  static const Color emerald = Color(0xFF10B981); // Bright living emerald
  static const Color emeraldDark = Color(0xFF059669);
  static const Color emeraldLight = Color(0xFFECFDF5); // Soft fresh mint tint

  static const Color restrainedLime = Color(0xFF059669); // High-contrast green
  static const Color limeLight = Color(0xFFECFDF5);
  static const Color limeDark = Color(0xFF047857);

  // High-Trust Sharp Typography
  static const Color richCharcoal = Color(
    0xFF111827,
  ); // Deep sharp charcoal text
  static const Color charcoalMuted = Color(
    0xFF4B5563,
  ); // Refined slate subtitles
  static const Color charcoalLight = Color(
    0xFF9CA3AF,
  ); // Soft gray labels & hints

  // Accents & Warmth
  static const Color sunflowerGold = Color(0xFFD97706);
  static const Color goldLight = Color(0xFFFEF3C7);

  // Status Colors (Fresh & Crisp)
  static const Color statusCritical = Color(0xFFE11D48); // Red
  static const Color statusCriticalBg = Color(0xFFFFE4E6);
  static const Color statusHigh = Color(0xFFD97706); // Amber
  static const Color statusHighBg = Color(0xFFFEF3C7);
  static const Color statusMedium = Color(0xFF2563EB); // Blue
  static const Color statusMediumBg = Color(0xFFEFF6FF);
  static const Color statusSuccess = Color(0xFF059669); // Green
  static const Color statusSuccessBg = Color(0xFFECFDF5);

  // Borders & Glow Layers
  static const Color borderColor = Color(
    0xFFE5E7EB,
  ); // Crisp subtle light border
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color borderGlow = Color(0x3310B981); // Soft emerald aura

  // Elevation Shadows (Smooth, Modern & Subtle)
  static List<BoxShadow> get subtleShadow => [
    const BoxShadow(
      color: Color(0x08000000),
      blurRadius: 10,
      offset: Offset(0, 3),
    ),
    const BoxShadow(
      color: Color(0x04000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get cardElevation => [
    const BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
    const BoxShadow(
      color: Color(0x05000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get emeraldGlow => [
    const BoxShadow(
      color: Color(0x1F059669),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  // Theme Data Definition (Clean Modern Light & Fresh Emerald)
  static ThemeData get lightTheme => _cleanModernLightTheme;
  static ThemeData get darkTheme => _cleanModernLightTheme;

  static ThemeData get _cleanModernLightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: forestGreen,
      scaffoldBackgroundColor: warmIvory,
      canvasColor: warmIvory,
      fontFamily: 'Segoe UI',
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: forestGreen,
        onPrimary: Colors.white,
        primaryContainer: emeraldLight,
        onPrimaryContainer: forestGreenDark,
        secondary: sunflowerGold,
        onSecondary: Colors.white,
        secondaryContainer: goldLight,
        onSecondaryContainer: Color(0xFF92400E),
        error: statusCritical,
        onError: Colors.white,
        errorContainer: statusCriticalBg,
        onErrorContainer: Color(0xFF9F1239),
        surface: cardSurface,
        onSurface: richCharcoal,
        surfaceContainerHighest: warmIvoryDark,
        outline: borderColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: warmIvory,
        foregroundColor: richCharcoal,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: richCharcoal,
          fontSize: 19,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: forestGreen),
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderColor, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: forestGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: const Color(0x26059669),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: forestGreen,
          side: const BorderSide(color: forestGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: forestGreen,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: forestGreen, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: statusCritical, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: statusCritical, width: 1.8),
        ),
        labelStyle: const TextStyle(color: charcoalMuted, fontSize: 14),
        hintStyle: const TextStyle(color: charcoalLight, fontSize: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: forestGreen,
        unselectedItemColor: charcoalLight,
        type: BottomNavigationBarType.fixed,
        elevation: 6,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: borderColor),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: richCharcoal,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: charcoalMuted,
          height: 1.45,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: richCharcoal,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: warmIvoryDark,
        disabledColor: Color(0xFFF3F4F6),
        selectedColor: emeraldLight,
        secondarySelectedColor: forestGreen,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        labelStyle: const TextStyle(
          color: richCharcoal,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderColor),
        ),
      ),
    );
  }
}
