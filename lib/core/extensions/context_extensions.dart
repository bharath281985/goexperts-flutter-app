import 'package:flutter/material.dart';
import '../../app/constants/app_sizes.dart';

/// Ergonomic access to theme, media query and responsive helpers.
extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get text => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;

  Size get screenSize => MediaQuery.sizeOf(this);
  double get width => MediaQuery.sizeOf(this).width;
  double get height => MediaQuery.sizeOf(this).height;
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  /// System navigation / home-indicator inset (3-button or gesture bar).
  double get bottomSafeInset => MediaQuery.viewPaddingOf(this).bottom;

  /// Page padding that clears the system navigation bar.
  EdgeInsets paddingWithBottomSafe([
    EdgeInsets padding = const EdgeInsets.all(AppSizes.xl),
  ]) {
    return padding.copyWith(bottom: padding.bottom + bottomSafeInset);
  }

  bool get isMobile => width < AppSizes.mobileBreakpoint;
  bool get isTablet =>
      width >= AppSizes.mobileBreakpoint && width < AppSizes.tabletBreakpoint;
  bool get isDesktop => width >= AppSizes.tabletBreakpoint;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Grid column count that adapts across form factors.
  int get responsiveColumns {
    if (width >= AppSizes.desktopBreakpoint) return 4;
    if (width >= AppSizes.tabletBreakpoint) return 3;
    if (width >= AppSizes.mobileBreakpoint) return 2;
    return 1;
  }

  void showSnack(String message, {bool isError = false}) {
    if (message.trim().isEmpty) return;
    final messenger = ScaffoldMessenger.of(this);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        backgroundColor: isError ? colors.error : null,
      ),
    );
  }
}
