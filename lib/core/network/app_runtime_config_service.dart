import '../utils/result.dart';
import 'api_client_helper.dart';
import 'api_endpoints.dart';

class AppRuntimeConfigService {
  AppRuntimeConfigService(this._api);

  final ApiClientHelper _api;

  Map<String, dynamic> latest = const {};

  Future<Result<Map<String, dynamic>>> load() async {
    final config = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.appConfig,
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    final version = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.appVersion,
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    final maintenance = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.appMaintenance,
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    final flags = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.appFeatureFlags,
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );

    final out = <String, dynamic>{
      'config': config.valueOrNull ?? const {},
      'version': version.valueOrNull ?? const {},
      'maintenance': maintenance.valueOrNull ?? const {},
      'featureFlags': flags.valueOrNull ?? const {},
    };
    latest = out;
    return Success(out);
  }
}
