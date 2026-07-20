import 'package:flutter/material.dart';
import '../../app/constants/app_sizes.dart';
import '../../l10n/app_localizations.dart';

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

  String tr(String text) {
    final l10n = AppLocalizations.of(this);
    switch (text) {
      case 'Login':
      case 'Log in':
        return l10n.login;
      case 'Settings':
        return l10n.settings;
      case 'Language':
        return l10n.language;
      case 'Select Language':
        return l10n.selectLanguage;
      case 'English':
        return l10n.english;
      case 'Hindi':
        return l10n.hindi;
      case 'Telugu':
        return l10n.telugu;
      case 'Tamil':
        return l10n.tamil;
      case 'Kannada':
        return l10n.kannada;
      case 'Malayalam':
        return l10n.malayalam;
      case 'Marathi':
        return l10n.marathi;
      case 'Gujarati':
        return l10n.gujarati;
      case 'Bengali':
        return l10n.bengali;
      case 'Arabic':
        return l10n.arabic;
      case 'Save':
        return l10n.save;
      case 'Cancel':
        return l10n.cancel;
      case 'Home':
        return l10n.home;
      case 'Projects':
        return l10n.projects;
      case 'Chats':
        return l10n.chats;
      case 'Wallet':
        return l10n.wallet;
      case 'Profile':
        return l10n.profile;
      case 'My Profile':
        return l10n.myProfile;
      case 'Edit Profile':
        return l10n.editProfile;
      case 'View Public Profile':
        return l10n.viewPublicProfile;
      case 'Portfolio':
        return l10n.portfolio;
      case 'Reviews':
        return l10n.reviews;
      case 'Analytics':
        return l10n.analytics;
      case 'Subscription':
        return l10n.subscription;
      case 'Dashboard':
        return l10n.dashboard;
      case 'Discover Projects':
        return l10n.discoverProjects;
    }
    return text;
  }

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
        content: Text(tr(message)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        backgroundColor: isError ? colors.error : null,
      ),
    );
  }

  void showTopSnack(String message, {bool isError = false}) {
    if (message.trim().isEmpty) return;
    _activeTopSnack?.remove();
    _activeTopSnack = null;

    final overlayState = Overlay.of(this);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _TopSnackWidget(
        message: message,
        isError: isError,
        onDismiss: () {
          if (overlayEntry.mounted) {
            overlayEntry.remove();
            if (_activeTopSnack == overlayEntry) {
              _activeTopSnack = null;
            }
          }
        },
      ),
    );

    _activeTopSnack = overlayEntry;
    overlayState.insert(overlayEntry);
  }
}

OverlayEntry? _activeTopSnack;

class _TopSnackWidget extends StatefulWidget {
  const _TopSnackWidget({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  @override
  State<_TopSnackWidget> createState() => _TopSnackWidgetState();
}

class _TopSnackWidgetState extends State<_TopSnackWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), _dismiss);
  }

  void _dismiss() {
    if (mounted) {
      _controller.reverse().then((_) {
        widget.onDismiss();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.viewPaddingOf(context).top;
    return Align(
      alignment: Alignment.topCenter,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Padding(
            padding: EdgeInsets.only(top: topPadding + 10, left: 16, right: 16),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: widget.isError
                      ? const Color(0xFFD32F2F)
                      : const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isError
                          ? Icons.error_outline_rounded
                          : Icons.check_circle_outline_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _dismiss,
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
