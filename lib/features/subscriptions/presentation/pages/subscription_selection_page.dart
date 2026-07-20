import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/payments/payment_checkout_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/subscription_status.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/responsive_wrapper.dart';
import '../../../../core/widgets/safe_bottom.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/repositories/subscription_repository.dart';

class SubscriptionSelectionPage extends StatefulWidget {
  const SubscriptionSelectionPage({super.key, this.isOnboarding = true});
  final bool isOnboarding;

  @override
  State<SubscriptionSelectionPage> createState() =>
      _SubscriptionSelectionPageState();
}

class _SubscriptionSelectionPageState extends State<SubscriptionSelectionPage> {
  bool _yearly = false;
  String _selected = 'pro';
  bool _loading = true;
  bool _saving = false;
  String? _loadError;
  List<SubscriptionPlan> _plans = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
      _plans = const [];
    });
    final repo = sl<SubscriptionRepository>();
    final plansRes = await repo.getPlans();
    final currentRes = await repo.getCurrentPlanId();
    if (!mounted) return;
    plansRes.fold(
      (failure) {
        _loadError = failure.message;
      },
      (plans) {
        _plans = plans;
      },
    );
    currentRes.fold((_) {}, (planId) {
      if (planId != null && planId.isNotEmpty) _selected = planId;
    });
    // Default to a free plan when no current plan is available.
    if (_plans.isNotEmpty &&
        (_selected == 'pro' || !_plans.any((p) => p.id == _selected))) {
      final free = _plans.cast<SubscriptionPlan?>().firstWhere((p) {
        final name = (p?.name ?? '').toLowerCase();
        return (p?.priceMonthly ?? 1) <= 0 ||
            p?.id.toLowerCase() == 'free' ||
            name.contains('free');
      }, orElse: () => _plans.isNotEmpty ? _plans.first : null);
      if (free != null) _selected = free.id;
    }
    if (_plans.isEmpty && _loadError == null) {
      _loadError = 'No subscription plans are available right now.';
    }
    setState(() => _loading = false);
  }

  bool get _isSelectedFree {
    final plan = _plans.cast<SubscriptionPlan?>().firstWhere(
      (p) => p?.id == _selected,
      orElse: () => null,
    );
    if (plan == null) return _selected == 'free';
    final name = plan.name.toLowerCase();
    final amount = _yearly ? plan.priceYearly : plan.priceMonthly;
    return amount <= 0 ||
        plan.id.toLowerCase() == 'free' ||
        name.contains('free');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.isOnboarding &&
                  context.read<AuthBloc>().state.subscriptionStatus ==
                      SubscriptionGateStatus.expired
              ? 'Renew your plan'
              : 'Choose a plan',
        ),
        actions: [
          if (widget.isOnboarding)
            TextButton(
              onPressed: _loading || _saving ? null : _skipWithFreePlan,
              child: const Text('Skip'),
            ),
        ],
      ),
      body: ResponsiveWrapper(
        maxWidth: 640,
        child: Column(
          children: [
            Expanded(child: _buildContent(context)),
            if (!_loading && _plans.isNotEmpty)
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
                    label: _isSelectedFree
                        ? 'Continue with Starter'
                        : 'Subscribe',
                    isLoading: _saving,
                    onPressed: _submit,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_plans.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _loadError ?? 'Unable to load subscription plans.',
                textAlign: TextAlign.center,
                style: context.text.bodyMedium,
              ),
              AppSizes.vGapMd,
              AppPrimaryButton(label: 'Retry', onPressed: _load),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSizes.xl),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.xl),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 22,
                offset: const Offset(0, 12),
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
                  AppSizes.hGapLg,
                  Text(
                    widget.isOnboarding &&
                            context.read<AuthBloc>().state.subscriptionStatus ==
                                SubscriptionGateStatus.expired
                        ? 'Renew your plan'
                        : 'Choose your plan',
                    style: context.text.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              AppSizes.vGapSm,
              Text(
                'Tap a plan to select it and view all included benefits.',
                style: context.text.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.84),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        AppSizes.vGapLg,
        Center(
          child: _BillingToggle(
            yearly: _yearly,
            onMonthly: () => setState(() => _yearly = false),
            onYearly: () => setState(() => _yearly = true),
          ),
        ),
        AppSizes.vGapLg,
        for (final plan in _plans)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.md),
            child: _ExpandablePlanCard(
              plan: plan,
              yearly: _yearly,
              selected: _selected == plan.id,
              onTap: () => setState(() => _selected = plan.id),
            ),
          ),
      ],
    );
  }

  Future<void> _skipWithFreePlan() async {
    final freePlan = _findFreePlan();
    final planId = freePlan?.id ?? 'free';

    setState(() {
      _selected = planId;
      _saving = true;
    });

    final res = await sl<SubscriptionRepository>().subscribe(
      planId,
      yearly: false,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    // Always continue onboarding on Skip — even if the API write fails.
    res.fold(
      (f) => _onSubscriptionSuccess(
        message: 'Continuing with Starter plan',
        planId: planId,
      ),
      (message) => _onSubscriptionSuccess(message: message, planId: planId),
    );
  }

  SubscriptionPlan? _findFreePlan() {
    for (final p in _plans) {
      final name = p.name.toLowerCase();
      final amount = _yearly ? p.priceYearly : p.priceMonthly;
      if (amount <= 0 ||
          p.id.toLowerCase() == 'free' ||
          name.contains('free')) {
        return p;
      }
    }
    return null;
  }

  Future<void> _submit() async {
    if (_plans.isEmpty) return;
    final repo = sl<SubscriptionRepository>();
    final plan = _plans.firstWhere(
      (p) => p.id == _selected,
      orElse: () => _plans.first,
    );
    final amount = _yearly ? plan.priceYearly : plan.priceMonthly;
    final name = plan.name.toLowerCase();
    final isFree =
        amount <= 0 ||
        _selected.toLowerCase() == 'free' ||
        name.contains('free');

    setState(() => _saving = true);

    if (!isFree) {
      final checkout = sl<PaymentCheckoutService>();
      final result = await checkout.checkoutWithEasebuzz(
        purpose: 'subscription',
        amount: amount,
        planId: _selected,
        metadata: {'billingCycle': _yearly ? 'yearly' : 'monthly'},
      );
      if (!mounted) return;

      await result.fold(
        (f) async {
          setState(() => _saving = false);
          context.showSnack(f.message, isError: true);
        },
        (paid) async {
          final sdk = paid.checkout;
          final verify = await checkout.verify(
            paymentId: paid.payment.paymentId,
            gateway: paid.payment.gateway,
            purpose: 'subscription',
            planId: _selected,
            verification: {
              'status': 'success',
              'orderId': paid.payment.orderId,
              'txnid': paid.payment.orderId,
              'billingCycle': _yearly ? 'yearly' : 'monthly',
              ...sdk.raw,
              if (sdk.raw['payment_response'] is Map)
                ...Map<String, dynamic>.from(
                  sdk.raw['payment_response'] as Map,
                ),
            },
          );
          if (!mounted) return;
          setState(() => _saving = false);
          verify.fold((f) => context.showSnack(f.message, isError: true), (_) {
            _onSubscriptionSuccess(
              message: 'Payment verified successfully',
              planId: _selected,
            );
          });
        },
      );
      return;
    }

    final res = await repo.subscribe(_selected, yearly: _yearly);
    if (!mounted) return;
    setState(() => _saving = false);
    res.fold(
      (f) {
        // Free plan: if API fails, still unlock onboarding and show the error.
        context.showSnack(f.message, isError: true);
        _onSubscriptionSuccess(
          message: 'Continuing with Starter plan',
          planId: _selected,
        );
      },
      (message) => _onSubscriptionSuccess(message: message, planId: _selected),
    );
  }

  void _onSubscriptionSuccess({
    String message = 'Subscription activated successfully',
    String? planId,
  }) {
    context.showSnack(message);
    if (widget.isOnboarding) {
      final bloc = context.read<AuthBloc>();
      if (planId != null && planId.isNotEmpty) {
        final user = bloc.state.user;
        final planName = _plans
            .cast<SubscriptionPlan?>()
            .firstWhere((p) => p?.id == planId, orElse: () => null)
            ?.name;
        if (user != null) {
          bloc.add(
            AuthUserUpdated(
              user.copyWith(
                subscriptionStatus: 'active',
                subscriptionPlan: planName ?? planId,
              ),
            ),
          );
        }
      }
      // Mark active and keep it — do not bounce back to this screen.
      bloc.add(const AuthSubscriptionActivated());
    } else {
      Navigator.of(context).maybePop();
    }
  }
}

class _BillingToggle extends StatelessWidget {
  const _BillingToggle({
    required this.yearly,
    required this.onMonthly,
    required this.onYearly,
  });

  final bool yearly;
  final VoidCallback onMonthly;
  final VoidCallback onYearly;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        border: Border.all(color: context.theme.dividerColor),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleOption(label: 'Monthly', active: !yearly, onTap: onMonthly),
          _ToggleOption(label: 'Yearly', active: yearly, onTap: onYearly),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.xl,
          vertical: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        ),
        child: Text(
          label,
          style: context.text.labelMedium?.copyWith(
            color: active ? Colors.white : AppColors.mutedText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ExpandablePlanCard extends StatelessWidget {
  const _ExpandablePlanCard({
    required this.plan,
    required this.yearly,
    required this.selected,
    required this.onTap,
  });

  final SubscriptionPlan plan;
  final bool yearly;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final price = yearly ? plan.priceYearly : plan.priceMonthly;
    final billingLabel = yearly ? 'Yearly' : 'Monthly';
    final detailRows = _detailRows();

    return AppCard(
      padding: EdgeInsets.zero,
      border: false,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            decoration: BoxDecoration(
              color: context.theme.cardColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(
                color: selected
                    ? AppColors.primary
                    : context.theme.dividerColor,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : AppColors.border.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMd,
                              ),
                            ),
                            child: Icon(
                              selected
                                  ? Icons.check_circle_rounded
                                  : Icons.workspace_premium_outlined,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.mutedText,
                            ),
                          ),
                          AppSizes.hGapMd,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        plan.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.text.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w900,
                                            ),
                                      ),
                                    ),
                                    if (plan.isPopular) const _PopularPill(),
                                  ],
                                ),
                                if (plan.tagline.trim().isNotEmpty) ...[
                                  AppSizes.vGapXs,
                                  Text(
                                    plan.tagline,
                                    style: context.text.bodySmall?.copyWith(
                                      color: AppColors.mutedText,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      AppSizes.vGapLg,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              price <= 0 ? 'Free' : Formatters.currency(price),
                              style: context.text.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          _BillingPill(label: billingLabel),
                        ],
                      ),
                    ],
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: _PlanDetails(plan: plan, rows: detailRows),
                  crossFadeState: selected
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 220),
                  sizeCurve: Curves.easeOut,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_DetailRowData> _detailRows() {
    return [
      // _DetailRowData(
      //   icon: Icons.schedule_rounded,
      //   label: 'Billing Duration',
      //   value: plan.duration.trim().isEmpty
      //       ? (yearly ? 'Yearly' : 'Monthly')
      //       : _title(plan.duration),
      // ),
      // _DetailRowData(
      //   icon: Icons.payments_outlined,
      //   label: 'Monthly Price',
      //   value: plan.priceMonthly <= 0
      //       ? 'Free'
      //       : Formatters.currency(plan.priceMonthly),
      // ),
      // _DetailRowData(
      //   icon: Icons.event_available_outlined,
      //   label: 'Yearly Price',
      //   value: plan.priceYearly <= 0
      //       ? 'Free'
      //       : Formatters.currency(plan.priceYearly),
      // ),
      for (final entry in plan.limits.entries)
        _DetailRowData(
          icon: Icons.tune_rounded,
          label: _title(entry.key),
          value: entry.value?.toString() == '-1'
              ? 'Unlimited'
              : entry.value?.toString() ?? '',
        ),
    ];
  }

  static String _title(String value) {
    final words = value
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.trim().isNotEmpty);
    return words
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

class _PlanDetails extends StatelessWidget {
  const _PlanDetails({required this.plan, required this.rows});

  final SubscriptionPlan plan;
  final List<_DetailRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.7),
        border: Border(top: BorderSide(color: context.theme.dividerColor)),
      ),
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: [
              for (final row in rows)
                _DetailChip(icon: row.icon, label: row.label, value: row.value),
            ],
          ),
          if (plan.features.isNotEmpty) ...[
            AppSizes.vGapLg,
            Text(
              'Features',
              style: context.text.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            AppSizes.vGapMd,
            for (final feature in plan.features)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 18,
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
              ),
          ],
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({
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
      constraints: const BoxConstraints(minWidth: 128),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: context.theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          AppSizes.hGapSm,
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelSmall?.copyWith(
                    color: AppColors.mutedText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSizes.vGapXs,
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BillingPill extends StatelessWidget {
  const _BillingPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Text(
        label,
        style: context.text.labelSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PopularPill extends StatelessWidget {
  const _PopularPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: const Text(
        'POPULAR',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _DetailRowData {
  const _DetailRowData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}
