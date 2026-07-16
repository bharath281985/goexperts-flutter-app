import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/dashboard/dashboard_cubit.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_chart_card.dart';
import '../../../../core/widgets/app_loading_shimmer.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_stat_card.dart';
import '../../../../core/widgets/dashboard_header.dart';
import '../../../startup_ideas/presentation/widgets/startup_card.dart';

class InvestorHomePage extends StatelessWidget {
  const InvestorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final loading = state.status == ViewStatus.loading || state.status == ViewStatus.initial;
        return RefreshIndicator(
          onRefresh: () => context.read<DashboardCubit>().refresh(),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Builder(
                builder: (ctx) => DashboardHeader(
                  subtitle: 'Track your deals, pipeline and portfolio performance.',
                  onMenu: () => Scaffold.of(ctx).openDrawer(),
                  unread: state.unreadNotificationsCount,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.screenPadding),
                child: loading
                    ? const AppLoadingShimmer(itemCount: 3, height: 110)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GridView.count(
                            crossAxisCount: context.isMobile ? 2 : 4,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: AppSizes.md,
                            crossAxisSpacing: AppSizes.md,
                            childAspectRatio: 1.35,
                            children: [
                              AppStatCard(label: 'Portfolio Value', value: Formatters.compactCurrency(state.monthlyEarnings), icon: Icons.pie_chart_outline_rounded, color: AppColors.success),
                              AppStatCard(label: 'Active Deals', value: '${state.activeProjectsCount}', icon: Icons.handshake_outlined, color: AppColors.info),
                              AppStatCard(label: 'Saved Startups', value: '${state.pendingProposalsCount}', icon: Icons.bookmark_outline_rounded, color: AppColors.warning),
                              AppStatCard(label: 'Due Diligence', value: '${state.profileCompletionPercent}', icon: Icons.fact_check_outlined, color: AppColors.primary),
                            ],
                          ),
                          AppSizes.vGapLg,
                          AppChartCard(
                            title: 'Investment Pipeline',
                            subtitle: 'Deals by stage',
                            color: AppColors.success,
                            data: _pipelineData(state.earningsChart),
                          ),
                          AppSizes.vGapLg,
                          AppSectionHeader(
                            title: 'Recommended Startups',
                            actionLabel: 'See all',
                            onAction: () => context.push(Routes.investorStartups),
                          ),
                          AppSizes.vGapMd,
                          for (final s in state.startups.take(2))
                            Padding(
                              padding: const EdgeInsets.only(bottom: AppSizes.md),
                              child: AppStartupCard(
                                startup: s,
                                onTap: () => context.push('${Routes.startupDetails}/${s.id}'),
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

List<BarData> _pipelineData(List<double> raw) {
  if (raw.isEmpty) {
    return const [
      BarData('Lead', 8),
      BarData('Screen', 5),
      BarData('DD', 3),
      BarData('Term', 2),
      BarData('Closed', 4),
    ];
  }
  const labels = ['Lead', 'Screen', 'DD', 'Term', 'Closed'];
  final values = raw.length >= 5 ? raw.sublist(0, 5) : raw;
  return [
    for (var i = 0; i < values.length; i++) BarData(labels[i], values[i]),
    if (values.length < 5)
      for (var i = values.length; i < 5; i++) BarData(labels[i], 0),
  ];
}
