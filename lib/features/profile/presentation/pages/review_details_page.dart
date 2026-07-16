import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_secondary_button.dart';
import '../../../../core/widgets/detail_actions.dart';
import '../../../../core/widgets/detail_view.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';

class ReviewDetailsPage extends StatelessWidget {
  const ReviewDetailsPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return DetailView<Review>(
      title: 'Review',
      fetcher: () => sl<ReviewRepository>().getReview(id),
      actions: detailActions(context, shareTitle: 'this review', shareLink: '${Routes.reviewDetails}/$id', reportType: 'review', bookmarkable: false),
      bottomBar: (context, r) => Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: AppSecondaryButton(label: 'Reply', icon: Icons.reply_rounded, onPressed: () => context.showSnack('Reply composer')),
      ),
      builder: (context, r) => ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppAvatar(name: r.authorName, imageUrl: r.authorAvatar, size: 48),
                    AppSizes.hGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.authorName, style: context.text.titleSmall),
                          Text(Formatters.date(r.createdAt), style: context.text.labelSmall),
                        ],
                      ),
                    ),
                  ],
                ),
                AppSizes.vGapMd,
                Row(
                  children: [
                    for (var i = 0; i < 5; i++)
                      Icon(
                        i < r.rating.floor()
                            ? Icons.star_rounded
                            : (i < r.rating ? Icons.star_half_rounded : Icons.star_outline_rounded),
                        color: AppColors.warning,
                        size: 22,
                      ),
                    AppSizes.hGapSm,
                    Text(r.rating.toString(), style: context.text.titleSmall),
                  ],
                ),
                if (r.context.isNotEmpty) ...[
                  AppSizes.vGapSm,
                  Text('on ${r.context}', style: context.text.labelSmall),
                ],
                AppSizes.vGapMd,
                Text(r.comment, style: context.text.bodyMedium),
              ],
            ),
          ),
          if (r.reply != null) ...[
            AppSizes.vGapMd,
            Padding(
              padding: const EdgeInsets.only(left: AppSizes.xl),
              child: AppCard(
                color: AppColors.primary.withValues(alpha: 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reply', style: context.text.labelMedium?.copyWith(color: AppColors.primary)),
                    AppSizes.vGapXs,
                    Text(r.reply!, style: context.text.bodyMedium),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}
