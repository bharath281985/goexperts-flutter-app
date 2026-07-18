import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_sizes.dart';
import '../extensions/context_extensions.dart';

/// Compact list tile used in drawers, settings and menus.
class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.leading,
    this.trailing,
    this.onTap,
    this.iconColor = AppColors.primary,
    this.showChevron = true,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color iconColor;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: 2,
      ),
      leading:
          leading ??
          (leadingIcon != null
              ? Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Icon(
                    leadingIcon,
                    color: iconColor,
                    size: AppSizes.iconSm,
                  ),
                )
              : null),
      title: Text(context.tr(title), style: context.text.titleSmall),
      subtitle: subtitle != null
          ? Text(context.tr(subtitle!), style: context.text.bodySmall)
          : null,
      trailing:
          trailing ??
          (showChevron && onTap != null
              ? const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.subtleText,
                )
              : null),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
    );
  }
}
