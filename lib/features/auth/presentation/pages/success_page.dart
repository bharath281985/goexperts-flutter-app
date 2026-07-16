import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/responsive_wrapper.dart';

/// Reusable success screen shown after a completed action.
class SuccessArgs {
  const SuccessArgs({
    this.title = 'All set!',
    this.message = 'Your action was completed successfully.',
    this.buttonLabel = 'Continue',
    this.onContinue,
  });

  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback? onContinue;
}

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key, this.args = const SuccessArgs()});
  final SuccessArgs args;

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.args;
    return Scaffold(
      body: SafeArea(
        child: ResponsiveWrapper(
          maxWidth: 480,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 68),
                  ),
                ),
                AppSizes.vGapXl,
                Text(a.title, style: context.text.headlineSmall, textAlign: TextAlign.center),
                AppSizes.vGapSm,
                Text(a.message, style: context.text.bodyMedium, textAlign: TextAlign.center),
                AppSizes.vGapXxl,
                SizedBox(
                  width: double.infinity,
                  child: AppPrimaryButton(
                    label: a.buttonLabel,
                    onPressed: a.onContinue ?? () => Navigator.of(context).maybePop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
