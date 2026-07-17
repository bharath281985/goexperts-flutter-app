import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../entities/startup.dart';

abstract class StartupRepository {
  Future<Result<Paginated<Startup>>> getStartups(QueryParams params);
  Future<Result<Startup>> getStartup(String id);
  Future<Result<bool>> toggleSave(String id);
  Future<Result<bool>> toggleFollow(String id);
  Future<Result<bool>> expressInterest(String id);
  Future<Result<bool>> withdrawInterest(String id);
  Future<Result<Startup>> createIdea(Map<String, dynamic> data);
  Future<Result<Startup>> updateIdea(String id, Map<String, dynamic> data);
  Future<Result<bool>> deleteIdea(String id);
}
