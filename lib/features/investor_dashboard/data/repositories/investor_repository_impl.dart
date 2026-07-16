import '../../../../app/config/app_config.dart';
import '../../../../core/auth/token_role_helper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/enums.dart';
import '../../domain/entities/investor.dart';
import '../../domain/repositories/investor_repository.dart';

class InvestorRepositoryImpl implements InvestorRepository {
  InvestorRepositoryImpl([this._api, this._tokenRoleHelper]);
  final ApiClientHelper? _api;
  final TokenRoleHelper? _tokenRoleHelper;

  Future<UserRole?> _role() async => await _tokenRoleHelper?.resolve();

  @override
  Future<Result<Paginated<Investor>>> getInvestors(QueryParams params) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final role = await _role();
    final path = role == UserRole.founder
        ? ApiEndpoints.founderInvestors
        : '/investors';
    return _api.getEnvelope<Paginated<Investor>>(
      path,
      query: params.toApiQuery(),
      parser: (env) => ApiResponse.parsePaginated(
        env.data,
        env.meta,
        _investorFromJson,
        fallbackPage: params.page,
      ),
    );
  }

  @override
  Future<Result<Investor>> getInvestor(String id) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final role = await _role();
    final path = role == UserRole.founder
        ? ApiEndpoints.founderInvestor(id)
        : '/investors/$id';
    return _api.get<Investor>(
      path,
      parser: (raw) => _investorFromJson(Map<String, dynamic>.from(raw as Map)),
    );
  }

  @override
  Future<Result<Paginated<Deal>>> getDeals(QueryParams params) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    return _api.getEnvelope<Paginated<Deal>>(
      ApiEndpoints.investorInvestments,
      query: params.toApiQuery(),
      parser: (env) {
        final rawData = env.data;
        dynamic listRaw = rawData;
        if (rawData is Map) {
          listRaw =
              rawData['deals'] ??
              rawData['investments'] ??
              rawData['items'] ??
              rawData['data'] ??
              rawData;
        }
        return ApiResponse.parsePaginated(
          listRaw,
          env.meta,
          _dealFromJson,
          fallbackPage: params.page,
        );
      },
    );
  }

  @override
  Future<Result<Paginated<PortfolioItem>>> getPortfolio(
    QueryParams params,
  ) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    return _api.getEnvelope<Paginated<PortfolioItem>>(
      ApiEndpoints.investorPortfolio,
      query: params.toApiQuery(),
      parser: (env) {
        final rawData = env.data;
        dynamic listRaw = rawData;
        if (rawData is Map) {
          listRaw =
              rawData['investments'] ??
              rawData['items'] ??
              rawData['data'] ??
              rawData;
        }
        return ApiResponse.parsePaginated(
          listRaw,
          env.meta,
          _portfolioFromJson,
          fallbackPage: params.page,
        );
      },
    );
  }

  @override
  Future<Result<bool>> toggleFollow(String id) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    return _api.postAction(
      '${ApiEndpoints.favorites}/toggle',
      body: {'entityType': 'investor', 'entityId': id},
    );
  }

  @override
  Future<Result<bool>> toggleSave(String id) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final post = await _api.postAction(
      ApiEndpoints.investorWatchlist,
      body: {'startupId': id},
    );
    if (post.isSuccess) return post;
    return _api.deleteAction(ApiEndpoints.investorWatchlistItem(id));
  }

  Investor _investorFromJson(Map<String, dynamic> json) => Investor(
    id: json['id']?.toString() ?? '',
    name: json['name'] as String? ?? 'Investor',
    investorType: json['investorType'] as String? ?? 'Angel',
    company: json['company'] as String? ?? '',
    location: json['location'] as String? ?? 'N/A',
    minInvestment: (json['minInvestment'] as num?)?.toDouble() ?? 0,
    maxInvestment: (json['maxInvestment'] as num?)?.toDouble() ?? 0,
    interestedIndustries:
        (json['interestedIndustries'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        const [],
    avatarUrl: json['avatarUrl'] as String?,
    coverUrl: json['coverUrl'] as String?,
    bio: json['bio'] as String? ?? '',
    partnerRole: json['partnerRole'] as String? ?? 'Strategic Partner',
    stagePreferences:
        (json['stagePreferences'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        const [],
    dealsCount: (json['dealsCount'] as num?)?.toInt() ?? 0,
    portfolioCount: (json['portfolioCount'] as num?)?.toInt() ?? 0,
    isVerified: json['isVerified'] as bool? ?? false,
    isFollowing: json['isFollowing'] as bool? ?? false,
    isSaved: json['isSaved'] as bool? ?? false,
  );

  Deal _dealFromJson(Map<String, dynamic> json) => Deal(
    id: json['id']?.toString() ?? '',
    startupName: json['startupName'] as String? ?? 'Startup',
    founderName: json['founderName'] as String? ?? 'Founder',
    stage: json['stage'] as String? ?? 'MVP',
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    equity: (json['equity'] as num?)?.toDouble() ?? 0,
    status: EntityStatus.fromString(json['status']?.toString() ?? 'pending'),
    updatedAt:
        DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
        DateTime.now(),
    startupLogo: json['startupLogo'] as String?,
    hasNda: json['hasNda'] as bool? ?? false,
    documentsCount: (json['documentsCount'] as num?)?.toInt() ?? 0,
  );

  PortfolioItem _portfolioFromJson(Map<String, dynamic> json) {
    final startup = json['startup'] as Map?;
    final startupProfile = json['startupProfile'] as Map?;
    final startupName =
        json['startupName'] as String? ??
        startup?['name'] as String? ??
        startupProfile?['startupName'] as String? ??
        json['name'] as String? ??
        'Startup';

    final investedAmount =
        (json['investedAmount'] as num?)?.toDouble() ??
        (json['amount'] as num?)?.toDouble() ??
        0.0;

    final currentValue =
        (json['currentValue'] as num?)?.toDouble() ??
        (json['value'] as num?)?.toDouble() ??
        (json['currentAmount'] as num?)?.toDouble() ??
        investedAmount;

    return PortfolioItem(
      id: json['id']?.toString() ?? '',
      startupName: startupName,
      investedAmount: investedAmount,
      currentValue: currentValue,
      equity: (json['equity'] as num?)?.toDouble() ?? 0,
      investedAt:
          DateTime.tryParse(
            json['investedAt']?.toString() ??
                json['createdAt']?.toString() ??
                '',
          ) ??
          DateTime.now(),
      logoUrl:
          json['logoUrl'] as String? ??
          json['logo'] as String? ??
          startup?['logoUrl'] as String?,
    );
  }

  Future<Result<T>> _apiNotConfigured<T>() async =>
      const Err(ServerFailure('Live API client is not configured.'));
}
