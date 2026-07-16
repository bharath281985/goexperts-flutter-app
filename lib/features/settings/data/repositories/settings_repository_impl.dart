import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._api);

  final ApiClientHelper _api;

  @override
  Future<Result<AppSettings>> getSettings() async {
    final res = await _api.get<AppSettings>(
      ApiEndpoints.freelancerSettings,
      parser: (data) {
        final json = Map<String, dynamic>.from(data as Map);
        return AppSettings(
          pushNotifications: json['pushNotifications'] as bool? ?? true,
          emailNotifications: json['emailNotifications'] as bool? ?? true,
          marketingNotifications: json['marketing'] as bool? ?? false,
          publicProfile:
              (json['privacy'] as Map?)?['profileVisible'] as bool? ?? true,
          language: json['language'] as String? ?? 'en',
        );
      },
    );
    return res;
  }

  @override
  Future<Result<bool>> updateSettings(Map<String, dynamic> data) {
    return _api.put<bool>(
      ApiEndpoints.freelancerSettings,
      body: data,
      parser: (_) => true,
    );
  }
}
