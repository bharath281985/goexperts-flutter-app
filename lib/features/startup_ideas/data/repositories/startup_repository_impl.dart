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
        : '/startups';
    return _api.getEnvelope<Paginated<Startup>>(
      path,
      query: params.toApiQuery(),
      parser: (env) => ApiResponse.parsePaginated(
        env.data,
        env.meta,
        _fromJson,
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
        : '/startups/$id';
    return _api.get<Startup>(
      path,
      parser: (raw) => _fromJson(Map<String, dynamic>.from(raw as Map)),
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
    return _api.postAction('/startups/$id/save');
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

  Startup _fromJson(Map<String, dynamic> json) => Startup(
    id: json['id']?.toString() ?? '',
    name: json['name'] as String? ?? 'Startup',
    tagline: json['tagline'] as String? ?? '',
    industry: json['industry'] as String? ?? 'General',
    stage: json['stage'] as String? ?? 'MVP',
    founderName: json['founderName'] as String? ?? 'Founder',
    fundingRequired: (json['fundingRequired'] as num?)?.toDouble() ?? 0,
    equityOffered: (json['equityOffered'] as num?)?.toDouble() ?? 0,
    location: json['location'] as String? ?? 'N/A',
    logoUrl: json['logoUrl'] as String?,
    coverUrl: json['coverUrl'] as String?,
    founderAvatar: json['founderAvatar'] as String?,
    problem: json['problem'] as String? ?? '',
    solution: json['solution'] as String? ?? '',
    businessModel: json['businessModel'] as String? ?? '',
    revenueModel: json['revenueModel'] as String? ?? '',
    marketSize: json['marketSize'] as String? ?? '',
    valuation: (json['valuation'] as num?)?.toDouble() ?? 0,
    fundingRaised: (json['fundingRaised'] as num?)?.toDouble() ?? 0,
    pitchDeckUrl: json['pitchDeckUrl'] as String?,
    views: (json['views'] as num?)?.toInt() ?? 0,
    investorInterests: (json['investorInterests'] as num?)?.toInt() ?? 0,
    isSaved: json['isSaved'] as bool? ?? false,
    isFollowing: json['isFollowing'] as bool? ?? false,
    isVerified: json['isVerified'] as bool? ?? false,
    tags:
        (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
  );

  Future<Result<T>> _apiNotConfigured<T>() async =>
      const Err(ServerFailure('Live API client is not configured.'));
}
