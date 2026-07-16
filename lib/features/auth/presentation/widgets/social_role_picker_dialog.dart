import 'package:flutter/material.dart';

import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/widgets/app_primary_button.dart';

/// Lightweight role picker shown before social login when role is not known.
Future<UserRole?> showSocialRolePicker(BuildContext context) {
  return showModalBottomSheet<UserRole>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
    ),
    builder: (ctx) {
      UserRole? selected;
      return StatefulBuilder(
        builder: (context, setState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.xl, AppSizes.lg, AppSizes.xl, AppSizes.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Choose your role', style: context.text.titleLarge),
                  AppSizes.vGapSm,
                  Text(
                    'Select how you want to use Go Experts before continuing.',
                    style: context.text.bodyMedium,
                  ),
                  AppSizes.vGapLg,
                  for (final role in UserRole.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.sm),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          side: BorderSide(
                            color: selected == role ? AppColors.primary : context.theme.dividerColor,
                          ),
                        ),
                        leading: Icon(role.icon, color: AppColors.primary),
                        title: Text(role.label),
                        subtitle: Text(role.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: selected == role
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                            : null,
                        onTap: () => setState(() => selected = role),
                      ),
                    ),
                  AppSizes.vGapMd,
                  AppPrimaryButton(
                    label: 'Continue',
                    onPressed: selected == null ? null : () => Navigator.of(ctx).pop(selected),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
