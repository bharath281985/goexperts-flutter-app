import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../entities/founder.dart';

abstract class FounderRepository {
  Future<Result<Paginated<Founder>>> getFounders(QueryParams params);
  Future<Result<Founder>> getFounder(String id);
  Future<Result<Paginated<InvestorRequest>>> getInvestorRequests(QueryParams params);
  Future<Result<bool>> respondToRequest(String id, String status);
  Future<Result<bool>> toggleFollow(String id);
}
