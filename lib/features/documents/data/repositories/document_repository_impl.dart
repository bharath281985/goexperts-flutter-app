import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/file_upload_helper.dart';
import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/app_document.dart';
import '../../domain/repositories/document_repository.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  DocumentRepositoryImpl(this._api, this._uploader);

  final ApiClientHelper _api;
  final FileUploadHelper _uploader;
  Paginated<AppDocument>? _lastSuccess;

  @override
  Future<Result<Paginated<AppDocument>>> getDocuments(
    QueryParams params, {
    String? category,
  }) async {
    final res = await _api.getEnvelope<Paginated<AppDocument>>(
      ApiEndpoints.files,
      query: {
        ...params.toApiQuery(),
        if (category != null && category.isNotEmpty) 'category': category,
      },
      parser: (envelope) => ApiResponse.parsePaginated(
        envelope.data,
        envelope.meta,
        AppDocument.fromApiJson,
        fallbackPage: params.page,
      ),
    );
    return res.fold(
      (f) {
        if (_lastSuccess != null) return Success(_lastSuccess!);
        return Err(f);
      },
      (page) {
        _lastSuccess = page;
        return Success(page);
      },
    );
  }

  @override
  Future<Result<AppDocument>> getDocument(String id) {
    return _api.get<AppDocument>(
      ApiEndpoints.fileById(id),
      parser: (raw) => AppDocument.fromApiJson(Map<String, dynamic>.from(raw as Map)),
    );
  }

  @override
  Future<Result<String>> previewUrl(String id) async {
    final res = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.filePreview(id),
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    return res.fold((f) => Err(f), (json) => Success(json['url']?.toString() ?? ''));
  }

  @override
  Future<Result<String>> downloadUrl(String id) async {
    final res = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.fileDownload(id),
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    return res.fold((f) => Err(f), (json) => Success(json['url']?.toString() ?? ''));
  }

  @override
  Future<Result<String>> uploadDocument({
    required String filePath,
    required String category,
    void Function(int sent, int total)? onProgress,
  }) async {
    return _uploader.uploadUrl(
      path: filePath,
      endpoint: ApiEndpoints.filesUpload,
      fields: {'category': category},
      onProgress: onProgress,
    );
  }

  @override
  Future<Result<bool>> deleteDocument(String id) {
    return _api.deleteAction(ApiEndpoints.fileById(id));
  }
}
