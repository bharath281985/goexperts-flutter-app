import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../bloc/auth_bloc.dart';
import 'social_role_picker_dialog.dart';

class SocialLoginRow extends StatelessWidget {
  const SocialLoginRow({super.key});

  Future<void> _startSocial(BuildContext context, String provider) async {
    final role = await showSocialRolePicker(context);
    if (role == null || !context.mounted) return;
    context.read<AuthBloc>().add(
      AuthSocialLoginRequested(provider: provider, role: role),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showApple = Platform.isIOS || Platform.isMacOS;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: context.theme.dividerColor)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Text('or continue with', style: context.text.bodySmall),
            ),
            Expanded(child: Divider(color: context.theme.dividerColor)),
          ],
        ),
        AppSizes.vGapLg,
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                icon: Icons.g_mobiledata_rounded,
                label: 'Google',
                onTap: () => _startSocial(context, 'google'),
              ),
            ),
            if (showApple) ...[
              AppSizes.hGapMd,
              Expanded(
                child: _SocialButton(
                  icon: Icons.apple,
                  label: 'Apple',
                  onTap: () => _startSocial(context, 'apple'),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 22),
      label: Text(label),
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
    );
  }
}
