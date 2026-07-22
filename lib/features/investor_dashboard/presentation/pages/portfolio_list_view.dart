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
import '../../../../core/utils/result.dart';
import '../../../../core/utils/enums.dart';

/// Embeddable portfolio holdings and investment history catalog.
class PortfolioListView extends StatelessWidget {
  const PortfolioListView({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = sl<InvestorRepository>();
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: context.text.labelSmall?.color,
            tabs: const [
              Tab(text: 'Holdings'),
              Tab(text: 'History'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Tab 1: Holdings (Active Portfolio Items)
                CatalogView<PortfolioItem>(
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
                    child: _PortfolioSummary<PortfolioItem>(),
                  ),
                  itemBuilder: (context, item, _) => _PortfolioTile(item: item),
                ),
                // Tab 2: History (Historical Investment Items)
                CatalogView<InvestmentHistoryItem>(
                  fetcher: repo.getInvestmentHistory,
                  showSearch: false,
                  emptyTitle: 'No investment history',
                  emptyIcon: Icons.history_rounded,
                  skeletonHeight: 88,
                  header: const Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSizes.screenPadding,
                      AppSizes.md,
                      AppSizes.screenPadding,
                      0,
                    ),
                    child: _PortfolioSummary<InvestmentHistoryItem>(),
                  ),
                  itemBuilder: (context, item, _) => _HistoryTile(item: item),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioSummary<T> extends StatefulWidget {
  const _PortfolioSummary();

  @override
  State<_PortfolioSummary<T>> createState() => _PortfolioSummaryState<T>();
}

class _PortfolioSummaryState<T> extends State<_PortfolioSummary<T>> {
  late Future<Result<PortfolioPerformance>> _performanceFuture;

  @override
  void initState() {
    super.initState();
    _performanceFuture = sl<InvestorRepository>().getPortfolioPerformance();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ListBloc<T>, ListState<T>>(
      listenWhen: (prev, curr) =>
          (curr.status == ViewStatus.loading &&
              prev.status != ViewStatus.loading) ||
          (curr.status == ViewStatus.refreshing &&
              prev.status != ViewStatus.refreshing),
      listener: (context, state) {
        setState(() {
          _performanceFuture = sl<InvestorRepository>()
              .getPortfolioPerformance();
        });
      },
      child: BlocBuilder<ListBloc<T>, ListState<T>>(
        builder: (context, listState) {
          return FutureBuilder<Result<PortfolioPerformance>>(
            future: _performanceFuture,
            builder: (context, snapshot) {
              double total = 0.0;
              double avgRoi = 0.0;
              bool hasData = false;

              if (snapshot.hasData) {
                snapshot.data!.fold((_) {}, (perf) {
                  total = perf.currentValue;
                  avgRoi = perf.totalRoi;
                  hasData = true;
                });
              }

              // Fallback to local calculation if API hasn't loaded yet or failed (holdings list tab only)
              if (!hasData && listState.items.isNotEmpty) {
                final dynamic items = listState.items;
                if (items is List<PortfolioItem>) {
                  total = items.fold<double>(
                    0.0,
                    (sum, item) => sum + item.currentValue,
                  );
                  avgRoi = items.isEmpty
                      ? 0.0
                      : (items.fold<double>(
                              0.0,
                              (sum, item) => sum + item.roi,
                            ) /
                            items.length);
                }
              }

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
                            context.tr('Total Portfolio Value'),
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
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusPill,
                            ),
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
        },
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

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});
  final InvestmentHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final statusColor = item.status.toLowerCase() == 'completed'
        ? AppColors.success
        : (item.status.toLowerCase() == 'pending'
              ? AppColors.warning
              : AppColors.primary);

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
                  '${item.equity.toStringAsFixed(0)}% equity · ${Formatters.date(item.date)}',
                  style: context.text.labelSmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.compactCurrency(item.amount),
                style: context.text.titleSmall,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
