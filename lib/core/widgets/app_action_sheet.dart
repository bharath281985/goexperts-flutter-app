import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_sizes.dart';
import '../extensions/context_extensions.dart';

/// An action in a bottom action sheet.
class AppAction {
  const AppAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;
}

/// Reusable bottom action sheet (used by "more" / overflow menus everywhere).
class AppActionSheet {
  static Future<void> show(
    BuildContext context, {
    String? title,
    required List<AppAction> actions,
  }) {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSizes.lg, 0, AppSizes.lg, AppSizes.sm),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(title, style: ctx.text.titleMedium),
                  ),
                ),
              ...actions.map(
                (a) => ListTile(
                  leading: Icon(
                    a.icon,
                    color: a.isDestructive ? AppColors.danger : null,
                  ),
                  title: Text(
                    a.label,
                    style: ctx.text.bodyLarge?.copyWith(
                      color: a.isDestructive ? AppColors.danger : null,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    a.onTap();
                  },
                ),
              ),
              AppSizes.vGapSm,
            ],
          ),
        );
      },
    );
  }
}
