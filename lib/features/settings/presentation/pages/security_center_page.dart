import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_list_tile.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_section_header.dart';

class SecurityCenterPage extends StatefulWidget {
  const SecurityCenterPage({super.key});

  @override
  State<SecurityCenterPage> createState() => _SecurityCenterPageState();
}

class _SecurityCenterPageState extends State<SecurityCenterPage> {
  bool _biometric = false;
  bool _twoFa = true;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Security Center')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          AppCard(
            color: AppColors.success.withValues(alpha: 0.08),
            child: Row(
              children: [
                const Icon(Icons.shield_rounded, color: AppColors.success, size: 30),
                AppSizes.hGapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your account is secure', style: context.text.titleSmall),
                      Text('Security score: 85/100', style: context.text.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSizes.vGapLg,
          const AppSectionHeader(title: 'Authentication'),
          AppSizes.vGapSm,
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint_rounded),
                  title: const Text('Biometric Login'),
                  subtitle: const Text('Fingerprint / Face ID'),
                  value: _biometric,
                  onChanged: (v) => setState(() => _biometric = v),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.pin_outlined),
                  title: const Text('Two-Factor Authentication'),
                  value: _twoFa,
                  onChanged: (v) => setState(() => _twoFa = v),
                ),
                AppListTile(
                  title: 'Change Password',
                  leadingIcon: Icons.lock_outline_rounded,
                  onTap: () => context.push(Routes.changePassword),
                ),
                AppListTile(title: 'Recovery Codes', leadingIcon: Icons.key_outlined, onTap: () {}),
              ],
            ),
          ),
          AppSizes.vGapLg,
          const AppSectionHeader(title: 'Active Sessions'),
          AppSizes.vGapSm,
          _session(context, 'iPhone 15 Pro', 'Bengaluru · This device', true),
          _session(context, 'Chrome · macOS', 'Bengaluru · 2 hours ago', false),
          _session(context, 'Android · Pixel 8', 'Mumbai · 3 days ago', false),
        ],
      ),
    );
  }

  Widget _session(BuildContext context, String device, String meta, bool current) => AppCard(
        margin: const EdgeInsets.only(bottom: AppSizes.md),
        child: Row(
          children: [
            Icon(device.contains('iPhone') || device.contains('Android') || device.contains('Pixel')
                ? Icons.smartphone_rounded
                : Icons.laptop_mac_rounded),
            AppSizes.hGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(device, style: context.text.titleSmall),
                      if (current) ...[
                        AppSizes.hGapSm,
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(999)),
                          child: const Text('Current', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),
                  Text(meta, style: context.text.labelSmall),
                ],
              ),
            ),
            if (!current)
              TextButton(onPressed: () => context.showSnack('Session revoked'), child: const Text('Revoke', style: TextStyle(color: AppColors.danger))),
          ],
        ),
      );
}
