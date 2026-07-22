import '../../../../app/config/app_config.dart';
import '../../../../core/auth/token_role_helper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/startup.dart';
import '../../domain/repositories/startup_repository.dart';

class StartupRepositoryImpl implements StartupRepository {
  StartupRepositoryImpl([this._api, this._tokenRoleHelper]);

  final ApiClientHelper? _api;
  final TokenRoleHelper? _tokenRoleHelper;

  Future<UserRole?> _role() async => await _tokenRoleHelper?.resolve();

  @override
  Future<Result<Paginated<Startup>>> getStartups(QueryParams params) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final role = await _role();
    final path = role == UserRole.investor
        ? ApiEndpoints.investorStartups
        : role == UserRole.founder
        ? ApiEndpoints.founderIdeas
        : ApiEndpoints.publicStartups;
    return _api.getEnvelope<Paginated<Startup>>(
      path,
      query: params.toApiQuery(),
      parser: (env) => ApiResponse.parsePaginated(
        env.data,
        env.meta,
        Startup.fromApiJson,
        fallbackPage: params.page,
      ),
    );
  }

  @override
  Future<Result<Startup>> getStartup(String id) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final role = await _role();
    final path = role == UserRole.investor
        ? ApiEndpoints.investorStartup(id)
        : role == UserRole.founder
        ? '${ApiEndpoints.founderIdeas}/$id'
        : '${ApiEndpoints.publicStartups}/$id';
    return _api.get<Startup>(
      path,
      parser: (raw) =>
          Startup.fromApiJson(Map<String, dynamic>.from(raw as Map)),
    );
  }

  @override
  Future<Result<bool>> toggleSave(String id) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final role = await _role();
    if (role == UserRole.investor) {
      final post = await _api.postAction(ApiEndpoints.investorStartupSave(id));
      if (post.isSuccess) return post;
      return _api.deleteAction(ApiEndpoints.investorStartupSave(id));
    }
    return _api.postAction('${ApiEndpoints.publicStartups}/$id/save');
  }

  @override
  Future<Result<bool>> toggleFollow(String id) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    return _api.postAction(
      '${ApiEndpoints.favorites}/toggle',
      body: {'entityType': 'startup', 'entityId': id},
    );
  }

  @override
  Future<Result<bool>> expressInterest(String id) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    return _api.postAction(
      ApiEndpoints.investorExpressInterest,
      body: {'startupId': id},
    );
  }

  @override
  Future<Result<bool>> withdrawInterest(String id) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    return _api.postAction(ApiEndpoints.investorCancelInvestment(id));
  }

  @override
  Future<Result<Startup>> createIdea(Map<String, dynamic> data) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    return _api.post<Startup>(
      ApiEndpoints.founderIdeas,
      body: data,
      parser: (raw) =>
          Startup.fromApiJson(Map<String, dynamic>.from(raw as Map)),
    );
  }

  @override
  Future<Result<Startup>> updateIdea(
    String id,
    Map<String, dynamic> data,
  ) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    return _api.put<Startup>(
      '${ApiEndpoints.founderIdeas}/$id',
      body: data,
      parser: (raw) =>
          Startup.fromApiJson(Map<String, dynamic>.from(raw as Map)),
    );
  }

  @override
  Future<Result<bool>> deleteIdea(String id) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    return _api.deleteAction('${ApiEndpoints.founderIdeas}/$id');
  }

  Future<Result<T>> _apiNotConfigured<T>() async =>
      const Err(ServerFailure('Live API client is not configured.'));
}
