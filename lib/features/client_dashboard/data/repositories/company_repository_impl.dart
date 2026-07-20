import '../../../../app/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/file_upload_helper.dart';
import '../../../../core/utils/mock_utils.dart';
import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/company.dart';
import '../../domain/repositories/company_repository.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  CompanyRepositoryImpl([this._api, this._uploader]);
  final ApiClientHelper? _api;
  final FileUploadHelper? _uploader;

  @override
  Future<Result<Paginated<Company>>> getCompanies(QueryParams params) {
    return MockUtils.paginate<Company>(
      MockData.companies,
      params,
      searchMatcher: (c, q) =>
          c.name.toLowerCase().contains(q) ||
          c.industry.toLowerCase().contains(q),
    );
  }

  @override
  Future<Result<Company>> getCompany(String id) {
    final c = MockData.companies.firstWhere(
      (e) => e.id == id,
      orElse: () => MockData.companies.first,
    );
    return MockUtils.single(c);
  }

  @override
  Future<Result<bool>> toggleFollow(String id) => MockUtils.action();

  @override
  Future<Result<Company>> getClientProfile() async {
    if (AppConfig.useMockData || _api == null) {
      return _apiNotConfigured();
    }
    return _api.get<Company>(
      ApiEndpoints.clientProfile,
      parser: (data) => _fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  @override
  Future<Result<Company>> updateClientProfile(
    Map<String, dynamic> data, {
    String? logoPath,
  }) async {
    if (AppConfig.useMockData || _api == null) {
      return _apiNotConfigured();
    }
    if (logoPath != null && _uploader != null) {
      final uploadRes = await _uploader.upload(
        path: logoPath,
        endpoint: ApiEndpoints.clientProfile,
        fileField: 'file',
        method: 'put',
        fields: data,
      );
      return uploadRes.fold(Err.new, (json) => Success(_fromJson(json)));
    }
    return _api.put<Company>(
      ApiEndpoints.clientProfile,
      body: data,
      parser: (raw) => _fromJson(Map<String, dynamic>.from(raw as Map)),
    );
  }

  @override
  Future<Result<String>> uploadClientLogo(String filePath) async {
    if (AppConfig.useMockData || _api == null || _uploader == null) {
      return _apiNotConfigured();
    }
    return _uploader.uploadUrl(
      path: filePath,
      endpoint: ApiEndpoints.clientProfileLogo,
    );
  }

  @override
  Future<Result<String>> uploadClientDocument(String filePath) async {
    if (AppConfig.useMockData || _api == null || _uploader == null) {
      return _apiNotConfigured();
    }
    final direct = await _uploader.uploadUrl(
      path: filePath,
      endpoint: ApiEndpoints.clientProfileDocuments,
    );
    if (direct.isSuccess) return direct;
    return _uploader.uploadUrl(
      path: filePath,
      endpoint: ApiEndpoints.filesUpload,
      fields: {'category': 'company_document'},
    );
  }

  Company _fromJson(Map<String, dynamic> json) => Company(
    id: json['id']?.toString() ?? 'company',
    name:
        json['name'] as String? ??
        json['companyName'] as String? ??
        json['company'] as String? ??
        'Company',
    industry: json['industry'] as String? ?? 'General',
    location:
        json['location'] as String? ?? json['address'] as String? ?? 'N/A',
    ownerName: json['ownerName'] as String? ?? '',
    logoUrl:
        json['logoUrl'] as String? ??
        json['logo'] as String? ??
        json['avatarUrl'] as String?,
    coverUrl: json['coverUrl'] as String?,
    description: json['description'] as String? ?? '',
    website: json['website'] as String?,
    teamSize: json['teamSize']?.toString() ?? '1-10',
    isVerified: json['isVerified'] as bool? ?? false,
    projectsPosted: (json['projectsPosted'] as num?)?.toInt() ?? 0,
    hiresCount: (json['hiresCount'] as num?)?.toInt() ?? 0,
    rating: (json['rating'] as num?)?.toDouble() ?? 0,
    isFollowing: json['isFollowing'] as bool? ?? false,
    isSaved: json['isSaved'] as bool? ?? false,
    gst: json['gst'] as String? ?? '',
    pan: json['pan'] as String? ?? '',
  );

  Future<Result<T>> _apiNotConfigured<T>() async =>
      const Err(ServerFailure('Live API client is not configured.'));
}
