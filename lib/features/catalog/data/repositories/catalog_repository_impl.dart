import '../../../../app/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/mock_utils.dart';
import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/catalog_entities.dart';
import '../../domain/repositories/catalog_repository.dart';

/// Mock implementation reading from [MockData]. Swap for a Dio datasource later.
class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl([this._api]);

  final ApiClientHelper? _api;

  @override
  Future<Result<Paginated<ServiceItem>>> getServices(QueryParams params) =>
      MockUtils.paginate(
        MockData.services,
        params,
        searchMatcher: (s, q) =>
            s.name.toLowerCase().contains(q) ||
            s.category.toLowerCase().contains(q),
      );

  @override
  Future<Result<ServiceItem>> getService(String id) =>
      _find(MockData.services, (e) => e.id == id);

  @override
  Future<Result<Paginated<Technology>>> getTechnologies(QueryParams params) =>
      MockUtils.paginate(
        MockData.technologies,
        params,
        searchMatcher: (t, q) => t.name.toLowerCase().contains(q),
      );

  @override
  Future<Result<Technology>> getTechnology(String id) =>
      _find(MockData.technologies, (e) => e.id == id);

  @override
  Future<Result<Paginated<CategoryItem>>> getCategories(QueryParams params) =>
      MockUtils.paginate(
        MockData.categories,
        params,
        searchMatcher: (c, q) => c.name.toLowerCase().contains(q),
      );

  @override
  Future<Result<CategoryItem>> getCategory(String id) =>
      _find(MockData.categories, (e) => e.id == id);

  @override
  Future<Result<Paginated<Certificate>>> getCertificates(
    QueryParams params,
  ) async {
    if (AppConfig.useMockData || _api == null) {
      return MockUtils.paginate(
        MockData.certificates,
        params,
        searchMatcher: (c, q) =>
            c.title.toLowerCase().contains(q) ||
            c.issuer.toLowerCase().contains(q),
      );
    }
    return _api.getEnvelope<Paginated<Certificate>>(
      ApiEndpoints.files,
      query: {...params.toApiQuery(), 'category': 'certificate'},
      parser: (envelope) => ApiResponse.parsePaginated(
        envelope.data,
        envelope.meta,
        _certificateFromJson,
        fallbackPage: params.page,
      ),
    );
  }

  @override
  Future<Result<Certificate>> getCertificate(String id) =>
      _find(MockData.certificates, (e) => e.id == id);

  @override
  Future<Result<Paginated<InvestmentOpportunity>>> getOpportunities(
    QueryParams params,
  ) => MockUtils.paginate(
    MockData.opportunities,
    params,
    searchMatcher: (o, q) =>
        o.startupName.toLowerCase().contains(q) ||
        o.industry.toLowerCase().contains(q),
  );

  @override
  Future<Result<InvestmentOpportunity>> getOpportunity(String id) =>
      _find(MockData.opportunities, (e) => e.id == id);

  @override
  Future<Result<BusinessPlan>> getBusinessPlan(String startupId) async {
    final plan =
        MockData.businessPlans[startupId] ??
        MockData.businessPlans.values.first;
    return MockUtils.single(plan);
  }

  @override
  Future<Result<PitchDeck>> getPitchDeck(String startupId) async {
    final deck =
        MockData.pitchDecks[startupId] ?? MockData.pitchDecks.values.first;
    return MockUtils.single(deck);
  }

  Future<Result<T>> _find<T>(List<T> source, bool Function(T) test) async {
    final match = source.where(test);
    if (match.isEmpty) {
      return const Err(NotFoundFailure());
    }
    return MockUtils.single(match.first);
  }

  static Certificate _certificateFromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id']?.toString() ?? '',
      title:
          json['title'] as String? ?? json['name'] as String? ?? 'Certificate',
      issuer:
          json['issuer'] as String? ??
          json['uploadedBy'] as String? ??
          'Issuer',
      issuedAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      credentialId: json['credentialId'] as String? ?? '',
      url: json['url'] as String? ?? json['previewUrl'] as String?,
      skills:
          (json['skills'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
    );
  }
}
