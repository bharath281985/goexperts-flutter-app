import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../entities/app_document.dart';

abstract class DocumentRepository {
  Future<Result<Paginated<AppDocument>>> getDocuments(
    QueryParams params, {
    String? category,
  });
  Future<Result<AppDocument>> getDocument(String id);
  Future<Result<String>> uploadDocument({
    required String filePath,
    required String category,
    void Function(int sent, int total)? onProgress,
  });
  Future<Result<String>> previewUrl(String id);
  Future<Result<String>> downloadUrl(String id);
  Future<Result<bool>> deleteDocument(String id);
}
