import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/detail_actions.dart';
import '../../../../core/widgets/detail_view.dart';
import '../../domain/entities/catalog_entities.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../widgets/detail_widgets.dart';

class PitchDeckPage extends StatelessWidget {
  const PitchDeckPage({super.key, required this.startupId});
  final String startupId;

  @override
  Widget build(BuildContext context) {
    return DetailView<PitchDeck>(
      title: 'Pitch Deck',
      fetcher: () => sl<CatalogRepository>().getPitchDeck(startupId),
      actions: detailActions(context, shareTitle: 'this pitch deck', shareLink: '${Routes.pitchDeckDetails}/$startupId', reportType: 'startup'),
      bottomBar: (context, d) => Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: AppPrimaryButton(label: 'Download Deck', icon: Icons.download_rounded, onPressed: () => context.showSnack('Downloading pitch deck')),
      ),
      builder: (context, d) => ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          DetailHeroBanner(
            icon: Icons.slideshow_outlined,
            title: '${d.startupName} Pitch Deck',
            subtitle: 'Updated ${Formatters.relative(d.updatedAt)}',
            chips: [DetailStatChip(icon: Icons.visibility_outlined, label: '${d.views} views')],
          ),
          AppSizes.vGapLg,
          Text('${d.slides.length} slides', style: context.text.titleMedium),
          AppSizes.vGapMd,
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.isMobile ? 2 : 3,
              crossAxisSpacing: AppSizes.md,
              mainAxisSpacing: AppSizes.md,
              childAspectRatio: 4 / 3,
            ),
            itemCount: d.slides.length,
            itemBuilder: (context, i) {
              final slide = d.slides[i];
              return InkWell(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                onTap: () => context.showSnack('Opening slide ${i + 1}'),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: context.theme.cardColor,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(color: context.theme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${i + 1}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
                      const Spacer(),
                      Text(slide.title, style: context.text.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(slide.subtitle, style: context.text.labelSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}
