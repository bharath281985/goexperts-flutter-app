import 'package:flutter/material.dart';

import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';

class ProposalCount extends StatelessWidget {
  const ProposalCount({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.projectPurpleSurface,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.groups_2_rounded,
            color: AppColors.projectPurple,
            size: 20,
          ),
        ),
        AppSizes.hGapXs,
        Text(
          '$count proposals',
          style: context.text.bodySmall?.copyWith(
            color: AppColors.projectText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
