import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/public_catalog_client.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/skill_category.dart';
import '../../domain/entities/skill_option.dart';
import '../../domain/repositories/master_data_repository.dart';

class MasterDataRepositoryImpl implements MasterDataRepository {
  MasterDataRepositoryImpl([PublicCatalogClient? client])
    : _client = client ?? PublicCatalogClient();

  final PublicCatalogClient _client;

  @override
  Future<Result<List<SkillCategory>>> getSkillCategories({
    int page = 1,
    int pageSize = 50,
    String search = '',
  }) async {
    final result = await _client.getList<SkillCategory>(
      path: ApiEndpoints.publicCategories,
      query: {
        'page': page,
        'pageSize': pageSize,
        if (search.trim().isNotEmpty) 'search': search.trim(),
      },
      itemParser: SkillCategory.fromJson,
    );
    if (result.isFailure) {
      return Err(result.failureOrNull!);
    }
    return Success(result.valueOrNull!.rows);
  }

  @override
  Future<Result<List<SkillCategory>>> getIndustries() async {
    final result = await _client.getList<SkillCategory>(
      path: ApiEndpoints.publicCategories,
      query: const {'page': 1, 'pageSize': 100},
      itemParser: SkillCategory.fromJson,
    );
    if (result.isFailure) {
      return Err(result.failureOrNull!);
    }
    final rows =
        result.valueOrNull!.rows
            .where((item) => item.id.isNotEmpty && item.name.trim().isNotEmpty)
            .toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
    return Success(rows);
  }

  @override
  Future<Result<List<SkillOption>>> getSkills({
    required String categoryId,
    int page = 1,
    int pageSize = 100,
  }) async {
    final result = await _client.getList<SkillOption>(
      path: ApiEndpoints.publicSkills,
      query: {'categoryId': categoryId, 'page': page, 'pageSize': pageSize},
      itemParser: SkillOption.fromJson,
    );
    if (result.isFailure) {
      return Err(result.failureOrNull!);
    }
    return Success(result.valueOrNull!.rows);
  }

  @override
  Future<Result<int>> getSkillsTotal({required String categoryId}) async {
    final result = await _client.getList<SkillOption>(
      path: ApiEndpoints.publicSkills,
      query: {'categoryId': categoryId, 'page': 1, 'pageSize': 1},
      itemParser: SkillOption.fromJson,
    );
    if (result.isFailure) {
      return Err(result.failureOrNull!);
    }
    return Success(result.valueOrNull!.total);
  }
}
