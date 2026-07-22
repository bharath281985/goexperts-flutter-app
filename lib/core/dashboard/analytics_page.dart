import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_sizes.dart';
import '../extensions/context_extensions.dart';
import '../utils/enums.dart';
import '../widgets/app_card.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_section_header.dart';
import '../widgets/app_stat_card.dart';

class _Metric {
  const _Metric(this.label, this.value, this.icon, this.trend, this.color);
  final String label;
  final String value;
  final IconData icon;
  final String trend;
  final Color color;
}

/// A reusable analytics dashboard rendered per role with headline metrics and
/// a lightweight bar chart. API-ready: swap the seeded series for live data.
class RoleAnalyticsPage extends StatelessWidget {
  const RoleAnalyticsPage({super.key, required this.role, this.title});

  final UserRole role;
  final String? title;

  List<_Metric> _metrics() {
    switch (role) {
      case UserRole.freelancer:
        return const [
          _Metric('Profile views', '1,284', Icons.visibility_outlined, '+12%', AppColors.info),
          _Metric('Proposal win rate', '38%', Icons.emoji_events_outlined, '+4%', AppColors.success),
          _Metric('Monthly earnings', '₹2.3L', Icons.payments_outlined, '+18%', AppColors.primary),
          _Metric('Avg rating', '4.9', Icons.star_outline_rounded, '+0.1', AppColors.warning),
        ];
      case UserRole.client:
        return const [
          _Metric('Projects posted', '18', Icons.work_outline_rounded, '+2', AppColors.primary),
          _Metric('Hire rate', '64%', Icons.how_to_reg_outlined, '+6%', AppColors.success),
          _Metric('Monthly spend', '₹8.4L', Icons.account_balance_wallet_outlined, '+9%', AppColors.info),
          _Metric('Avg time to hire', '4.2d', Icons.timelapse_outlined, '-1d', AppColors.warning),
        ];
      case UserRole.investor:
        return const [
          _Metric('Portfolio value', '₹7.2Cr', Icons.trending_up_rounded, '+21%', AppColors.success),
          _Metric('Active deals', '6', Icons.handshake_outlined, '+1', AppColors.primary),
          _Metric('Avg ROI', '2.4x', Icons.assessment_outlined, '+0.2x', AppColors.info),
          _Metric('Deals reviewed', '42', Icons.fact_check_outlined, '+8', AppColors.warning),
        ];
      case UserRole.founder:
        return const [
          _Metric('Startup views', '5,410', Icons.visibility_outlined, '+15%', AppColors.info),
          _Metric('Deck views', '312', Icons.slideshow_outlined, '+22%', AppColors.primary),
          _Metric('Investor interests', '24', Icons.favorite_border_rounded, '+5', AppColors.success),
          _Metric('Funding raised', '₹60L', Icons.savings_outlined, '+₹20L', AppColors.warning),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _metrics();
    const series = [0.4, 0.65, 0.5, 0.8, 0.72, 0.95, 0.6];
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return AppScaffold(
      appBar: AppBar(title: Text(title ?? 'Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          GridView.count(
            crossAxisCount: context.isMobile ? 2 : 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSizes.md,
            mainAxisSpacing: AppSizes.md,
            childAspectRatio: 1.5,
            children: [
              for (final m in metrics)
                AppStatCard(label: m.label, value: m.value, icon: m.icon, color: m.color, trend: m.trend),
            ],
          ),
          AppSizes.vGapLg,
          const AppSectionHeader(title: 'This week'),
          AppSizes.vGapMd,
          AppCard(
            child: SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < series.length; i++)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 130 * series[i],
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                            ),
                          ),
                          AppSizes.vGapSm,
                          Text(labels[i], style: context.text.labelSmall),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
