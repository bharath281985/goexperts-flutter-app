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
import '../../domain/entities/proposal.dart';
import '../../domain/repositories/proposal_repository.dart';

/// Embeddable proposals catalog.
class ProposalsListView extends StatefulWidget {
  const ProposalsListView({super.key});

  @override
  State<ProposalsListView> createState() => _ProposalsListViewState();
}

class _ProposalsListViewState extends State<ProposalsListView> {
  int _listKey = 0;

  void _reload() => setState(() => _listKey++);

  @override
  Widget build(BuildContext context) {
    final repo = sl<ProposalRepository>();
    return CatalogView<Proposal>(
      key: ValueKey(_listKey),
      fetcher: repo.getProposals,
      searchHint: 'Search proposals…',
      emptyTitle: 'No proposals yet',
      emptyMessage: 'Apply to projects to see your proposals here.',
      emptyIcon: Icons.description_outlined,
      itemBuilder: (context, p, _) =>
          _ProposalCard(proposal: p, onReturned: _reload),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  const _ProposalCard({required this.proposal, required this.onReturned});
  final Proposal proposal;
  final VoidCallback onReturned;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () async {
        await context.push('${Routes.proposalDetails}/${proposal.id}');
        if (context.mounted) onReturned();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  proposal.projectTitle,
                  style: context.text.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppStatusChip.status(proposal.status, dense: true),
            ],
          ),
          AppSizes.vGapSm,
          Row(
            children: [
              AppAvatar(
                name: proposal.freelancerName,
                imageUrl: proposal.freelancerAvatar,
                size: 24,
              ),
              AppSizes.hGapSm,
              Text(proposal.freelancerName, style: context.text.bodySmall),
              const Spacer(),
              const Icon(
                Icons.star_rounded,
                size: 14,
                color: AppColors.warning,
              ),
              Text(
                ' ${proposal.freelancerRating}',
                style: context.text.labelMedium,
              ),
            ],
          ),
          AppSizes.vGapMd,
          Text(
            proposal.coverLetter,
            style: context.text.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          AppSizes.vGapMd,
          const Divider(height: 1),
          AppSizes.vGapMd,
          Row(
            children: [
              _meta(
                context,
                Icons.payments_outlined,
                proposal.isHourly
                    ? '${Formatters.compactCurrency(proposal.bidAmount)}/hr'
                    : Formatters.compactCurrency(proposal.bidAmount),
              ),
              AppSizes.hGapLg,
              _meta(
                context,
                Icons.schedule_rounded,
                '${proposal.deliveryDays} days',
              ),
              const Spacer(),
              Text(
                Formatters.relative(proposal.submittedAt),
                style: context.text.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _meta(BuildContext context, IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 15, color: AppColors.mutedText),
      const SizedBox(width: 4),
      Text(text, style: context.text.labelMedium),
    ],
  );
}
