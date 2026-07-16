import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_sizes.dart';
import '../extensions/context_extensions.dart';
import '../utils/enums.dart';

/// Colored pill representing an [EntityStatus] or an arbitrary label.
class AppStatusChip extends StatelessWidget {
  const AppStatusChip({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.dense = false,
  });

  AppStatusChip.status(EntityStatus status, {super.key, this.dense = false})
    : label = status.label,
      icon = null,
      color = _colorFor(status);

  final String label;
  final Color? color;
  final IconData? icon;
  final bool dense;

  static Color _colorFor(EntityStatus status) {
    switch (status) {
      case EntityStatus.open:
      case EntityStatus.active:
      case EntityStatus.accepted:
      case EntityStatus.completed:
        return AppColors.success;
      case EntityStatus.pending:
      case EntityStatus.underReview:
      case EntityStatus.inProgress:
      case EntityStatus.shortlisted:
      case EntityStatus.interview:
        return AppColors.warning;
      case EntityStatus.rejected:
      case EntityStatus.cancelled:
      case EntityStatus.expired:
      case EntityStatus.withdrawn:
        return AppColors.danger;
      case EntityStatus.draft:
        return AppColors.mutedText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.info;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? AppSizes.sm : AppSizes.md,
        vertical: dense ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: c),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: context.text.bodySmall?.copyWith(
              color: c,
              fontSize: dense ? 10 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
