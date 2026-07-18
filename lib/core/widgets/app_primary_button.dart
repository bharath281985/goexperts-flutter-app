import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_sizes.dart';
import '../extensions/context_extensions.dart';

/// Primary CTA button with loading + icon support.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.expanded = true,
    this.gradient = true,
    this.textColor = AppColors.white,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.height = AppSizes.buttonHeight,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool expanded;
  final bool gradient;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? disabledBackgroundColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation(AppColors.white),
            ),
          )
        : Row(
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSizes.iconSm, color: textColor),
                AppSizes.hGapSm,
              ],
              Flexible(
                child: Text(
                  context.tr(label),
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          );

    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        onTap: (isLoading || onPressed == null) ? null : onPressed,
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            gradient: gradient && backgroundColor == null && onPressed != null
                ? AppColors.primaryGradient
                : null,
            color: onPressed == null
                ? disabledBackgroundColor ??
                      (backgroundColor ?? AppColors.primary).withValues(
                        alpha: 0.5,
                      )
                : (gradient && backgroundColor == null
                      ? null
                      : backgroundColor ?? AppColors.primary),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Center(child: child),
        ),
      ),
    );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
