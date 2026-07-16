import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/bloc/list_bloc.dart';
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
          options: const [
            'AgriTech',
            'HealthTech',
            'EdTech',
            'CleanTech',
            'FinTech',
            'SaaS',
          ],
        ),
        FilterSection(
          key: 'stage',
          title: 'Stage',
          options: const [
            'Idea Stage',
            'Prototype',
            'MVP',
            'Early Revenue',
            'Growth',
            'Expansion',
          ],
        ),
      ],
      itemBuilder: (context, s, _) {
        final bloc = context.read<ListBloc<Startup>>();
        return AppStartupCard(
          startup: s,
          onTap: () => context.push('${Routes.startupDetails}/${s.id}'),
          onSave: () async {
            final res = await repo.toggleSave(s.id);
            res.fold((f) => context.showSnack(f.message), (success) {
              if (success) {
                final updated = s.copyWith(isSaved: !s.isSaved);
                bloc.add(
                  ListItemUpdated(
                    updated,
                    (existing, newItem) => existing.id == newItem.id,
                  ),
                );
                context.showSnack(
                  updated.isSaved ? 'Saved startup' : 'Removed from saved',
                );
              }
            });
          },
          onInterest: () {
            context.push(
              '${Routes.apply}?type=Investment&name=${Uri.encodeComponent(s.name)}&projectId=${s.id}',
            );
          },
        );
      },
    );
  }
}
