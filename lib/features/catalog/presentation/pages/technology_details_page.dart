import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/detail_actions.dart';
import '../../../../core/widgets/detail_view.dart';
import '../../domain/entities/catalog_entities.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../widgets/detail_widgets.dart';

class TechnologyDetailsPage extends StatelessWidget {
  const TechnologyDetailsPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return DetailView<Technology>(
      title: 'Technology',
      fetcher: () => sl<CatalogRepository>().getTechnology(id),
      actions: detailActions(context, shareTitle: 'this technology', shareLink: '${Routes.technologyDetails}/$id', reportType: 'technology'),
      bottomBar: (context, t) => Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: AppPrimaryButton(label: 'Find ${t.name} Experts', icon: Icons.search_rounded, onPressed: () => context.showSnack('Browsing ${t.name} talent')),
      ),
      builder: (context, t) => ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          DetailHeroBanner(
            icon: Icons.code_rounded,
            title: t.name,
            subtitle: t.category,
            chips: [DetailStatChip(icon: Icons.trending_up_rounded, label: '${t.popularity}% popular')],
          ),
          AppSizes.vGapLg,
          Row(
            children: [
              Expanded(child: DetailMetric(icon: Icons.work_outline_rounded, label: 'Projects', value: '${t.projectsCount}')),
              Expanded(child: DetailMetric(icon: Icons.groups_outlined, label: 'Freelancers', value: '${t.freelancersCount}')),
            ],
          ),
          AppSizes.vGapLg,
          DetailSection(title: 'Overview', child: Text(t.description, style: context.text.bodyMedium)),
          AppSizes.vGapLg,
          DetailSection(
            title: 'Adoption',
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${t.popularity}% market popularity', style: context.text.titleSmall),
                  AppSizes.vGapSm,
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: t.popularity / 100,
                      minHeight: 8,
                      backgroundColor: context.theme.dividerColor,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (t.relatedSkills.isNotEmpty) ...[
            AppSizes.vGapLg,
            DetailSection(title: 'Related Skills', child: DetailChips(items: t.relatedSkills)),
          ],
          if (t.resources.isNotEmpty) ...[
            AppSizes.vGapLg,
            DetailSection(
              title: 'Learning Resources',
              child: Column(
                children: [
                  for (final r in t.resources)
                    AppCard(
                      margin: const EdgeInsets.only(bottom: AppSizes.sm),
                      padding: const EdgeInsets.all(AppSizes.md),
                      onTap: () => context.showSnack('Opening $r'),
                      child: Row(children: [
                        const Icon(Icons.menu_book_outlined, size: 18, color: AppColors.primary),
                        AppSizes.hGapMd,
                        Expanded(child: Text(r, style: context.text.bodyMedium)),
                        const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.mutedText),
                      ]),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}
