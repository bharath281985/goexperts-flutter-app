import 'package:flutter/material.dart';
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

class CategoryDetailsPage extends StatelessWidget {
  const CategoryDetailsPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return DetailView<CategoryItem>(
      title: 'Category',
      fetcher: () => sl<CatalogRepository>().getCategory(id),
      actions: detailActions(context, shareTitle: 'this category', shareLink: '${Routes.categoryDetails}/$id', reportType: 'category'),
      bottomBar: (context, c) => Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: AppPrimaryButton(label: 'Explore ${c.name}', icon: Icons.explore_outlined, onPressed: () => context.showSnack('Exploring ${c.name}')),
      ),
      builder: (context, c) => ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          DetailHeroBanner(icon: Icons.category_outlined, title: c.name, subtitle: '${c.projectsCount} live projects'),
          AppSizes.vGapLg,
          Row(
            children: [
              Expanded(child: DetailMetric(icon: Icons.work_outline_rounded, label: 'Projects', value: '${c.projectsCount}')),
              Expanded(child: DetailMetric(icon: Icons.groups_outlined, label: 'Talent', value: '${c.freelancersCount}')),
              Expanded(child: DetailMetric(icon: Icons.payments_outlined, label: 'Avg Budget', value: Formatters.compactCurrency(c.avgBudget))),
            ],
          ),
          AppSizes.vGapLg,
          DetailSection(title: 'Overview', child: Text(c.description, style: context.text.bodyMedium)),
          if (c.subcategories.isNotEmpty) ...[
            AppSizes.vGapLg,
            DetailSection(title: 'Subcategories', child: DetailChips(items: c.subcategories)),
          ],
          if (c.trendingSkills.isNotEmpty) ...[
            AppSizes.vGapLg,
            DetailSection(title: 'Trending Skills', child: DetailChips(items: c.trendingSkills)),
          ],
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}
