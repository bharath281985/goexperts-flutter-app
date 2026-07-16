import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/paginated.dart';
import '../models/client_proposal_model.dart';
import '../../../proposals/domain/entities/proposal.dart';

class ClientProposalRemoteDatasource {
  ClientProposalRemoteDatasource(this._api);

  final ApiClientHelper _api;

  Future<Paginated<Proposal>> getProposals(QueryParams params) async {
    final result = await _api.getEnvelope<Paginated<Proposal>>(
      ApiEndpoints.clientProposals,
      query: params.toApiQuery(),
      parser: (envelope) => ApiResponse.parsePaginated(
        envelope.data,
        envelope.meta,
        ClientProposalModel.fromJson,
        fallbackPage: params.page,
      ),
    );
    return result.fold((f) => throw Exception(f.message), (data) => data);
  }

  Future<Paginated<Proposal>> getProjectProposals(
    String projectId,
    QueryParams params,
  ) async {
    final result = await _api.getEnvelope<Paginated<Proposal>>(
      ApiEndpoints.clientProjectProposals(projectId),
      query: params.toApiQuery(),
      parser: (envelope) => ApiResponse.parsePaginated(
        envelope.data,
        envelope.meta,
        ClientProposalModel.fromJson,
        fallbackPage: params.page,
      ),
    );
    return result.fold((f) => throw Exception(f.message), (data) => data);
  }

  Future<Proposal> getProposal(String id) async {
    final result = await _api.get<Proposal>(
      ApiEndpoints.clientProposal(id),
      parser: (data) => ClientProposalModel.fromJson(
        Map<String, dynamic>.from(data as Map),
      ),
    );
    return result.fold((f) => throw Exception(f.message), (data) => data);
  }

  Future<Proposal> _patchStatus(String id, String endpoint) async {
    await _api.patchAction(endpoint);
    return getProposal(id);
  }

  Future<Proposal> shortlist(String id) =>
      _patchStatus(id, ApiEndpoints.clientProposalShortlist(id));

  Future<Proposal> reject(String id) =>
      _patchStatus(id, ApiEndpoints.clientProposalReject(id));

  Future<Proposal> moveToInterview(String id) =>
      _patchStatus(id, ApiEndpoints.clientProposalInterview(id));

  Future<Proposal> accept(String id) =>
      _patchStatus(id, ApiEndpoints.clientProposalAccept(id));

  Future<bool> sendMessage(String id, String message) async {
    final result = await _api.postAction(
      ApiEndpoints.clientProposalMessage(id),
      body: {'message': message},
    );
    return result.fold((f) => throw Exception(f.message), (v) => v);
  }
}
