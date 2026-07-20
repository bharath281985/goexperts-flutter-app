import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_filter_bottom_sheet.dart';
import '../../../../core/widgets/catalog_view.dart';
import '../../domain/entities/investor.dart';
import '../../domain/repositories/investor_repository.dart';
import '../widgets/investor_card.dart';

/// Embeddable investor discovery catalog (used by founders).
class InvestorsListView extends StatelessWidget {
  const InvestorsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = sl<InvestorRepository>();
    return CatalogView<Investor>(
      fetcher: repo.getInvestors,
      searchHint: 'Search investors, industries…',
      emptyTitle: 'No investors found',
      emptyIcon: Icons.trending_up_rounded,
      sortOptions: const ['Most deals', 'Ticket: High to Low'],
      filterSections: () => [
        FilterSection(
          key: 'industry',
          title: 'Industries',
          options: const [
            'FinTech',
            'SaaS',
            'AI',
            'HealthTech',
            'EdTech',
            'CleanTech',
            'Manufacturing',
            'AgriTech',
            'E-Commerce',
          ],
        ),
        FilterSection(
          key: 'partnerRole',
          title: 'Partner Role',
          options: const [
            'Working Partner',
            'Sleeping Partner',
            'Strategic Partner',
            'Mentor Investor',
          ],
        ),
      ],
      itemBuilder: (context, i, _) => AppInvestorCard(
        investor: i,
        onTap: () => context.push('${Routes.publicInvestor}/${i.id}'),
        onFollow: () => context.showSnack(
          i.isFollowing ? 'Unfollowed' : 'Following ${i.name}',
        ),
        onConnect: () =>
            context.showSnack('Connection request sent to ${i.name}'),
      ),
    );
  }
}
