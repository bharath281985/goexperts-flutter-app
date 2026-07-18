import '../../../../core/errors/failures.dart';
import '../../../../core/auth/token_role_helper.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  ReviewRepositoryImpl([this._api, this._tokenRoleHelper]);

  final ApiClientHelper? _api;
  final TokenRoleHelper? _tokenRoleHelper;

  @override
  Future<Result<Paginated<Review>>> getReviews(QueryParams params) async {
    if (_api == null) return _apiNotConfigured();

    final role = await _tokenRoleHelper?.resolve();
    final prefix = (role == UserRole.freelancer)
        ? 'freelancer'
        : (role == UserRole.client)
        ? 'client'
        : (role == UserRole.investor)
        ? 'investor'
        : 'founder';
    final path = '/$prefix/reviews';

    return _api.getEnvelope<Paginated<Review>>(
      path,
      query: params.toApiQuery(),
      parser: (envelope) => ApiResponse.parsePaginated(
        envelope.data,
        envelope.meta,
        _reviewFromJson,
        fallbackPage: params.page,
      ),
    );
  }

  @override
  Future<Result<Review>> getReview(String id) async {
    if (_api == null) return _apiNotConfigured();

    final list = await getReviews(const QueryParams(page: 1, pageSize: 100));
    return list.fold((failure) => Err(failure), (page) {
      final match = page.items.where((r) => r.id == id);
      if (match.isEmpty) return const Err(NotFoundFailure());
      return Success(match.first);
    });
  }

  @override
  Future<Result<Map<String, dynamic>>> getReviewsAverage() async {
    if (_api == null) return _apiNotConfigured();

    final role = await _tokenRoleHelper?.resolve();
    final prefix = (role == UserRole.freelancer)
        ? 'freelancer'
        : (role == UserRole.client)
        ? 'client'
        : (role == UserRole.investor)
        ? 'investor'
        : 'founder';
    final path = '/$prefix/reviews/average';

    return _api.getEnvelope<Map<String, dynamic>>(
      path,
      parser: (envelope) {
        final data = envelope.data;
        if (data is Map<String, dynamic>) {
          return data;
        }
        return {};
      },
    );
  }

  @override
  Future<Result<bool>> submitReview({
    required double rating,
    required String comment,
    required String targetType,
    String? targetId,
  }) async {
    if (_api == null) return _apiNotConfigured();
    final role = await _tokenRoleHelper?.resolve();
    if (role != UserRole.client) {
      return const Err(
        ServerFailure('Only clients can submit reviews currently.'),
      );
    }
    if (targetId == null || targetId.isEmpty) {
      return const Err(ValidationFailure('Review target is required.'));
    }
    return _api.postAction(
      ApiEndpoints.clientReviews,
      body: {
        'revieweeId': targetId,
        'rating': rating,
        'comment': comment,
        'targetType': targetType,
      },
    );
  }

  @override
  Future<Result<bool>> reportReview(String id, String reason) async {
    if (_api == null) return _apiNotConfigured();
    // Report via support ticket until a dedicated moderation API exists.
    return _api.postAction(
      ApiEndpoints.supportTickets,
      body: {
        'subject': 'Report review $id',
        'category': 'moderation',
        'priority': 'Medium',
        'message': reason,
      },
    );
  }

  static Review _reviewFromJson(Map<String, dynamic> json) {
    final ratingRaw = json['rating'] as num?;
    final createdAtRaw =
        json['createdAt'] as String? ?? json['created_at'] as String? ?? '';

    return Review(
      id: json['id']?.toString() ?? '',
      authorName:
          json['authorName'] as String? ??
          json['reviewerName'] as String? ??
          json['reviewerId'] as String? ??
          json['reviewer_name'] as String? ??
          'User',
      authorAvatar:
          json['authorAvatar'] as String? ?? json['avatar'] as String?,
      rating: ratingRaw?.toDouble() ?? 0,
      comment:
          json['comment'] as String? ??
          json['body'] as String? ??
          json['message'] as String? ??
          '',
      context: json['context'] as String? ?? '',
      createdAt: DateTime.tryParse(createdAtRaw) ?? DateTime.now(),
      reply: json['reply'] as String? ?? json['response'] as String?,
    );
  }

  Future<Result<T>> _apiNotConfigured<T>() async =>
      const Err(ServerFailure('Live API client is not configured.'));
}
