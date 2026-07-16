import 'package:flutter/material.dart';

import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/enums.dart';

class ProjectStatusPill extends StatelessWidget {
  const ProjectStatusPill({super.key, required this.status});

  final EntityStatus status;

  @override
  Widget build(BuildContext context) {
    final isOpen = status == EntityStatus.open;
    final color = isOpen ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: color, size: 10),
          AppSizes.hGapSm,
          Text(
            isOpen ? 'Open for Proposals' : status.label,
            style: context.text.bodySmall?.copyWith(
              color: isOpen
                  ? AppColors.projectSuccessText
                  : AppColors.projectWarningText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
