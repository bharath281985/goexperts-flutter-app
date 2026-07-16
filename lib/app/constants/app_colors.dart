import 'package:flutter/material.dart';

/// Go Experts brand color palette.
///
/// Centralized so themes and widgets never hardcode raw hex values.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFFE30613);
  static const Color primaryBlack = Color(0xFF111111);

  // Text
  static const Color darkText = Color(0xFF202124);
  static const Color mutedText = Color(0xFF6B7280);
  static const Color subtleText = Color(0xFF9AA0A6);

  // Surfaces
  static const Color background = Color(0xFFF8F9FC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE7EAF3);

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF0EA5E9);

  // Dark mode surfaces
  static const Color darkBackground = Color(0xFF0E0E10);
  static const Color darkCard = Color(0xFF17171A);
  static const Color darkBorder = Color(0xFF26262B);
  static const Color darkText2 = Color(0xFFECEDEE);

  // Utility
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color shadow = Color(0x14000000);

  // Project card accents
  static const Color projectText = Color(0xFF10172A);
  static const Color projectSecondaryText = Color(0xFF4B5563);
  static const Color projectBodyText = Color(0xFF667085);
  static const Color projectPurple = Color(0xFF5B35F5);
  static const Color projectPurpleText = Color(0xFF4F35D9);
  static const Color projectPurpleSoft = Color(0xFFF2F0FF);
  static const Color projectPurpleSurface = Color(0xFFF1EEFF);
  static const Color projectAvatarRing = Color(0xFFE5DEFF);
  static const Color projectSoftBorder = Color(0xFFE9EAF3);
  static const Color projectPanelBorder = Color(0xFFE5E7EB);
  static const Color projectDash = Color(0xFFDDE1EC);
  static const Color projectVerified = Color(0xFF2F80ED);
  static const Color projectTailwind = Color(0xFF38BDF8);
  static const Color projectSuccessText = Color(0xFF166534);
  static const Color projectWarningText = Color(0xFF92400E);

  // Startup card accents
  static const Color startupHeaderRed = Color(0xFFE30613);
  static const Color startupHeaderDarkRed = Color(0xFFC80010);
  static const Color startupHeaderHighlight = Color(0x22FFFFFF);
  static const Color startupTagSurface = Color(0x33FFFFFF);
  static const Color startupTagText = Color(0xFFFFFFFF);
  static const Color startupChipSurface = Color(0xFFFFE8EA);
  static const Color startupChipText = Color(0xFFC80010);
  static const Color startupIconGreenSurface = Color(0xFFE6F8EE);
  static const Color startupIconBlueSurface = Color(0xFFEAF1FF);
  static const Color startupIconPurpleSurface = Color(0xFFF1EAFF);

  // Brand gradient used on hero/gradient headers.
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE30613), Color(0xFFB00410)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A1D), Color(0xFF111111)],
  );

  /// Deterministic accent color for avatars / charts from a seed string.
  static Color fromSeed(String seed) {
    const palette = [
      Color(0xFFE30613),
      Color(0xFF0EA5E9),
      Color(0xFF16A34A),
      Color(0xFFF59E0B),
      Color(0xFF7C3AED),
      Color(0xFFDB2777),
      Color(0xFF0891B2),
      Color(0xFF4F46E5),
    ];
    var hash = 0;
    for (final code in seed.codeUnits) {
      hash = code + ((hash << 5) - hash);
    }
    return palette[hash.abs() % palette.length];
  }
}
