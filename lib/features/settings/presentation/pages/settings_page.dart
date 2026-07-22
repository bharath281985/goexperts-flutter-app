import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/locale/locale_cubit.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/theme_cubit.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_list_tile.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/utils/enums.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/repositories/settings_repository.dart';

const _supportedLanguageCodes = [
  'en',
  'fr',
  'hi',
  'te',
  'ta',
  'kn',
  'ml',
  'mr',
  'gu',
  'bn',
  'ar',
];

const _languageNames = {
  'en': 'English',
  'fr': 'French',
  'hi': 'Hindi',
  'te': 'Telugu',
  'ta': 'Tamil',
  'kn': 'Kannada',
  'ml': 'Malayalam',
  'mr': 'Marathi',
  'gu': 'Gujarati',
  'bn': 'Bengali',
  'ar': 'Arabic',
};

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _loading = true;
  bool _saving = false;
  bool _push = true;
  bool _email = true;
  bool _marketing = false;
  bool _public = true;
  String _language = 'en';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _language = context.read<LocaleCubit>().state.languageCode;
    final res = await sl<SettingsRepository>().getSettings();
    if (!mounted) return;
    res.fold((_) {}, (s) {
      _push = s.pushNotifications;
      _email = s.emailNotifications;
      _marketing = s.marketingNotifications;
      _public = s.publicProfile;
      _language = context.read<LocaleCubit>().state.languageCode;
    });
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final res = await sl<SettingsRepository>().updateSettings({
      'pushNotifications': _push,
      'emailNotifications': _email,
      'marketing': _marketing,
      'privacy': {'profileVisible': _public},
      'language': _language,
    });
    if (!mounted) return;
    setState(() => _saving = false);
    res.fold(
      (f) => context.showSnack(f.message),
      (_) => context.showSnack(context.tr('Settings updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedLanguage = context.watch<LocaleCubit>().state.languageCode;
    final selectedLanguageName =
        _languageNames[selectedLanguage] ?? selectedLanguage;

    return AppScaffold(
      appBar: AppBar(
        title: Text(context.tr('Settings')),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(context.tr('Save')),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        children: [
          if (_loading) const Center(child: CircularProgressIndicator()),
          _group(context, 'Account', [
            AppListTile(
              title: 'Edit Profile',
              leadingIcon: Icons.person_outline_rounded,
              onTap: () {
                final role =
                    context.read<AuthBloc>().state.user?.role ??
                    UserRole.freelancer;
                switch (role) {
                  case UserRole.investor:
                    context.push(Routes.investorProfile);
                    break;
                  case UserRole.founder:
                    context.push(Routes.founderProfile);
                    break;
                  case UserRole.client:
                    context.push(Routes.clientProfile);
                    break;
                  case UserRole.freelancer:
                    context.push(Routes.profileCompletion);
                    break;
                }
              },
            ),
            AppListTile(
              title: 'Security Center',
              leadingIcon: Icons.shield_outlined,
              onTap: () => context.push(Routes.securityCenter),
            ),
            AppListTile(
              title: 'Subscription & Billing',
              leadingIcon: Icons.workspace_premium_outlined,
              onTap: () => context.push(Routes.subscriptionsManage),
            ),
          ]),
          AppSizes.vGapLg,
          _group(context, 'Preferences', [
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, mode) => SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: Text(context.tr('Dark Mode')),
                value: mode == ThemeMode.dark,
                onChanged: (_) => context.read<ThemeCubit>().toggle(),
              ),
            ),
            AppListTile(
              title: 'Language',
              subtitle:
                  '${context.tr(selectedLanguageName)} (${selectedLanguage.toUpperCase()})',
              leadingIcon: Icons.language_rounded,
              onTap: () => _languageSheet(context),
            ),
            AppListTile(
              title: 'Currency',
              subtitle: 'INR (₹)',
              leadingIcon: Icons.currency_rupee_rounded,
              onTap: () {},
            ),
          ]),
          AppSizes.vGapLg,
          _group(context, 'Notifications', [
            SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined),
              title: Text(context.tr('Push Notifications')),
              value: _push,
              onChanged: (v) => setState(() => _push = v),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.email_outlined),
              title: Text(context.tr('Email Updates')),
              value: _email,
              onChanged: (v) => setState(() => _email = v),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.campaign_outlined),
              title: Text(context.tr('Marketing')),
              value: _marketing,
              onChanged: (v) => setState(() => _marketing = v),
            ),
          ]),
          AppSizes.vGapLg,
          _group(context, 'Privacy', [
            SwitchListTile(
              secondary: const Icon(Icons.visibility_outlined),
              title: Text(context.tr('Public Profile')),
              value: _public,
              onChanged: (v) => setState(() => _public = v),
            ),
            AppListTile(
              title: 'Blocked Users',
              leadingIcon: Icons.block_rounded,
              onTap: () {},
            ),
            AppListTile(
              title: 'Privacy Policy',
              leadingIcon: Icons.privacy_tip_outlined,
              onTap: () => context.push(Routes.privacyPolicy),
            ),
            AppListTile(
              title: 'Terms of Service',
              leadingIcon: Icons.gavel_outlined,
              onTap: () => context.push(Routes.termsOfService),
            ),
          ]),
          AppSizes.vGapLg,
          _group(context, 'Support', [
            AppListTile(
              title: 'Help Center',
              leadingIcon: Icons.help_outline_rounded,
              onTap: () => context.push(Routes.support),
            ),
            AppListTile(
              title: 'About Go Experts',
              leadingIcon: Icons.info_outline_rounded,
              onTap: () => context.push(Routes.privacyPolicy),
            ),
            AppListTile(
              title: 'App Version',
              subtitle: '1.0.0',
              leadingIcon: Icons.smartphone_outlined,
              showChevron: false,
            ),
          ]),
        ],
      ),
    );
  }

  void _languageSheet(BuildContext context) {
    final selectedLanguage = context.read<LocaleCubit>().state.languageCode;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final l in _supportedLanguageCodes)
              ListTile(
                title: Text(
                  '${context.tr(_languageNames[l] ?? l)} (${l.toUpperCase()})',
                ),
                trailing: l == selectedLanguage
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () {
                  setState(() => _language = l);
                  context.read<LocaleCubit>().setLanguage(l);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _group(BuildContext context, String title, List<Widget> children) =>
      AppCard(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.sm,
                AppSizes.md,
                AppSizes.xs,
              ),
              child: Text(
                context.tr(title).toUpperCase(),
                style: context.text.labelSmall?.copyWith(letterSpacing: 1),
              ),
            ),
            ...children,
          ],
        ),
      );
}
