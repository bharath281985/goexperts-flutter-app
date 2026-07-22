import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../core/bloc/list_bloc.dart';
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
        padding: EdgeInsets.fromLTRB(
          AppSizes.screenPadding,
          AppSizes.md,
          AppSizes.screenPadding,
          0,
        ),
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
    return BlocBuilder<ListBloc<PortfolioItem>, ListState<PortfolioItem>>(
      builder: (context, state) {
        final items = state.items;
        final total = items.fold<double>(
          0.0,
          (sum, item) => sum + item.currentValue,
        );
        final avgRoi = items.isEmpty
            ? 0.0
            : (items.fold<double>(0.0, (sum, item) => sum + item.roi) /
                  items.length);

        return AppCard(
          color: AppColors.primary,
          border: false,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Portfolio Value',
                      style: TextStyle(
                        color: Colors.white.withAlpha(216),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.compactCurrency(total),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          avgRoi >= 0
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${avgRoi >= 0 ? '+' : ''}${avgRoi.toStringAsFixed(0)}% ROI',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
                Text(
                  '${item.equity.toStringAsFixed(0)}% equity · ${Formatters.date(item.investedAt)}',
                  style: context.text.labelSmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.compactCurrency(item.currentValue),
                style: context.text.titleSmall,
              ),
              Text(
                '${positive ? '+' : ''}${item.roi.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: positive ? AppColors.success : AppColors.danger,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
