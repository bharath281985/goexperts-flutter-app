import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../domain/entities/meeting.dart';

/// Reusable meeting card.
class AppMeetingCard extends StatelessWidget {
  const AppMeetingCard({super.key, required this.meeting, this.onTap, this.onJoin});

  final Meeting meeting;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Column(
              children: [
                Text(Formatters.dayMonth(meeting.startTime).split(' ')[0],
                    style: context.text.titleMedium?.copyWith(color: AppColors.primary)),
                Text(Formatters.dayMonth(meeting.startTime).split(' ')[1].toUpperCase(),
                    style: context.text.labelSmall?.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
          AppSizes.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meeting.title, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(meeting.isVideo ? Icons.videocam_outlined : Icons.call_outlined,
                        size: 14, color: AppColors.mutedText),
                    const SizedBox(width: 4),
                    Text('${Formatters.time(meeting.startTime)} · ${meeting.durationMinutes}m',
                        style: context.text.labelMedium),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    AppAvatar(name: meeting.withName, imageUrl: meeting.withAvatar, size: 20),
                    const SizedBox(width: 6),
                    Flexible(child: Text(meeting.withName, style: context.text.labelSmall, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ),
          ),
          AppSizes.hGapSm,
          if (meeting.isUpcoming)
            FilledButton(
              onPressed: onJoin,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                minimumSize: Size.zero,
              ),
              child: const Text('Join'),
            )
          else
            AppStatusChip.status(meeting.status, dense: true),
        ],
      ),
    );
  }
}
