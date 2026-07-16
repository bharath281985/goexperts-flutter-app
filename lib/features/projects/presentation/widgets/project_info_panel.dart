import 'package:flutter/material.dart';

import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import 'project_info_item.dart';

class ProjectInfoPanel extends StatelessWidget {
  const ProjectInfoPanel({
    super.key,
    required this.budget,
    required this.timeline,
  });

  final String budget;
  final String timeline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.projectPanelBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: ProjectInfoItem(
              icon: Icons.savings_rounded,
              iconColor: AppColors.success,
              label: 'Budget',
              value: budget,
            ),
          ),
          Container(
            width: 1,
            height: 30,
            margin: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
            color: AppColors.projectPanelBorder,
          ),
          Expanded(
            child: ProjectInfoItem(
              icon: Icons.schedule_rounded,
              iconColor: AppColors.warning,
              label: 'Timeline',
              value: timeline,
            ),
          ),
        ],
      ),
    );
  }
}
