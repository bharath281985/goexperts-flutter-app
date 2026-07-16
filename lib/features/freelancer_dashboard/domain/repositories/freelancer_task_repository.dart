import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../entities/freelancer_task.dart';

abstract class FreelancerTaskRepository {
  Future<Result<Paginated<FreelancerTask>>> getTasks(QueryParams params);
  Future<Result<FreelancerTask>> getTask(String id);
  Future<Result<bool>> updateTaskStatus(String id, String status);
  Future<Result<List<TaskComment>>> getComments(String taskId);
  Future<Result<List<TaskAttachment>>> getAttachments(String taskId);
  Future<Result<List<TaskTimeLog>>> getTimeLogs(String taskId);
  Future<Result<bool>> addComment(String taskId, String text);
  Future<Result<bool>> addAttachment(String taskId, String filePath);
}
