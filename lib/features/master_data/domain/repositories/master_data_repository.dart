import '../../../../core/utils/result.dart';
import '../entities/skill_category.dart';
import '../entities/skill_option.dart';

abstract class MasterDataRepository {
  Future<Result<List<SkillCategory>>> getSkillCategories({
    int page,
    int pageSize,
    String search,
  });

  /// Categories for profile completion — backed by the public categories API.
  Future<Result<List<SkillCategory>>> getIndustries();

  Future<Result<List<SkillOption>>> getSkills({
    required String categoryId,
    int page,
    int pageSize,
  });

  Future<Result<int>> getSkillsTotal({required String categoryId});
}
