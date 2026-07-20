import 'package:flutter/material.dart';

import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/responsive_wrapper.dart';
import '../../../../core/widgets/safe_bottom.dart';
import '../../domain/entities/current_subscription.dart';
import '../../domain/repositories/subscription_repository.dart';
import 'subscription_selection_page.dart';

class CurrentSubscriptionPage extends StatefulWidget {
  const CurrentSubscriptionPage({super.key});

  @override
  State<CurrentSubscriptionPage> createState() =>
      _CurrentSubscriptionPageState();
}

class _CurrentSubscriptionPageState extends State<CurrentSubscriptionPage> {
  bool _loading = true;
  String? _error;
  CurrentSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await sl<SubscriptionRepository>().getCurrentSubscription();
    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() {
          _error = failure.message;
          _subscription = null;
          _loading = false;
        });
      },
      (subscription) {
        setState(() {
          _subscription = subscription?.isActive == true ? subscription : null;
          _loading = false;
        });
      },
    );
  }

  Future<void> _openPlans() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SubscriptionSelectionPage(isOnboarding: false),
      ),
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Subscription'),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveWrapper(
        maxWidth: 640,
        child: Column(
          children: [
            Expanded(child: _content(context)),
            SafeBottom(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.96),
                  border: Border(
                    top: BorderSide(color: context.theme.dividerColor),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.xl,
                  AppSizes.md,
                  AppSizes.xl,
                  AppSizes.md,
                ),
                child: AppPrimaryButton(
                  label: 'View Plans',
                  icon: Icons.workspace_premium_outlined,
                  onPressed: _openPlans,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 42,
                color: AppColors.danger,
              ),
              AppSizes.vGapMd,
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium,
              ),
              AppSizes.vGapMd,
              AppPrimaryButton(
                label: 'Retry',
                icon: Icons.refresh_rounded,
                onPressed: _load,
                expanded: false,
              ),
            ],
          ),
        ),
      );
    }

    final subscription = _subscription;
    if (subscription == null) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.xl),
          children: [
            const SizedBox(height: 72),
            Container(
              padding: const EdgeInsets.all(AppSizes.xxl),
              decoration: BoxDecoration(
                color: context.theme.cardColor,
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                border: Border.all(color: context.theme.dividerColor),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_outlined,
                      size: 34,
                      color: AppColors.primary,
                    ),
                  ),
                  AppSizes.vGapLg,
                  Text(
                    'No current plan',
                    textAlign: TextAlign.center,
                    style: context.text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  AppSizes.vGapSm,
                  Text(
                    'Choose a subscription plan to activate your account benefits.',
                    textAlign: TextAlign.center,
                    style: context.text.bodyMedium?.copyWith(
                      color: AppColors.mutedText,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.xl),
        children: [
          _PlanHero(
            subscription: subscription,
            price: _price(subscription.plan),
            period: _period(subscription),
            daysLeft: _daysLeft(subscription.endDate),
          ),
          AppSizes.vGapLg,
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  icon: Icons.calendar_today_outlined,
                  label: 'Started',
                  value: _date(subscription.startDate),
                ),
              ),
              AppSizes.hGapMd,
              Expanded(
                child: _MetricTile(
                  icon: Icons.event_available_outlined,
                  label: 'Renews',
                  value: _date(subscription.endDate),
                ),
              ),
            ],
          ),
          AppSizes.vGapMd,
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  icon: Icons.autorenew_rounded,
                  label: 'Auto Renew',
                  value: subscription.autoRenew ? 'Enabled' : 'Disabled',
                ),
              ),
              AppSizes.hGapMd,
              Expanded(
                child: _MetricTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Role',
                  value: subscription.plan.role.isEmpty
                      ? 'Account'
                      : _title(subscription.plan.role),
                ),
              ),
            ],
          ),
          if (subscription.plan.features.isNotEmpty) ...[
            AppSizes.vGapLg,
            _SectionPanel(
              title: 'Plan Features',
              icon: Icons.verified_outlined,
              children: [
                for (final feature in subscription.plan.features)
                  _FeatureRow(feature: feature),
              ],
            ),
          ],
          if (subscription.plan.limits.isNotEmpty) ...[
            AppSizes.vGapLg,
            _SectionPanel(
              title: 'Plan Limits',
              icon: Icons.tune_rounded,
              children: [
                for (final entry in subscription.plan.limits.entries)
                  _LimitRow(
                    label: _title(entry.key),
                    value: entry.value?.toString() == '-1'
                        ? 'Unlimited'
                        : entry.value?.toString() ?? '',
                  ),
              ],
            ),
          ],
          AppSizes.vGapXxl,
        ],
      ),
    );
  }

  String _price(CurrentSubscriptionPlan plan) {
    final amount = plan.currency.toUpperCase() == 'INR'
        ? Formatters.currency(plan.amount)
        : '${plan.currency} ${plan.amount.toStringAsFixed(0)}';
    final duration = plan.duration.isEmpty ? '' : ' / ${_title(plan.duration)}';
    return '$amount$duration';
  }

  String _period(CurrentSubscription subscription) {
    final start = _date(subscription.startDate);
    final end = _date(subscription.endDate);
    return '$start - $end';
  }

  String _date(DateTime? date) {
    if (date == null) return '-';
    return Formatters.date(date.toLocal());
  }

  int? _daysLeft(DateTime? endDate) {
    if (endDate == null) return null;
    final today = DateTime.now();
    final end = endDate.toLocal();
    final diff = DateTime(
      end.year,
      end.month,
      end.day,
    ).difference(DateTime(today.year, today.month, today.day)).inDays;
    return diff < 0 ? 0 : diff;
  }

  String _title(String value) {
    final words = value
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.trim().isNotEmpty);
    return words
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

class _PlanHero extends StatelessWidget {
  const _PlanHero({
    required this.subscription,
    required this.price,
    required this.period,
    required this.daysLeft,
  });

  final CurrentSubscription subscription;
  final String price;
  final String period;
  final int? daysLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                ),
              ),
              AppSizes.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.plan.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    AppSizes.vGapXs,
                    Text(
                      period,
                      style: context.text.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSizes.vGapXxl,
          Text(
            price,
            style: context.text.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          AppSizes.vGapLg,
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: [
              _HeroChip(
                icon: Icons.check_circle_outline_rounded,
                label: subscription.status.isEmpty
                    ? 'Active'
                    : subscription.status.toUpperCase(),
              ),
              if (daysLeft != null)
                _HeroChip(
                  icon: Icons.schedule_rounded,
                  label: daysLeft == 1 ? '1 day left' : '$daysLeft days left',
                ),
              _HeroChip(
                icon: Icons.autorenew_rounded,
                label: subscription.autoRenew
                    ? 'Auto renew on'
                    : 'Manual renew',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          AppSizes.hGapXs,
          Text(
            label,
            style: context.text.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 104),
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: context.theme.dividerColor),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          AppSizes.vGapMd,
          Text(
            label,
            style: context.text.labelSmall?.copyWith(
              color: AppColors.mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSizes.vGapXs,
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionPanel extends StatelessWidget {
  const _SectionPanel({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Icon(icon, size: 18, color: AppColors.primary),
                ),
                AppSizes.hGapMd,
                Text(
                  title,
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.feature});

  final String feature;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 20,
            color: AppColors.success,
          ),
          AppSizes.hGapSm,
          Expanded(
            child: Text(
              feature,
              style: context.text.bodyMedium?.copyWith(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _LimitRow extends StatelessWidget {
  const _LimitRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: context.text.bodyMedium?.copyWith(
                color: AppColors.mutedText,
              ),
            ),
          ),
          AppSizes.hGapMd,
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
            child: Text(
              value,
              style: context.text.labelMedium?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
