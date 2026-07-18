import 'package:flutter/widgets.dart';

/// Spacing, radius and breakpoint tokens for a consistent layout system.
class AppSizes {
  AppSizes._();

  // Spacing scale
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 12;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double x4xl = 40;
  static const double x5xl = 50;

  // Screen padding
  static const double screenPadding = 16;

  // Radius
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusPill = 999;

  // Elevation-like blur
  static const double cardBlur = 18;

  // Common component sizes
  static const double buttonHeight = 52;
  static const double inputHeight = 54;
  static const double avatarSm = 32;
  static const double avatarMd = 44;
  static const double avatarLg = 72;
  static const double iconSm = 18;
  static const double iconMd = 22;
  static const double iconLg = 28;

  // Responsive breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  /// Max content width for centered layouts on large screens.
  static const double maxContentWidth = 1120;

  // Common gaps (widgets)
  static const gapXs = SizedBox(height: xs, width: xs);
  static const gapSm = SizedBox(height: sm, width: sm);
  static const gapMd = SizedBox(height: md, width: md);
  static const gapLg = SizedBox(height: lg, width: lg);
  static const gapXl = SizedBox(height: xl, width: xl);

  static const vGapXs = SizedBox(height: xs);
  static const vGapSm = SizedBox(height: sm);
  static const vGapMd = SizedBox(height: md);
  static const vGapLg = SizedBox(height: lg);
  static const vGapXl = SizedBox(height: xl);
  static const vGapXxl = SizedBox(height: xxl);
  static const vGapXxxl = SizedBox(height: xxxl);
  static const vGap4xl = SizedBox(height: x4xl);
  static const vGap5xl = SizedBox(height: x5xl);

  static const hGapXs = SizedBox(width: xs);
  static const hGapSm = SizedBox(width: sm);
  static const hGapMd = SizedBox(width: md);
  static const hGapLg = SizedBox(width: lg);
  static const hGapXl = SizedBox(width: xl);
}
