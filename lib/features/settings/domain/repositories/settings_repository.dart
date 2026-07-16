import '../../../../core/utils/result.dart';

class AppSettings {
  const AppSettings({
    required this.pushNotifications,
    required this.emailNotifications,
    required this.marketingNotifications,
    required this.publicProfile,
    required this.language,
  });

  final bool pushNotifications;
  final bool emailNotifications;
  final bool marketingNotifications;
  final bool publicProfile;
  final String language;
}

abstract class SettingsRepository {
  Future<Result<AppSettings>> getSettings();
  Future<Result<bool>> updateSettings(Map<String, dynamic> data);
}
