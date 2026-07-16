import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../network/api_client_helper.dart';
import '../network/api_endpoints.dart';

enum AppUpdateAction { none, softUpdate, forceUpdate, maintenance }

class AppUpdateCheck {
  const AppUpdateCheck({
    required this.action,
    this.title,
    this.message,
    this.storeUrl,
  });

  final AppUpdateAction action;
  final String? title;
  final String? message;
  final String? storeUrl;
}

/// Checks /app/version and /app/maintenance for update and maintenance gates.
class AppUpdateService {
  AppUpdateService(this._api);

  final ApiClientHelper _api;

  Future<AppUpdateCheck> check() async {
    final maintenance = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.appMaintenance,
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    final maintenanceData = maintenance.valueOrNull ?? const {};
    if (maintenanceData['enabled'] == true || maintenanceData['isActive'] == true) {
      return AppUpdateCheck(
        action: AppUpdateAction.maintenance,
        title: maintenanceData['title']?.toString() ?? 'Under Maintenance',
        message: maintenanceData['message']?.toString() ??
            'We are performing scheduled maintenance. Please try again later.',
      );
    }

    final versionRes = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.appVersion,
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    final versionData = versionRes.valueOrNull;
    if (versionData == null) return const AppUpdateCheck(action: AppUpdateAction.none);

    final packageInfo = await PackageInfo.fromPlatform();
    final current = packageInfo.version;
    final minRequired = versionData['minVersion']?.toString() ??
        versionData['minimumVersion']?.toString();
    final latest = versionData['latestVersion']?.toString() ??
        versionData['version']?.toString();
    final storeUrl = versionData['storeUrl']?.toString() ??
        versionData['androidUrl']?.toString() ??
        versionData['iosUrl']?.toString();

    if (minRequired != null && _isLower(current, minRequired)) {
      return AppUpdateCheck(
        action: AppUpdateAction.forceUpdate,
        title: 'Update Required',
        message: versionData['forceMessage']?.toString() ??
            'A new version ($minRequired) is required to continue.',
        storeUrl: storeUrl,
      );
    }

    if (latest != null && _isLower(current, latest)) {
      return AppUpdateCheck(
        action: AppUpdateAction.softUpdate,
        title: 'Update Available',
        message: versionData['softMessage']?.toString() ??
            'Version $latest is available. Update for the best experience.',
        storeUrl: storeUrl,
      );
    }

    return const AppUpdateCheck(action: AppUpdateAction.none);
  }

  bool _isLower(String current, String target) {
    final c = _parts(current);
    final t = _parts(target);
    for (var i = 0; i < 3; i++) {
      final cv = i < c.length ? c[i] : 0;
      final tv = i < t.length ? t[i] : 0;
      if (cv < tv) return true;
      if (cv > tv) return false;
    }
    return false;
  }

  List<int> _parts(String v) =>
      v.split('.').map((e) => int.tryParse(e) ?? 0).toList();

  static Future<void> showUpdateDialog(
    BuildContext context,
    AppUpdateCheck check, {
    required bool force,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: !force,
      builder: (ctx) => PopScope(
        canPop: !force,
        child: AlertDialog(
          title: Text(check.title ?? 'Update'),
          content: Text(check.message ?? 'Please update the app.'),
          actions: [
            if (!force)
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Later'),
              ),
            TextButton(
              onPressed: () async {
                final url = check.storeUrl;
                if (url != null && url.isNotEmpty) {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
                if (!force && ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> showMaintenanceDialog(
    BuildContext context,
    AppUpdateCheck check,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(check.title ?? 'Maintenance'),
        content: Text(check.message ?? 'App is under maintenance.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
