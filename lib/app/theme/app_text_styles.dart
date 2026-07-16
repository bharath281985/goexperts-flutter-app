import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Typography scale for Go Experts. Uses the platform default font family
/// (swappable to a brand font later) with tuned weights & spacing.
class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Roboto';

  static TextTheme textTheme(Color primaryText, Color secondaryText) {
    return TextTheme(
      displayLarge: _s(32, FontWeight.w700, primaryText, height: 1.2),
      displayMedium: _s(28, FontWeight.w700, primaryText, height: 1.2),
      displaySmall: _s(24, FontWeight.w700, primaryText, height: 1.25),
      headlineMedium: _s(22, FontWeight.w700, primaryText),
      headlineSmall: _s(20, FontWeight.w600, primaryText),
      titleLarge: _s(18, FontWeight.w600, primaryText),
      titleMedium: _s(16, FontWeight.w600, primaryText),
      titleSmall: _s(14, FontWeight.w600, primaryText),
      bodyLarge: _s(16, FontWeight.w400, primaryText, height: 1.45),
      bodyMedium: _s(14, FontWeight.w400, primaryText, height: 1.45),
      bodySmall: _s(12, FontWeight.w400, secondaryText, height: 1.4),
      labelLarge: _s(14, FontWeight.w600, primaryText),
      labelMedium: _s(12, FontWeight.w500, secondaryText),
      labelSmall: _s(11, FontWeight.w500, secondaryText),
    );
  }

  static TextStyle _s(
    double size,
    FontWeight weight,
    Color color, {
    double? height,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: 0.1,
    );
  }

  // Convenience styles used by widgets directly.
  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: AppColors.white,
  );
}
