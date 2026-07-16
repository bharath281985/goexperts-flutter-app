import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_secondary_button.dart';
import '../../../../core/widgets/detail_actions.dart';
import '../../../../core/widgets/detail_view.dart';
import '../../domain/entities/catalog_entities.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../widgets/detail_widgets.dart';

class OpportunityDetailsPage extends StatelessWidget {
  const OpportunityDetailsPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return DetailView<InvestmentOpportunity>(
      title: 'Investment Opportunity',
      fetcher: () => sl<CatalogRepository>().getOpportunity(id),
      actions: detailActions(context, shareTitle: 'this opportunity', shareLink: '${Routes.opportunityDetails}/$id', reportType: 'startup'),
      bottomBar: (context, o) => Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Row(
          children: [
            Expanded(child: AppSecondaryButton(label: 'Express Interest', icon: Icons.favorite_border_rounded, onPressed: () => context.showSnack('Interest expressed'))),
            AppSizes.hGapMd,
            Expanded(flex: 2, child: AppPrimaryButton(label: 'Invest', icon: Icons.trending_up_rounded, onPressed: () => context.push('${Routes.apply}?type=Investment'))),
          ],
        ),
      ),
      builder: (context, o) => ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          DetailHeroBanner(
            icon: Icons.rocket_launch_outlined,
            title: o.startupName,
            subtitle: '${o.industry} · ${o.stage}',
            chips: [
              DetailStatChip(icon: Icons.percent_rounded, label: '${o.equityOffered.toStringAsFixed(0)}% equity'),
              if (o.deadline != null) DetailStatChip(icon: Icons.timer_outlined, label: 'Closes ${Formatters.date(o.deadline!)}'),
            ],
          ),
          AppSizes.vGapLg,
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${Formatters.compactCurrency(o.raisedSoFar)} raised', style: context.text.titleSmall),
                    Text('of ${Formatters.compactCurrency(o.amountSought)}', style: context.text.bodySmall),
                  ],
                ),
                AppSizes.vGapSm,
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: o.progress,
                    minHeight: 8,
                    backgroundColor: context.theme.dividerColor,
                    valueColor: const AlwaysStoppedAnimation(AppColors.success),
                  ),
                ),
              ],
            ),
          ),
          AppSizes.vGapLg,
          Row(
            children: [
              Expanded(child: DetailMetric(icon: Icons.savings_outlined, label: 'Min Ticket', value: Formatters.compactCurrency(o.minTicket))),
              Expanded(child: DetailMetric(icon: Icons.assessment_outlined, label: 'Valuation', value: Formatters.compactCurrency(o.valuation))),
            ],
          ),
          AppSizes.vGapLg,
          DetailSection(title: 'Overview', child: Text(o.summary, style: context.text.bodyMedium)),
          if (o.highlights.isNotEmpty) ...[
            AppSizes.vGapLg,
            DetailSection(
              title: 'Highlights',
              child: Column(
                children: [
                  for (final h in o.highlights)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.sm),
                      child: Row(children: [
                        const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.success),
                        AppSizes.hGapSm,
                        Expanded(child: Text(h, style: context.text.bodyMedium)),
                      ]),
                    ),
                ],
              ),
            ),
          ],
          AppSizes.vGapLg,
          DetailSection(
            title: 'Documents',
            child: Column(
              children: [
                _doc(context, 'Pitch Deck.pdf', () => context.push('${Routes.pitchDeckDetails}/s1')),
                _doc(context, 'Business Plan.pdf', () => context.push('${Routes.businessPlanDetails}/s1')),
                _doc(context, 'Financials.xlsx', () => context.push('${Routes.documentViewer}?type=Excel&name=Financials.xlsx')),
              ],
            ),
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _doc(BuildContext context, String name, VoidCallback onTap) => AppCard(
        margin: const EdgeInsets.only(bottom: AppSizes.sm),
        padding: const EdgeInsets.all(AppSizes.md),
        onTap: onTap,
        child: Row(children: [
          const Icon(Icons.description_outlined, size: 18, color: AppColors.primary),
          AppSizes.hGapMd,
          Expanded(child: Text(name, style: context.text.bodyMedium)),
          const Icon(Icons.chevron_right_rounded, color: AppColors.mutedText),
        ]),
      );
}
