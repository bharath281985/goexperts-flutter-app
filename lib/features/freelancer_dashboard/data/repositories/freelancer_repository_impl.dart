import '../../../../app/config/app_config.dart';
import '../../../../core/auth/token_role_helper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/freelancer.dart';
import '../../domain/repositories/freelancer_repository.dart';

class FreelancerRepositoryImpl implements FreelancerRepository {
  FreelancerRepositoryImpl([this._api, this._tokenRoleHelper]);

  final ApiClientHelper? _api;
  final TokenRoleHelper? _tokenRoleHelper;

  @override
  Future<Result<Paginated<Freelancer>>> getFreelancers(
    QueryParams params,
  ) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final role = await _tokenRoleHelper?.resolve();
    final path = role == UserRole.client
        ? ApiEndpoints.clientFreelancers
        : ApiEndpoints.publicFreelancers;
    return _api.getEnvelope<Paginated<Freelancer>>(
      path,
      query: params.toApiQuery(),
      parser: (env) => ApiResponse.parsePaginated(
        env.data,
        env.meta,
        _fromJson,
        fallbackPage: params.page,
      ),
    );
  }

  @override
  Future<Result<Freelancer>> getFreelancer(String id) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final role = await _tokenRoleHelper?.resolve();
    final path = role == UserRole.client
        ? '${ApiEndpoints.clientFreelancers}/$id'
        : '${ApiEndpoints.publicFreelancers}/$id';
    return _api.get<Freelancer>(
      path,
      parser: (data) => _fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  @override
  Future<Result<bool>> toggleSave(String id) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    return _api.postAction('${ApiEndpoints.clientFreelancers}/$id/save');
  }

  @override
  Future<Result<bool>> toggleFollow(String id) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    return _api.postAction(
      '${ApiEndpoints.favorites}/toggle',
      body: {'entityType': 'freelancer', 'entityId': id},
    );
  }

  @override
  Future<Result<bool>> invite(String id) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    // Opens chat / DM invite via client team invite when available.
    return _api.postAction(
      '${ApiEndpoints.clientTeam}/invite',
      body: {'freelancerId': id, 'role': 'member'},
    );
  }

  static Freelancer _fromJson(Map<String, dynamic> json) {
    return Freelancer(
      id: json['id']?.toString() ?? '',
      name:
          json['name'] as String? ??
          json['fullName'] as String? ??
          'Freelancer',
      headline: json['headline'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      skills:
          (json['skills'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 0,
      location: json['location'] as String? ?? 'Remote',
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String? ?? '',
      isSaved: json['isSaved'] as bool? ?? false,
      isFollowing: json['isFollowing'] as bool? ?? false,
      languages:
          (json['languages'] as List?)?.map((e) => e.toString()).toList() ??
          const ['English'],
      followers: (json['followers'] as num?)?.toInt() ?? 0,
      successRate: (json['successRate'] as num?)?.toInt() ?? 0,
    );
  }

  Future<Result<T>> _apiNotConfigured<T>() async =>
      const Err(ServerFailure('Live API client is not configured.'));
}
