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
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_stat_card.dart';
import '../../../../core/widgets/dashboard_header.dart';
import '../../../freelancer_dashboard/presentation/widgets/freelancer_card.dart';

class ClientHomePage extends StatelessWidget {
  const ClientHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final loading =
            state.status == ViewStatus.loading ||
            state.status == ViewStatus.initial;
        return RefreshIndicator(
          onRefresh: () => context.read<DashboardCubit>().refresh(),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Builder(
                builder: (ctx) => DashboardHeader(
                  subtitle:
                      'Manage your projects, teams and hiring in one place.',
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
                          AppPrimaryButton(
                            label: 'Post a New Project',
                            icon: Icons.add_rounded,
                            onPressed: () =>
                                context.push(Routes.clientCreateProject),
                          ),
                          AppSizes.vGapLg,
                          GridView.count(
                            crossAxisCount: context.isMobile ? 2 : 4,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: AppSizes.md,
                            crossAxisSpacing: AppSizes.md,
                            childAspectRatio: 1.35,
                            children: [
                              AppStatCard(
                                label: 'Active Projects',
                                value: '${state.activeProjectsCount}',
                                icon: Icons.work_outline_rounded,
                                color: AppColors.info,
                              ),
                              AppStatCard(
                                label: 'Freelancers Hired',
                                value: '${state.profileCompletionPercent}',
                                icon: Icons.groups_outlined,
                                color: AppColors.success,
                              ),
                              AppStatCard(
                                label: 'Applications',
                                value: '${state.pendingProposalsCount}',
                                icon: Icons.inbox_outlined,
                                color: AppColors.warning,
                                trend: '5',
                                trendUp: true,
                                onTap: () =>
                                    context.push(Routes.clientApplications),
                              ),
                              AppStatCard(
                                label: 'Monthly Spend',
                                value: Formatters.compactCurrency(state.monthlyEarnings),
                                icon: Icons.payments_outlined,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                          AppSizes.vGapLg,
                          AppChartCard(
                            title: 'Project Spending',
                            subtitle: 'Last 6 months',
                            color: AppColors.info,
                            data: _spendChart(state.earningsChart),
                          ),
                          AppSizes.vGapLg,
                          AppSectionHeader(
                            title: 'Recommended Freelancers',
                            actionLabel: 'See all',
                            onAction: () =>
                                context.push(Routes.clientFreelancers),
                          ),
                          AppSizes.vGapMd,
                          for (final f in state.freelancers.take(3))
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSizes.md,
                              ),
                              child: AppFreelancerCard(
                                freelancer: f,
                                onTap: () => context.push(
                                  '${Routes.publicFreelancer}/${f.id}',
                                ),
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

List<BarData> _spendChart(List<double> raw) {
  if (raw.isEmpty) {
    return const [
      BarData('Jan', 320),
      BarData('Feb', 280),
      BarData('Mar', 400),
      BarData('Apr', 360),
      BarData('May', 520),
      BarData('Jun', 640),
    ];
  }
  const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
  final values = raw.length >= 6 ? raw.sublist(0, 6) : raw;
  return [
    for (var i = 0; i < values.length; i++) BarData(labels[i], values[i]),
    if (values.length < 6)
      for (var i = values.length; i < 6; i++) BarData(labels[i], 0),
  ];
}
