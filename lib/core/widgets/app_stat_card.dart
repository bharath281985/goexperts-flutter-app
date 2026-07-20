import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_sizes.dart';
import '../extensions/context_extensions.dart';
import 'app_card.dart';

/// Compact metric card for dashboards (value + label + trend).
class AppStatCard extends StatelessWidget {
  const AppStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = AppColors.primary,
    this.trend,
    this.trendUp = true,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool trendUp;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSizes.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final content = SizedBox(
            width: constraints.maxWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: Icon(icon, color: color, size: AppSizes.iconSm),
                    ),
                    const Spacer(),
                    if (trend != null)
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              trendUp
                                  ? Icons.trending_up_rounded
                                  : Icons.trending_down_rounded,
                              size: 15,
                              color: trendUp
                                  ? AppColors.success
                                  : AppColors.danger,
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                trend!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: trendUp
                                      ? AppColors.success
                                      : AppColors.danger,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: context.text.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  context.tr(label),
                  style: context.text.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );

          return FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topLeft,
            child: content,
          );
        },
      ),
    );
  }
}
