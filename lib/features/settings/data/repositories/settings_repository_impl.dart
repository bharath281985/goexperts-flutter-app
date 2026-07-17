import '../../../../core/auth/token_role_helper.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._api, this._tokenRoleHelper);

  final ApiClientHelper _api;
  final TokenRoleHelper _tokenRoleHelper;

  @override
  Future<Result<AppSettings>> getSettings() async {
    final role = await _tokenRoleHelper.resolve();
    final isFounderOrInvestor =
        (role == UserRole.founder || role == UserRole.investor);
    if (isFounderOrInvestor) {
      final res = await _api.get<AppSettings>(
        ApiEndpoints.notificationsPreferences,
        parser: (data) {
          final json = Map<String, dynamic>.from(data as Map);
          return AppSettings(
            pushNotifications: json['push'] as bool? ?? true,
            emailNotifications: json['email'] as bool? ?? true,
            marketingNotifications: json['sms'] as bool? ?? false,
            publicProfile: true,
            language: 'en',
          );
        },
      );
      return res;
    }

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
  Future<Result<bool>> updateSettings(Map<String, dynamic> data) async {
    final role = await _tokenRoleHelper.resolve();
    final isFounderOrInvestor =
        (role == UserRole.founder || role == UserRole.investor);
    if (isFounderOrInvestor) {
      final res = await _api.put<dynamic>(
        ApiEndpoints.notificationsPreferences,
        body: {
          'email': data['emailNotifications'] ?? true,
          'push': data['pushNotifications'] ?? true,
          'sms': data['marketing'] ?? data['marketingNotifications'] ?? false,
        },
        parser: (_) => true,
      );
      return res.fold((f) => Err(f), (_) => const Success(true));
    }

    return _api.put<bool>(
      ApiEndpoints.freelancerSettings,
      body: data,
      parser: (_) => true,
    );
  }
}
