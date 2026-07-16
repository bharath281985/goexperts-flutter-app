import 'package:flutter/material.dart';
import '../../app/constants/app_sizes.dart';

/// Constrains content width on large screens (web/desktop/tablet) so the app
/// stays comfortable to read while remaining edge-to-edge on phones.
class ResponsiveWrapper extends StatelessWidget {
  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = AppSizes.maxContentWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
