import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../app/constants/app_sizes.dart';
import '../extensions/context_extensions.dart';

/// Shimmer skeletons for loading states.
class AppLoadingShimmer extends StatelessWidget {
  const AppLoadingShimmer({super.key, this.itemCount = 6, this.height = 92});

  final int itemCount;
  final double height;

  @override
  Widget build(BuildContext context) {
    final base = context.isDark ? Colors.white10 : Colors.black12;
    final highlight = context.isDark
        ? Colors.white24
        : Colors.black.withValues(alpha: 0.04);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => AppSizes.vGapMd,
        itemBuilder: (_, __) => Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
        ),
      ),
    );
  }
}

/// A single shimmer box (for custom skeleton layouts).
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius = AppSizes.radiusSm,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final base = context.isDark ? Colors.white10 : Colors.black12;
    final highlight = context.isDark
        ? Colors.white24
        : Colors.black.withValues(alpha: 0.04);
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
