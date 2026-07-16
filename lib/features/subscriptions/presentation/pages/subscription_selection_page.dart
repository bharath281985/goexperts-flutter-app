import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../core/payments/payment_checkout_service.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/subscription_status.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/responsive_wrapper.dart';
import '../../../../core/widgets/safe_bottom.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../widgets/plan_card.dart';

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
      appBar: AppBar(
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
                child: Padding(
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
        Center(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: context.theme.cardColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              border: Border.all(color: context.theme.dividerColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _toggle(
                  'Monthly',
                  !_yearly,
                  () => setState(() => _yearly = false),
                ),
                _toggle(
                  'Yearly · Save 20%',
                  _yearly,
                  () => setState(() => _yearly = true),
                ),
              ],
            ),
          ),
        ),
        AppSizes.vGapLg,
        for (final plan in _plans)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.md),
            child: PlanCard(
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

  Widget _toggle(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : context.text.bodyMedium?.color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
