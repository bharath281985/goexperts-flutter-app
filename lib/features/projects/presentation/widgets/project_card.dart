import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/dashed_divider.dart';
import '../../../../core/widgets/skill_list_chips.dart';
import '../../domain/entities/project.dart';
import 'project_header.dart';
import 'project_info_panel.dart';
import 'project_status_pill.dart';
import 'proposal_count.dart';

/// Reusable project card used across freelancer & client listings.
class AppProjectCard extends StatelessWidget {
  const AppProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.onSave,
    this.onApply,
    this.onEdit,
    this.onUpdateStatus,
  });

  final Project project;
  final VoidCallback? onTap;
  final VoidCallback? onSave;
  final VoidCallback? onApply;
  final VoidCallback? onEdit;
  final VoidCallback? onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    final budget = project.isHourly
        ? '${Formatters.compactCurrency(project.budgetMin)} - ${Formatters.compactCurrency(project.budgetMax)} /hr'
        : '${Formatters.compactCurrency(project.budgetMin)} - ${Formatters.compactCurrency(project.budgetMax)}';
    final isOwner = project.isOwner;

    return Material(
      color: context.theme.cardColor,
      elevation: 12,
      shadowColor: AppColors.black.withValues(alpha: 0.30),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProjectHeader(
                project: project,
                onSave: isOwner ? null : onSave,
                onEdit: isOwner ? onEdit : null,
              ),
              if (project.description.trim().isNotEmpty) ...[
                AppSizes.vGapMd,
                Text(
                  project.description,
                  style: context.text.bodySmall?.copyWith(
                    color: AppColors.projectBodyText,
                    height: 1.45,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (project.skills.isNotEmpty) ...[
                AppSizes.vGapMd,
                SkillListChips(skills: project.skills),
              ],
              AppSizes.vGapMd,
              ProjectInfoPanel(budget: budget, timeline: project.timeline),
              AppSizes.vGapMd,
              const SizedBox(height: 1, child: DashedDivider()),
              AppSizes.vGapMd,
              Wrap(
                spacing: AppSizes.md,
                runSpacing: AppSizes.md,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ProjectStatusPill(status: project.status),
                  ProposalCount(count: project.proposalsCount),
                ],
              ),
              AppSizes.vGapSm,
              if (isOwner)
                Row(
                  children: [
                    Expanded(
                      child: AppPrimaryButton(
                        label: 'View Details',
                        icon: Icons.remove_red_eye_outlined,
                        onPressed: onTap,
                        gradient: false,
                        backgroundColor: AppColors.border,
                        textColor: AppColors.black,
                        height: 40,
                      ),
                    ),
                    AppSizes.hGapXs,
                    Expanded(
                      child: AppPrimaryButton(
                        label: 'Edit',
                        icon: Icons.edit_outlined,
                        onPressed: onEdit ?? onTap,
                        gradient: false,
                        backgroundColor: AppColors.projectPurple,
                        height: 40,
                      ),
                    ),
                    if (onUpdateStatus != null) ...[
                      AppSizes.hGapXs,
                      IconButton(
                        tooltip: 'Update status',
                        onPressed: onUpdateStatus,
                        icon: const Icon(Icons.flag_outlined),
                      ),
                    ],
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: AppPrimaryButton(
                        label: 'View Details',
                        icon: Icons.remove_red_eye_outlined,
                        onPressed: onTap,
                        gradient: false,
                        backgroundColor: AppColors.border,
                        textColor: AppColors.black,
                        disabledBackgroundColor: AppColors.white,
                        height: 40,
                      ),
                    ),
                    AppSizes.hGapXs,
                    Expanded(
                      child: AppPrimaryButton(
                        label: project.isApplied ? 'Applied' : 'Apply',
                        icon: project.isApplied
                            ? Icons.check_circle_outline_rounded
                            : Icons.near_me_rounded,
                        onPressed: project.isApplied ? null : onApply ?? onTap,
                        gradient: false,
                        backgroundColor: project.isApplied
                            ? AppColors.success
                            : AppColors.projectPurple,
                        disabledBackgroundColor: project.isApplied
                            ? AppColors.success
                            : AppColors.projectPurple.withValues(alpha: 0.5),
                        height: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
