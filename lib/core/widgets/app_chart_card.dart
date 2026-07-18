import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_sizes.dart';
import '../extensions/context_extensions.dart';
import 'app_card.dart';
import 'app_section_header.dart';

/// Simple bar chart card built with a custom painter (no chart dependency).
class AppChartCard extends StatelessWidget {
  const AppChartCard({
    super.key,
    required this.title,
    required this.data,
    this.subtitle,
    this.color = AppColors.primary,
    this.height = 160,
  });

  final String title;
  final String? subtitle;
  final List<BarData> data;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(title: title, subtitle: subtitle),
          AppSizes.vGapLg,
          SizedBox(
            height: height,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxVal = data.isEmpty
                    ? 1.0
                    : data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final bar in data)
                      Expanded(
                        child: _Bar(
                          data: bar,
                          maxValue: maxVal == 0 ? 1 : maxVal,
                          color: color,
                          maxHeight: constraints.maxHeight - 24,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.data,
    required this.maxValue,
    required this.color,
    required this.maxHeight,
  });

  final BarData data;
  final double maxValue;
  final Color color;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final barHeight = (data.value / maxValue) * maxHeight;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0, end: barHeight.clamp(4, maxHeight)),
          builder: (_, value, __) => Container(
            width: 14,
            height: value,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color, color.withValues(alpha: 0.5)],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        AppSizes.vGapSm,
        Text(context.tr(data.label), style: context.text.labelSmall),
      ],
    );
  }
}

class BarData {
  const BarData(this.label, this.value);
  final String label;
  final double value;
}
