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
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_loading_shimmer.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_stat_card.dart';
import '../../../../core/widgets/dashboard_header.dart';
import '../../../investor_dashboard/presentation/widgets/investor_card.dart';

class FounderHomePage extends StatelessWidget {
  const FounderHomePage({super.key});

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
                  subtitle: 'Grow your startup, raise funds and engage investors.',
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
                          const _FundingCard(),
                          AppSizes.vGapLg,
                          GridView.count(
                            crossAxisCount: context.isMobile ? 2 : 4,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: AppSizes.md,
                            crossAxisSpacing: AppSizes.md,
                            childAspectRatio: 1.35,
                            children: [
                              AppStatCard(label: 'Investor Interests', value: '${state.activeProjectsCount}', icon: Icons.favorite_outline_rounded, color: AppColors.primary),
                              AppStatCard(label: 'Pitch Deck Views', value: '${state.pendingProposalsCount}', icon: Icons.slideshow_outlined, color: AppColors.info),
                              AppStatCard(label: 'Startup Views', value: '${state.profileCompletionPercent}', icon: Icons.visibility_outlined, color: AppColors.warning),
                              AppStatCard(label: 'Meetings', value: state.topSkills.isNotEmpty ? state.topSkills.first : '0', icon: Icons.event_outlined, color: AppColors.success),
                            ],
                          ),
                          AppSizes.vGapLg,
                          AppSectionHeader(
                            title: 'Recommended Investors',
                            actionLabel: 'See all',
                            onAction: () => context.push(Routes.founderInvestors),
                          ),
                          AppSizes.vGapMd,
                          for (final i in state.investors.take(3))
                            Padding(
                              padding: const EdgeInsets.only(bottom: AppSizes.md),
                              child: AppInvestorCard(
                                investor: i,
                                onTap: () => context.push('${Routes.publicInvestor}/${i.id}'),
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

class _FundingCard extends StatelessWidget {
  const _FundingCard();
  @override
  Widget build(BuildContext context) {
    final state = context.watch<DashboardCubit>().state;
    final raised = state.monthlyEarnings;
    final goal = raised > 0 ? raised * 2.4 : 20000000.0;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(title: 'Funding Progress', subtitle: 'Seed round'),
          AppSizes.vGapMd,
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
                  value: goal == 0 ? 0 : (raised / goal).clamp(0, 1),
              minHeight: 10,
              backgroundColor: context.theme.dividerColor,
              valueColor: const AlwaysStoppedAnimation(AppColors.success),
            ),
          ),
          AppSizes.vGapMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Formatters.compactCurrency(raised), style: context.text.titleMedium?.copyWith(color: AppColors.success)),
                  Text('Raised', style: context.text.labelSmall),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(Formatters.compactCurrency(goal), style: context.text.titleMedium),
                  Text('Goal', style: context.text.labelSmall),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
