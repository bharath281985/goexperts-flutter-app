import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../entities/startup.dart';

abstract class StartupRepository {
  Future<Result<Paginated<Startup>>> getStartups(QueryParams params);
  Future<Result<Startup>> getStartup(String id);
  Future<Result<bool>> toggleSave(String id);
  Future<Result<bool>> toggleFollow(String id);
  Future<Result<bool>> expressInterest(String id);
}
