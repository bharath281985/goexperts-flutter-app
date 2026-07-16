import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../entities/catalog_entities.dart';

/// Serves reference/content entities (services, technologies, categories,
/// certificates and startup assets) that back the standalone detail pages.
abstract class CatalogRepository {
  Future<Result<Paginated<ServiceItem>>> getServices(QueryParams params);
  Future<Result<ServiceItem>> getService(String id);

  Future<Result<Paginated<Technology>>> getTechnologies(QueryParams params);
  Future<Result<Technology>> getTechnology(String id);

  Future<Result<Paginated<CategoryItem>>> getCategories(QueryParams params);
  Future<Result<CategoryItem>> getCategory(String id);

  Future<Result<Paginated<Certificate>>> getCertificates(QueryParams params);
  Future<Result<Certificate>> getCertificate(String id);

  Future<Result<Paginated<InvestmentOpportunity>>> getOpportunities(QueryParams params);
  Future<Result<InvestmentOpportunity>> getOpportunity(String id);

  Future<Result<BusinessPlan>> getBusinessPlan(String startupId);
  Future<Result<PitchDeck>> getPitchDeck(String startupId);
}
