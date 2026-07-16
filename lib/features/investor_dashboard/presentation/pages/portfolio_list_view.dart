import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/catalog_view.dart';
import '../../domain/entities/investor.dart';
import '../../domain/repositories/investor_repository.dart';

/// Embeddable portfolio holdings catalog.
class PortfolioListView extends StatelessWidget {
  const PortfolioListView({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = sl<InvestorRepository>();
    return CatalogView<PortfolioItem>(
      fetcher: repo.getPortfolio,
      showSearch: false,
      emptyTitle: 'No holdings yet',
      emptyIcon: Icons.pie_chart_outline_rounded,
      skeletonHeight: 88,
      header: const Padding(
        padding: EdgeInsets.fromLTRB(AppSizes.screenPadding, AppSizes.md, AppSizes.screenPadding, 0),
        child: _PortfolioSummary(),
      ),
      itemBuilder: (context, item, _) => _PortfolioTile(item: item),
    );
  }
}

class _PortfolioSummary extends StatelessWidget {
  const _PortfolioSummary();
  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.primary,
      border: false,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Portfolio Value',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
                const SizedBox(height: 4),
                Text(Formatters.compactCurrency(72200000),
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('+34% ROI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PortfolioTile extends StatelessWidget {
  const _PortfolioTile({required this.item});
  final PortfolioItem item;

  @override
  Widget build(BuildContext context) {
    final positive = item.roi >= 0;
    return AppCard(
      child: Row(
        children: [
          AppAvatar(name: item.startupName, imageUrl: item.logoUrl, size: 44),
          AppSizes.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.startupName, style: context.text.titleSmall),
                Text('${item.equity.toStringAsFixed(0)}% equity · ${Formatters.date(item.investedAt)}',
                    style: context.text.labelSmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Formatters.compactCurrency(item.currentValue), style: context.text.titleSmall),
              Text('${positive ? '+' : ''}${item.roi.toStringAsFixed(0)}%',
                  style: TextStyle(color: positive ? AppColors.success : AppColors.danger, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}
