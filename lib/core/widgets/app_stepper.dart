import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_sizes.dart';
import '../extensions/context_extensions.dart';

/// Horizontal progress stepper used by multi-step wizards.
class AppStepper extends StatelessWidget {
  const AppStepper({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  final List<String> steps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              _Dot(index: i, current: currentStep),
              if (i != steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    color: i < currentStep
                        ? AppColors.primary
                        : context.theme.dividerColor,
                  ),
                ),
            ],
          ],
        ),
        AppSizes.vGapSm,
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Step ${currentStep + 1} of ${steps.length} · ${steps[currentStep]}',
            style: context.text.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.index, required this.current});
  final int index;
  final int current;

  @override
  Widget build(BuildContext context) {
    final done = index < current;
    final active = index == current;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: (done || active) ? AppColors.primary : context.theme.cardColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: (done || active) ? AppColors.primary : context.theme.dividerColor,
        ),
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check_rounded, size: 16, color: AppColors.white)
            : Text(
                '${index + 1}',
                style: TextStyle(
                  color: active ? AppColors.white : context.text.bodySmall?.color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
      ),
    );
  }
}
