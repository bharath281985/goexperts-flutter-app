import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_sizes.dart';

/// Gradient hero header used on dashboards and profile pages.
class AppGradientHeader extends StatelessWidget {
  const AppGradientHeader({
    super.key,
    required this.child,
    this.height,
    this.padding = const EdgeInsets.fromLTRB(
      AppSizes.screenPadding,
      AppSizes.lg,
      AppSizes.screenPadding,
      AppSizes.xl,
    ),
    this.borderRadius,
  });

  final Widget child;
  final double? height;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.viewPaddingOf(context).top;
    return Container(
      height: height,
      padding: padding.add(EdgeInsets.only(top: topInset)),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: borderRadius ??
            const BorderRadius.vertical(bottom: Radius.circular(AppSizes.radiusXl)),
      ),
      child: child,
    );
  }
}
