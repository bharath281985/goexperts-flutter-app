import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_sizes.dart';
import '../extensions/context_extensions.dart';
import '../utils/enums.dart';
import '../widgets/app_card.dart';
import '../widgets/app_scaffold.dart';

class _Report {
  const _Report(this.title, this.subtitle, this.icon);
  final String title;
  final String subtitle;
  final IconData icon;
}

/// Reusable reports list (generated documents) rendered per role.
class RoleReportsPage extends StatelessWidget {
  const RoleReportsPage({super.key, required this.role, this.title});

  final UserRole role;
  final String? title;

  List<_Report> _reports() {
    switch (role) {
      case UserRole.client:
        return const [
          _Report('Hiring funnel report', 'Applications → hires · last 30 days', Icons.filter_alt_outlined),
          _Report('Spending summary', 'Project spend by category', Icons.pie_chart_outline_rounded),
          _Report('Freelancer performance', 'Ratings & delivery times', Icons.groups_outlined),
          _Report('Department performance', 'Cross-team throughput', Icons.apartment_outlined),
        ];
      case UserRole.investor:
        return const [
          _Report('Portfolio performance', 'ROI & valuation changes', Icons.trending_up_rounded),
          _Report('Deal pipeline report', 'Stage-by-stage breakdown', Icons.handshake_outlined),
          _Report('Due diligence summary', 'Open items across deals', Icons.fact_check_outlined),
          _Report('Capital deployed', 'Investments by industry', Icons.account_balance_outlined),
        ];
      default:
        return const [
          _Report('Activity report', 'Your recent activity', Icons.insights_outlined),
          _Report('Earnings report', 'Income & payouts', Icons.payments_outlined),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final reports = _reports();
    return AppScaffold(
      appBar: AppBar(title: Text(title ?? 'Reports')),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        itemCount: reports.length,
        separatorBuilder: (_, __) => AppSizes.vGapMd,
        itemBuilder: (context, i) {
          final r = reports[i];
          return AppCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                  child: Icon(r.icon, color: AppColors.primary),
                ),
                AppSizes.hGapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.title, style: context.text.titleSmall),
                      Text(r.subtitle, style: context.text.labelSmall),
                    ],
                  ),
                ),
                IconButton(onPressed: () => context.showSnack('Downloading ${r.title}'), icon: const Icon(Icons.download_rounded)),
              ],
            ),
          );
        },
      ),
    );
  }
}
