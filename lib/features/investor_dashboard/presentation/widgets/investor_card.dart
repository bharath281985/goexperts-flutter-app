import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/investor.dart';

/// Reusable investor card for founder discovery.
class AppInvestorCard extends StatelessWidget {
  const AppInvestorCard({
    super.key,
    required this.investor,
    this.onTap,
    this.onFollow,
    this.onConnect,
  });

  final Investor investor;
  final VoidCallback? onTap;
  final VoidCallback? onFollow;
  final VoidCallback? onConnect;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(
                name: investor.name,
                imageUrl: investor.avatarUrl,
                size: 52,
              ),
              AppSizes.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            investor.name,
                            style: context.text.titleSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (investor.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: AppColors.info,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      [
                        if (investor.investorType.trim().isNotEmpty)
                          investor.investorType.trim(),
                        if (investor.company.trim().isNotEmpty)
                          investor.company.trim(),
                      ].join(' · '),
                      style: context.text.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSizes.vGapMd,
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: context.theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _stat(
                    context,
                    'Ticket',
                    '${Formatters.compactCurrency(investor.minInvestment)}-${Formatters.compactCurrency(investor.maxInvestment)}',
                  ),
                ),
                Expanded(
                  child: _stat(context, 'Deals', '${investor.dealsCount}'),
                ),
                Expanded(
                  child: _stat(
                    context,
                    'Portfolio',
                    '${investor.portfolioCount}',
                  ),
                ),
              ],
            ),
          ),
          AppSizes.vGapMd,
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: [
              for (final s in investor.interestedIndustries.take(3))
                _pill(context, s),
            ],
          ),
          AppSizes.vGapMd,
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onFollow,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                  ),
                  child: Text(investor.isFollowing ? 'Following' : 'Follow'),
                ),
              ),
              AppSizes.hGapMd,
              Expanded(
                child: FilledButton(
                  onPressed: onConnect,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(40),
                  ),
                  child: const Text('Connect'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String label, String value) => Column(
    children: [
      Text(value, style: context.text.titleSmall, textAlign: TextAlign.center),
      Text(label, style: context.text.labelSmall),
    ],
  );

  Widget _pill(BuildContext context, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
