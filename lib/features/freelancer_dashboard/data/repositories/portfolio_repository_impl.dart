import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/portfolio_item.dart';
import '../../domain/repositories/portfolio_repository.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  PortfolioRepositoryImpl(this._api);

  final ApiClientHelper _api;

  @override
  Future<Result<Paginated<PortfolioItem>>> getPortfolio(
    QueryParams params,
  ) async {
    return _api.getEnvelope<Paginated<PortfolioItem>>(
      ApiEndpoints.freelancerPortfolio,
      query: params.toApiQuery(),
      parser: (envelope) => _pageFromEnvelope(envelope, params),
    );
  }

  @override
  Future<Result<PortfolioItem>> getPortfolioItem(String id) {
    return _api.getEnvelope<PortfolioItem>(
      ApiEndpoints.freelancerPortfolioItem(id),
      parser: (envelope) => PortfolioItem.fromApiJson(
        Map<String, dynamic>.from(envelope.data as Map),
      ),
    );
  }

  @override
  Future<Result<PortfolioItem>> addPortfolio(Map<String, dynamic> data) async {
    return _api.postEnvelope<PortfolioItem>(
      ApiEndpoints.freelancerPortfolio,
      body: data,
      parser: (envelope) => _itemFromEnvelope(envelope, fallback: data),
    );
  }

  @override
  Future<Result<PortfolioItem>> updatePortfolio(
    String id,
    Map<String, dynamic> data,
  ) {
    return _api.putEnvelope<PortfolioItem>(
      ApiEndpoints.freelancerPortfolioItem(id),
      body: data,
      parser: (envelope) =>
          _itemFromEnvelope(envelope, fallback: {'id': id, ...data}),
    );
  }

  @override
  Future<Result<bool>> deletePortfolio(String id) {
    return _api.deleteAction(ApiEndpoints.freelancerPortfolioItem(id));
  }

  Paginated<PortfolioItem> _pageFromEnvelope(
    ApiResponse<dynamic> envelope,
    QueryParams params,
  ) {
    final raw = envelope.data;
    final rawMap = raw is Map ? Map<String, dynamic>.from(raw) : null;
    final list = raw is List
        ? raw
        : rawMap?['items'] ??
              rawMap?['rows'] ??
              rawMap?['data'] ??
              rawMap?['portfolio'] ??
              const [];
    final meta = envelope.meta ?? rawMap?['meta'] as Map<String, dynamic>?;

    return ApiResponse.parsePaginated(
      list,
      meta,
      PortfolioItem.fromApiJson,
      fallbackPage: params.page,
    );
  }

  PortfolioItem _itemFromEnvelope(
    ApiResponse<dynamic> envelope, {
    required Map<String, dynamic> fallback,
  }) {
    final raw = envelope.data;
    final rawMap = raw is Map ? Map<String, dynamic>.from(raw) : null;
    final nested = rawMap?['portfolio'] is Map
        ? rawMap!['portfolio'] as Map
        : rawMap?['item'] is Map
        ? rawMap!['item'] as Map
        : rawMap?['data'] is Map
        ? rawMap!['data'] as Map
        : rawMap;
    final json = {
      ...fallback,
      if (nested != null) ...Map<String, dynamic>.from(nested),
    };
    final message =
        envelope.message ??
        (rawMap?['message'] is String ? rawMap!['message'] as String : null);

    return PortfolioItem.fromApiJson(json, responseMessage: message);
  }
}
