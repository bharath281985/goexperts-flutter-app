import 'package:flutter/material.dart';

/// Keeps content above the system navigation bar (3-button / gesture inset).
///
/// Use around sticky bottom CTAs, or prefer [ContextX.paddingWithBottomSafe]
/// for scrollable page padding.
class SafeBottom extends StatelessWidget {
  const SafeBottom({
    super.key,
    required this.child,
    this.minimum = 0,
    this.maintainBottomViewPadding = true,
  });

  final Widget child;
  final double minimum;
  final bool maintainBottomViewPadding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      left: false,
      right: false,
      maintainBottomViewPadding: maintainBottomViewPadding,
      minimum: EdgeInsets.only(bottom: minimum),
      child: child,
    );
  }
}
