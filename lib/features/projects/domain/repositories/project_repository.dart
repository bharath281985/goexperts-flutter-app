import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../entities/project.dart';

abstract class ProjectRepository {
  Future<Result<Paginated<Project>>> getProjects(QueryParams params);
  Future<Result<Project>> getProject(String id);
  Future<Result<Project>> updateProject(String id, Map<String, dynamic> data);
  Future<Result<bool>> updateProjectStatus(String id, String status);
  Future<Result<bool>> deleteProject(String id);
  Future<Result<bool>> trackProjectShare(String id, String platform);
  Future<Result<bool>> toggleSave(String id);
  Future<Result<bool>> apply(String id);
  Future<Result<Paginated<Contract>>> getContracts(QueryParams params);
  Future<Result<Contract>> getContract(String id);
}
