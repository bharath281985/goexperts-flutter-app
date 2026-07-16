import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/freelancer.dart';

/// Reusable freelancer card for discovery & recommendations.
class AppFreelancerCard extends StatelessWidget {
  const AppFreelancerCard({
    super.key,
    required this.freelancer,
    this.onTap,
    this.onSave,
    this.onInvite,
    this.showInvite = true,
  });

  final Freelancer freelancer;
  final VoidCallback? onTap;
  final VoidCallback? onSave;
  final VoidCallback? onInvite;
  final bool showInvite;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(name: freelancer.name, imageUrl: freelancer.avatarUrl, size: 52),
              AppSizes.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(child: Text(freelancer.name, style: context.text.titleSmall, overflow: TextOverflow.ellipsis)),
                        if (freelancer.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded, size: 14, color: AppColors.info),
                        ],
                      ],
                    ),
                    Text(freelancer.headline,
                        style: context.text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                        const SizedBox(width: 2),
                        Text('${freelancer.rating} (${freelancer.reviewsCount})', style: context.text.labelMedium),
                        AppSizes.hGapSm,
                        const Icon(Icons.location_on_outlined, size: 13, color: AppColors.mutedText),
                        Flexible(child: Text(freelancer.location, style: context.text.labelSmall, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onSave,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  freelancer.isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                  color: freelancer.isSaved ? AppColors.primary : AppColors.subtleText,
                ),
              ),
            ],
          ),
          AppSizes.vGapMd,
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: [for (final s in freelancer.skills.take(3)) _tag(context, s)],
          ),
          AppSizes.vGapMd,
          Row(
            children: [
              Text(Formatters.currency(freelancer.hourlyRate),
                  style: context.text.titleSmall?.copyWith(color: AppColors.primary)),
              Text('/hr', style: context.text.labelSmall),
              const Spacer(),
              if (showInvite)
                TextButton(
                  onPressed: onInvite,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 4),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Invite', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(BuildContext context, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4),
        decoration: BoxDecoration(
          color: context.theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          border: Border.all(color: context.theme.dividerColor),
        ),
        child: Text(text, style: context.text.labelSmall),
      );
}
