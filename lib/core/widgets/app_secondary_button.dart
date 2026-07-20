import 'package:flutter/material.dart';
import '../../app/constants/app_sizes.dart';
import '../extensions/context_extensions.dart';

/// Outlined secondary button.
class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expanded = true,
    this.color,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final Color? color;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? context.text.titleSmall?.color;
    final child = isLoading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
          )
        : Row(
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSizes.iconSm, color: fg),
                AppSizes.hGapSm,
              ],
              Flexible(
                child: Text(
                  context.tr(label),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          );

    final button = OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color ?? context.theme.dividerColor),
      ),
      child: child,
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
