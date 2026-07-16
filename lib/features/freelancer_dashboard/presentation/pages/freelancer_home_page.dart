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
import '../../../../core/widgets/app_chart_card.dart';
import '../../../../core/widgets/app_loading_shimmer.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_stat_card.dart';
import '../../../../core/widgets/dashboard_header.dart';
import '../../../meetings/presentation/widgets/meeting_card.dart';
import '../../../projects/presentation/widgets/project_card.dart';

class FreelancerHomePage extends StatelessWidget {
  const FreelancerHomePage({super.key});

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
                      "Here's what's happening with your freelance work today.",
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
                          _ProfileCompletionCard(
                            completionPercent: state.profileCompletionPercent,
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
                                label: 'Available Balance',
                                value: Formatters.compactCurrency(
                                  state.wallet?.available ?? 0,
                                ),
                                icon: Icons.account_balance_wallet_outlined,
                                color: AppColors.success,
                                trend: '12%',
                                onTap: () => context.push(Routes.wallet),
                              ),
                              AppStatCard(
                                label: 'Active Projects',
                                value: '${state.activeProjectsCount}',
                                icon: Icons.work_outline_rounded,
                                color: AppColors.info,
                              ),
                              AppStatCard(
                                label: 'Pending Proposals',
                                value: '${state.pendingProposalsCount}',
                                icon: Icons.description_outlined,
                                color: AppColors.warning,
                              ),
                              AppStatCard(
                                label: 'This Month',
                                value:
                                    Formatters.compactCurrency(state.monthlyEarnings),
                                icon: Icons.trending_up_rounded,
                                color: AppColors.primary,
                                trend: '8%',
                              ),
                            ],
                          ),
                          AppSizes.vGapLg,
                          AppChartCard(
                            title: 'Monthly Earnings',
                            subtitle: 'Last 6 months',
                            data: _chartData(state.earningsChart),
                          ),
                          AppSizes.vGapLg,
                          if (state.meetings.isNotEmpty) ...[
                            AppSectionHeader(
                              title: 'Upcoming Meetings',
                              actionLabel: 'See all',
                              onAction: () => context.push(Routes.meetings),
                            ),
                            AppSizes.vGapMd,
                            AppMeetingCard(meeting: state.meetings.first),
                            AppSizes.vGapLg,
                          ],
                          AppSectionHeader(
                            title: 'Recommended Projects',
                            actionLabel: 'See all',
                            onAction: () =>
                                context.push(Routes.freelancerProjects),
                          ),
                          AppSizes.vGapMd,
                          for (final p in state.projects.take(3))
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSizes.md,
                              ),
                              child: AppProjectCard(
                                project: p,
                                onTap: () => context.push(
                                  '${Routes.projectDetails}/${p.id}',
                                ),
                              ),
                            ),
                          AppSizes.vGapMd,
                          _TrendingSkillsCard(skills: state.topSkills),
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

class _ProfileCompletionCard extends StatelessWidget {
  const _ProfileCompletionCard({required this.completionPercent});

  final int completionPercent;

  @override
  Widget build(BuildContext context) {
    final progress = (completionPercent / 100).clamp(0, 1).toDouble();
    return AppCard(
      color: AppColors.primary.withValues(alpha: 0.06),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
                Text(
                  '$completionPercent%',
                  style: context.text.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          AppSizes.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Complete your profile', style: context.text.titleSmall),
                Text(
                  'Add a portfolio & certificates to win more work.',
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
        ],
      ),
    );
  }
}

class _TrendingSkillsCard extends StatelessWidget {
  const _TrendingSkillsCard({this.skills});

  final List<String>? skills;
  @override
  Widget build(BuildContext context) {
    const fallbackSkills = [
      'Flutter',
      'AI/ML',
      'Next.js',
      'Kubernetes',
      'LLMs',
      'Rust',
      'Figma',
    ];

    final effectiveSkills =
        (skills != null && skills!.isNotEmpty)
            ? skills!
                .where((s) => s.trim().isNotEmpty && !_skillLooksLikeUuid(s))
                .toList()
            : fallbackSkills;
    final displaySkills =
        effectiveSkills.isNotEmpty ? effectiveSkills : fallbackSkills;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'Trending Skills',
            subtitle: 'In demand this week',
          ),
          AppSizes.vGapMd,
              Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: [
                  for (final s in displaySkills)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        s,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
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
  }
}

List<BarData> _chartData(List<double> raw) {
  if (raw.isEmpty) {
    // Keep current visuals during early integration.
    return const [
      BarData('Jan', 120),
      BarData('Feb', 160),
      BarData('Mar', 140),
      BarData('Apr', 200),
      BarData('May', 180),
      BarData('Jun', 240),
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

final _skillUuidPattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  caseSensitive: false,
);

bool _skillLooksLikeUuid(String value) =>
    _skillUuidPattern.hasMatch(value.trim());

