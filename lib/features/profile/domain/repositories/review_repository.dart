import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../entities/review.dart';

abstract class ReviewRepository {
  Future<Result<Paginated<Review>>> getReviews(QueryParams params);
  Future<Result<Review>> getReview(String id);
  Future<Result<Map<String, dynamic>>> getReviewsAverage();
  Future<Result<bool>> submitReview({
    required double rating,
    required String comment,
    required String targetType,
    String? targetId,
  });
  Future<Result<bool>> reportReview(String id, String reason);
}
