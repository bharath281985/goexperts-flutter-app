import '../../../../app/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../../../proposals/domain/entities/proposal.dart';
import '../../domain/repositories/client_proposal_repository.dart';
import '../datasources/client_proposal_remote_datasource.dart';

class ClientProposalRepositoryImpl implements ClientProposalRepository {
  ClientProposalRepositoryImpl(this._remote);

  final ClientProposalRemoteDatasource _remote;

  @override
  Future<Result<Paginated<Proposal>>> getProposals(QueryParams params) async {
    if (AppConfig.useMockData) {
      return _mockModeDisabled();
    }
    try {
      final data = await _remote.getProposals(params);
      return Success(data);
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Paginated<Proposal>>> getProjectProposals(
    String projectId,
    QueryParams params,
  ) async {
    if (AppConfig.useMockData) {
      return _mockModeDisabled();
    }
    try {
      final data = await _remote.getProjectProposals(projectId, params);
      return Success(data);
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Proposal>> getProposal(String id) async {
    if (AppConfig.useMockData) {
      return _mockModeDisabled();
    }
    try {
      return Success(await _remote.getProposal(id));
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Proposal>> shortlist(String id) => _action(
        id,
        () => _remote.shortlist(id),
      );

  @override
  Future<Result<Proposal>> reject(String id) => _action(
        id,
        () => _remote.reject(id),
      );

  @override
  Future<Result<Proposal>> moveToInterview(String id) => _action(
        id,
        () => _remote.moveToInterview(id),
      );

  @override
  Future<Result<Proposal>> accept(String id) => _action(
        id,
        () => _remote.accept(id),
      );

  @override
  Future<Result<bool>> sendMessage(String id, String message) async {
    if (AppConfig.useMockData) return _mockModeDisabled();
    try {
      return Success(await _remote.sendMessage(id, message));
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  Future<Result<Proposal>> _action(
    String id,
    Future<Proposal> Function() remote,
  ) async {
    if (AppConfig.useMockData) {
      return _mockModeDisabled();
    }
    try {
      return Success(await remote());
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  Future<Result<T>> _mockModeDisabled<T>() async =>
      const Err(ServerFailure('Live API data is required for this screen.'));
}
