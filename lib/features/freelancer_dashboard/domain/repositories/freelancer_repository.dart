import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../entities/freelancer.dart';

abstract class FreelancerRepository {
  Future<Result<Paginated<Freelancer>>> getFreelancers(QueryParams params);
  Future<Result<Freelancer>> getFreelancer(String id);
  Future<Result<bool>> toggleSave(String id);
  Future<Result<bool>> toggleFollow(String id);
  Future<Result<bool>> invite(String id);
}
