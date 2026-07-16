import 'package:flutter/material.dart';

import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/widgets/bookmark_button.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/project.dart';

class ProjectHeader extends StatelessWidget {
  const ProjectHeader({
    super.key,
    required this.project,
    this.onSave,
    this.onEdit,
  });

  final Project project;
  final VoidCallback? onSave;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: 60,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.projectAvatarRing, width: 3),
          ),
          child: AppAvatar(
            name: project.clientName,
            imageUrl: project.clientAvatar,
            size: 55,
            showOnline: true,
            isOnline: project.status == EntityStatus.open,
          ),
        ),
        AppSizes.hGapMd,
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: context.text.bodyLarge?.copyWith(
                    color: AppColors.projectText,
                    fontWeight: FontWeight.w800,
                    height: 1.22,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSizes.vGapSm,
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        project.clientName,
                        style: context.text.bodySmall?.copyWith(
                          color: AppColors.projectSecondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (project.clientVerified) ...[
                      const SizedBox(width: 8),
                      const VerifiedBadge(
                        size: 20,
                        color: AppColors.projectVerified,
                      ),
                    ],
                  ],
                ),
                if (project.category.isNotEmpty) ...[
                  AppSizes.vGapXs,
                  Text(
                    project.category,
                    style: context.text.labelSmall?.copyWith(
                      color: AppColors.mutedText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        if (onEdit != null)
          IconButton(
            tooltip: 'Edit',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: AppColors.projectPurple),
          )
        else
          BookmarkButton(isSaved: project.isSaved, onPressed: onSave),
      ],
    );
  }
}
