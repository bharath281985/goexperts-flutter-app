import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_sizes.dart';
import '../extensions/context_extensions.dart';

/// Rounded surface card with a soft shadow and optional tap handling.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSizes.lg),
    this.onTap,
    this.color,
    this.border = true,
    this.radius = AppSizes.radiusLg,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final bool border;
  final double radius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    final shape = RoundedRectangleBorder(
      borderRadius: borderRadius,
      side: border
          ? BorderSide(color: context.theme.dividerColor)
          : BorderSide.none,
    );
    final content = Padding(padding: padding, child: child);

    return Container(
      margin: margin,
      child: Material(
        color: color ?? context.theme.cardColor,
        elevation: 6,
        shadowColor: AppColors.shadow,
        surfaceTintColor: Colors.transparent,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: onTap == null
            ? content
            : InkWell(borderRadius: borderRadius, onTap: onTap, child: content),
      ),
    );
  }
}
