import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/file_upload_helper.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/freelancer_profile.dart';
import '../../domain/repositories/freelancer_profile_repository.dart';

class FreelancerProfileRepositoryImpl implements FreelancerProfileRepository {
  FreelancerProfileRepositoryImpl(this._api, this._uploader);

  final ApiClientHelper _api;
  final FileUploadHelper _uploader;

  @override
  Future<Result<FreelancerProfile>> getProfile() {
    return _api.get<FreelancerProfile>(
      ApiEndpoints.freelancerProfile,
      parser: (data) =>
          FreelancerProfile.fromApiJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  @override
  Future<Result<FreelancerProfile>> updateProfile(Map<String, dynamic> data) {
    return _api.put<FreelancerProfile>(
      ApiEndpoints.freelancerProfile,
      body: data,
      parser: (raw) =>
          FreelancerProfile.fromApiJson(Map<String, dynamic>.from(raw as Map)),
    );
  }

  @override
  Future<Result<String>> uploadAvatar(
    String filePath, {
    void Function(int sent, int total)? onProgress,
  }) async {
    return _uploader.uploadUrl(
      path: filePath,
      endpoint: ApiEndpoints.freelancerProfileAvatar,
      onProgress: onProgress,
    );
  }

  @override
  Future<Result<String>> uploadResume(
    String filePath, {
    void Function(int sent, int total)? onProgress,
  }) async {
    return _uploader.uploadUrl(
      path: filePath,
      endpoint: ApiEndpoints.freelancerProfileResume,
      onProgress: onProgress,
    );
  }

  @override
  Future<Result<String>> uploadCertificate(
    String filePath, {
    void Function(int sent, int total)? onProgress,
  }) async {
    return _uploader.uploadUrl(
      path: filePath,
      endpoint: ApiEndpoints.filesUpload,
      fields: {'category': 'certificate'},
      onProgress: onProgress,
    );
  }
}
