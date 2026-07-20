import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/catalog_view.dart';
import '../../domain/entities/investor.dart';
import '../../domain/repositories/investor_repository.dart';
import '../../../meetings/presentation/pages/meetings_list_view.dart';

/// Embeddable deal-room catalog.
class DealsListView extends StatelessWidget {
  const DealsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = sl<InvestorRepository>();
    return CatalogView<Deal>(
      fetcher: repo.getDeals,
      searchHint: 'Search deals…',
      emptyTitle: 'No active deals',
      emptyIcon: Icons.handshake_outlined,
      skeletonHeight: 100,
      itemBuilder: (context, deal, _) => _DealCard(deal: deal),
    );
  }
}

class _DealCard extends StatelessWidget {
  const _DealCard({required this.deal});
  final Deal deal;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => context.push('${Routes.startupDetails}/${deal.id}'),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppAvatar(
                        name: deal.startupName,
                        imageUrl: deal.startupLogo,
                        size: 46,
                      ),
                      AppSizes.hGapMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              deal.startupName,
                              style: context.text.titleSmall,
                            ),
                            Text(
                              '${deal.founderName} · ${deal.stage}',
                              style: context.text.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      AppStatusChip.status(deal.status, dense: true),
                    ],
                  ),
                  AppSizes.vGapMd,
                  Row(
                    children: [
                      Expanded(
                        child: _stat(
                          context,
                          'Amount',
                          Formatters.compactCurrency(deal.amount),
                        ),
                      ),
                      Expanded(
                        child: _stat(
                          context,
                          'Equity',
                          '${deal.equity.toStringAsFixed(0)}%',
                        ),
                      ),
                      Expanded(
                        child: _stat(context, 'Docs', '${deal.documentsCount}'),
                      ),
                      if (deal.hasNda)
                        const AppStatusChip(
                          label: 'NDA',
                          color: AppColors.info,
                          icon: Icons.lock_outline_rounded,
                          dense: true,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: AppSizes.lg,
              right: AppSizes.lg,
              bottom: AppSizes.lg,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                    ),
                    icon: const Icon(Icons.person_outline_rounded, size: 16),
                    label: const Text('View Founder'),
                    onPressed: () {
                      // publicFounder → /public/startups/:startupId
                      final startupId = deal.founderId ?? deal.id;
                      context.push('${Routes.publicFounder}/$startupId');
                    },
                  ),
                ),
                AppSizes.hGapSm,
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                    ),
                    icon: const Icon(Icons.calendar_today_outlined, size: 16),
                    label: const Text('Schedule'),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => ScheduleMeetingSheet(
                          onScheduled: () {},
                          preselectedParticipantId: deal.founderId ?? deal.id,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value, style: context.text.titleSmall),
      Text(label, style: context.text.labelSmall),
    ],
  );
}
