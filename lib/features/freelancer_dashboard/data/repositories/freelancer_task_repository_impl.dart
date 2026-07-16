import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/file_upload_helper.dart';
import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/freelancer_task.dart';
import '../../domain/repositories/freelancer_task_repository.dart';

class FreelancerTaskRepositoryImpl implements FreelancerTaskRepository {
  FreelancerTaskRepositoryImpl(this._api, this._uploader);

  final ApiClientHelper _api;
  final FileUploadHelper _uploader;

  @override
  Future<Result<Paginated<FreelancerTask>>> getTasks(QueryParams params) {
    return _api.getEnvelope<Paginated<FreelancerTask>>(
      ApiEndpoints.freelancerTasks,
      query: params.toApiQuery(),
      parser: (envelope) => ApiResponse.parsePaginated(
        envelope.data,
        envelope.meta,
        FreelancerTask.fromApiJson,
        fallbackPage: params.page,
      ),
    );
  }

  @override
  Future<Result<FreelancerTask>> getTask(String id) {
    return _api.get<FreelancerTask>(
      ApiEndpoints.freelancerTask(id),
      parser: (data) =>
          FreelancerTask.fromApiJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  @override
  Future<Result<bool>> updateTaskStatus(String id, String status) {
    return _api.patchAction(
      ApiEndpoints.freelancerTaskStatus(id),
      body: {'status': status},
    );
  }

  @override
  Future<Result<List<TaskComment>>> getComments(String taskId) async {
    final task = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.freelancerTask(taskId),
      parser: (data) => Map<String, dynamic>.from(data as Map),
    );
    return task.fold(
      (f) => Err(f),
      (json) => Success(
        (json['comments'] as List?)
                ?.whereType<Map>()
                .map((e) => TaskComment.fromApiJson(Map<String, dynamic>.from(e)))
                .toList() ??
            const [],
      ),
    );
  }

  @override
  Future<Result<List<TaskAttachment>>> getAttachments(String taskId) async {
    final task = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.freelancerTask(taskId),
      parser: (data) => Map<String, dynamic>.from(data as Map),
    );
    return task.fold(
      (f) => Err(f),
      (json) => Success(
        (json['attachments'] as List?)
                ?.whereType<Map>()
                .map((e) => TaskAttachment.fromApiJson(Map<String, dynamic>.from(e)))
                .toList() ??
            const [],
      ),
    );
  }

  @override
  Future<Result<List<TaskTimeLog>>> getTimeLogs(String taskId) async {
    // Prefer dedicated endpoint if available.
    final dedicated = await _api.getEnvelope<List<TaskTimeLog>>(
      '${ApiEndpoints.freelancerTask(taskId)}/time-logs',
      parser: (envelope) => ApiResponse.parseList(
        envelope.data,
        TaskTimeLog.fromApiJson,
      ),
    );
    if (dedicated.isSuccess) return Success(dedicated.valueOrNull ?? const []);

    final task = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.freelancerTask(taskId),
      parser: (data) => Map<String, dynamic>.from(data as Map),
    );
    return task.fold(
      (f) => Err(f),
      (json) => Success(
        (json['timeLogs'] as List?)
                ?.whereType<Map>()
                .map((e) => TaskTimeLog.fromApiJson(Map<String, dynamic>.from(e)))
                .toList() ??
            const [],
      ),
    );
  }

  @override
  Future<Result<bool>> addComment(String taskId, String text) {
    return _api.postAction(
      '${ApiEndpoints.freelancerTask(taskId)}/comments',
      body: {'comment': text},
    );
  }

  @override
  Future<Result<bool>> addAttachment(String taskId, String filePath) async {
    final res = await _uploader.upload(
      path: filePath,
      endpoint: ApiEndpoints.filesUpload,
      fields: {'category': 'task_attachment', 'taskId': taskId},
    );
    return res.fold((f) => Err(f), (_) => const Success(true));
  }
}
