import 'package:flutter/material.dart';

import '../../app/constants/app_colors.dart';
import '../../app/constants/app_sizes.dart';
import 'widgets.dart';

class SkillListChips extends StatelessWidget {
  const SkillListChips({super.key, required this.skills});

  final List<String> skills;

  @override
  Widget build(BuildContext context) {
    final visible = skills.take(3).toList();
    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: [
        for (final skill in visible)
          AppStatusChip(label: skill, color: AppColors.projectPurple),
        if (skills.length > visible.length)
          AppStatusChip(
            label: '+${skills.length - visible.length}',
            color: AppColors.projectPurple,
          ),
      ],
    );
  }
}
