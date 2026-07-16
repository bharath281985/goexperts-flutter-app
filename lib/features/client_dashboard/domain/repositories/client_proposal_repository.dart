import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../../../proposals/domain/entities/proposal.dart';

abstract class ClientProposalRepository {
  Future<Result<Paginated<Proposal>>> getProposals(QueryParams params);
  Future<Result<Paginated<Proposal>>> getProjectProposals(
    String projectId,
    QueryParams params,
  );
  Future<Result<Proposal>> getProposal(String id);
  Future<Result<Proposal>> shortlist(String id);
  Future<Result<Proposal>> reject(String id);
  Future<Result<Proposal>> moveToInterview(String id);
  Future<Result<Proposal>> accept(String id);
  Future<Result<bool>> sendMessage(String id, String message);
}
