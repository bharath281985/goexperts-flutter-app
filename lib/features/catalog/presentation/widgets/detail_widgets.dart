import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_card.dart';

/// A gradient hero banner used at the top of detail pages.
class DetailHeroBanner extends StatelessWidget {
  const DetailHeroBanner({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.chips = const [],
    this.imageUrl,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> chips;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          AppSizes.vGapMd,
          Text(title, style: context.text.headlineSmall?.copyWith(color: Colors.white)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: context.text.bodyMedium?.copyWith(color: Colors.white70)),
          ],
          if (chips.isNotEmpty) ...[
            AppSizes.vGapMd,
            Wrap(spacing: AppSizes.sm, runSpacing: AppSizes.sm, children: chips),
          ],
        ],
      ),
    );
  }
}

/// A translucent chip used inside the hero banner.
class DetailStatChip extends StatelessWidget {
  const DetailStatChip({super.key, required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// A compact metric card (icon + value + label).
class DetailMetric extends StatelessWidget {
  const DetailMetric({super.key, required this.icon, required this.label, required this.value, this.color = AppColors.primary});
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.all(AppSizes.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          AppSizes.vGapSm,
          Text(value, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(label, style: context.text.labelSmall),
        ],
      ),
    );
  }
}

/// A wrap of pill chips.
class DetailChips extends StatelessWidget {
  const DetailChips({super.key, required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: [
        for (final i in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
            child: Text(i, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12)),
          ),
      ],
    );
  }
}

/// A vertical timeline / activity list.
class DetailTimeline extends StatelessWidget {
  const DetailTimeline({super.key, required this.events});
  final List<TimelineEvent> events;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < events.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: events[i].done ? AppColors.success : AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (i != events.length - 1)
                      Expanded(child: Container(width: 2, color: context.theme.dividerColor)),
                  ],
                ),
                AppSizes.hGapMd,
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(events[i].title, style: context.text.titleSmall),
                        if (events[i].subtitle != null)
                          Text(events[i].subtitle!, style: context.text.bodySmall),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class TimelineEvent {
  const TimelineEvent(this.title, {this.subtitle, this.done = false});
  final String title;
  final String? subtitle;
  final bool done;
}
