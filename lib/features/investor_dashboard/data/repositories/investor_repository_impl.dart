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
    final res = await _api.getEnvelope<List<Map<String, dynamic>>>(
      ApiEndpoints.investorInvestments,
      query: params.toApiQuery(),
      parser: (env) {
        final list = env.data as List?;
        if (list == null) return const [];
        return list
            .whereType<Map>()
            .map((x) => Map<String, dynamic>.from(x))
            .toList();
      },
    );

    if (res.isFailure) return Err(res.failureOrNull!);

    final rawDeals = res.valueOrNull ?? const [];
    final deals = <Deal>[];
    final startupDetailsCache = <String, Map<String, String>>{};

    for (final raw in rawDeals) {
      final startupId = raw['startup']?.toString() ?? '';
      if (startupId.isNotEmpty && !startupDetailsCache.containsKey(startupId)) {
        // Fetch startup details
        final path = '/investor/startups/$startupId';
        final startupRes = await _api.get<Map<String, dynamic>>(
          path,
          parser: (rawObj) => Map<String, dynamic>.from(rawObj as Map),
        );
        startupRes.fold((_) {}, (su) {
          final Map<String, dynamic>? profile =
              (su['founderProfile'] ?? su['founder_profile']) != null
              ? Map<String, dynamic>.from(
                  (su['founderProfile'] ?? su['founder_profile']) as Map,
                )
              : null;
          final name =
              profile?['startupName']?.toString() ??
              su['startup']?.toString() ??
              su['name']?.toString() ??
              su['fullName']?.toString() ??
              'Startup';
          final avatar =
              su['avatarUrl'] as String? ??
              su['logoUrl'] as String? ??
              su['logo'] as String? ??
              profile?['logoUrl'] as String?;
          final founder =
              su['fullName']?.toString() ??
              su['founderName']?.toString() ??
              'Founder';
          final stage =
              profile?['stage']?.toString() ?? su['stage']?.toString() ?? 'MVP';

          startupDetailsCache[startupId] = {
            'name': name,
            'logo': avatar ?? '',
            'founder': founder,
            'stage': stage,
          };
        });
      }

      final cached =
          startupDetailsCache[startupId] ??
          const {
            'name': 'Startup',
            'logo': '',
            'founder': 'Founder',
            'stage': 'MVP',
          };

      deals.add(
        Deal(
          id: startupId.isNotEmpty ? startupId : (raw['id']?.toString() ?? ''),
          startupName: cached['name'] ?? 'Startup',
          founderName: cached['founder'] ?? 'Founder',
          stage: cached['stage'] ?? 'MVP',
          amount:
              (raw['offer'] as num?)?.toDouble() ??
              (raw['amount'] as num?)?.toDouble() ??
              0.0,
          equity: (raw['equity'] as num?)?.toDouble() ?? 0.0,
          status: EntityStatus.fromString(
            raw['status']?.toString() ?? 'pending',
          ),
          updatedAt:
              DateTime.tryParse(raw['updatedAt']?.toString() ?? '') ??
              DateTime.now(),
          startupLogo: cached['logo']?.isNotEmpty == true
              ? cached['logo']
              : null,
          hasNda: raw['hasNda'] as bool? ?? false,
          documentsCount: (raw['documentsCount'] as num?)?.toInt() ?? 0,
        ),
      );
    }

    return Success(
      Paginated(
        items: deals,
        page: params.page,
        totalPages: 1,
        totalItems: deals.length,
      ),
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

  Investor _investorFromJson(Map<String, dynamic> json) =>
      Investor.fromApiJson(json);

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
