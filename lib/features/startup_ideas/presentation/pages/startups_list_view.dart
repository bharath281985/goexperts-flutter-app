import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_filter_bottom_sheet.dart';
import '../../../../core/widgets/catalog_view.dart';
import '../../domain/entities/startup.dart';
import '../../domain/repositories/startup_repository.dart';
import '../widgets/startup_card.dart';

/// Embeddable startup discovery catalog.
class StartupsListView extends StatelessWidget {
  const StartupsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = sl<StartupRepository>();
    return CatalogView<Startup>(
      fetcher: repo.getStartups,
      searchHint: 'Search startups, industries…',
      emptyTitle: 'No startups found',
      emptyIcon: Icons.rocket_launch_outlined,
      sortOptions: const ['Most interest', 'Funding: High to Low', 'Newest'],
      filterSections: () => [
        FilterSection(
          key: 'industry',
          title: 'Industry',
          options: const ['AgriTech', 'HealthTech', 'EdTech', 'CleanTech', 'FinTech', 'SaaS'],
        ),
        FilterSection(
          key: 'stage',
          title: 'Stage',
          options: const ['Idea Stage', 'Prototype', 'MVP', 'Early Revenue', 'Growth', 'Expansion'],
        ),
      ],
      itemBuilder: (context, s, _) => AppStartupCard(
        startup: s,
        onTap: () => context.push('${Routes.startupDetails}/${s.id}'),
        onSave: () => context.showSnack(s.isSaved ? 'Removed from saved' : 'Saved startup'),
        onInterest: () => context.showSnack('Interest expressed in ${s.name}'),
      ),
    );
  }
}
