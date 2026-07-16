import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/subscription_plan.dart';

class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.plan,
    required this.yearly,
    this.selected = false,
    this.onTap,
  });

  final SubscriptionPlan plan;
  final bool yearly;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final price = yearly ? plan.priceYearly : plan.priceMonthly;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSizes.lg),
          decoration: BoxDecoration(
            color: context.theme.cardColor,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: selected ? AppColors.primary : context.theme.dividerColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(plan.name, style: context.text.titleMedium),
                  AppSizes.hGapSm,
                  if (plan.isPopular)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                      ),
                      child: const Text('POPULAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                  const Spacer(),
                  if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 2),
              Text(plan.tagline, style: context.text.bodySmall),
              AppSizes.vGapMd,
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(price == 0 ? 'Free' : Formatters.currency(price), style: context.text.displaySmall),
                  if (price != 0) Text(yearly ? '/yr' : '/mo', style: context.text.bodySmall),
                ],
              ),
              AppSizes.vGapMd,
              for (final f in plan.features)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.sm),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.success),
                      AppSizes.hGapSm,
                      Expanded(child: Text(f, style: context.text.bodySmall)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
