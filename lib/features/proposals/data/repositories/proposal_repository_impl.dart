import '../../../../app/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/proposal.dart';
import '../../domain/repositories/proposal_repository.dart';

class ProposalRepositoryImpl implements ProposalRepository {
  ProposalRepositoryImpl([this._api]);

  final ApiClientHelper? _api;

  @override
  Future<Result<Paginated<Proposal>>> getProposals(QueryParams params) {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();

    return _api.getEnvelope<Paginated<Proposal>>(
      ApiEndpoints.freelancerProposals,
      query: params.toApiQuery(),
      parser: (envelope) => ApiResponse.parsePaginated(
        envelope.data,
        envelope.meta,
        _proposalFromJson,
        fallbackPage: params.page,
      ),
    );
  }

  @override
  Future<Result<Proposal>> getProposal(String id) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();

    return _api.get<Proposal>(
      '${ApiEndpoints.freelancerProposals}/$id',
      parser: (data) =>
          _proposalFromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  @override
  Future<Result<Proposal>> submitProposal({
    required String projectId,
    required String coverLetter,
    required double bidAmount,
    required int deliveryDays,
    List<String> attachments = const [],
  }) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();

    final body = <String, dynamic>{
      'projectId': projectId,
      'bidAmount': bidAmount,
      'coverLetter': coverLetter,
      'deliveryTime': deliveryDays,
      if (attachments.isNotEmpty) 'attachments': attachments,
    };

    return _api.post<Proposal>(
      ApiEndpoints.freelancerProposals,
      body: body,
      parser: (data) =>
          _proposalFromJson(Map<String, dynamic>.from(data as Map)),
      allowNullData: false,
    );
  }

  @override
  Future<Result<Proposal>> updateProposal({
    required String proposalId,
    required String coverLetter,
    required double bidAmount,
    int? deliveryDays,
  }) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();

    return _api.putEnvelope<Proposal>(
      ApiEndpoints.freelancerProposal(proposalId),
      body: {
        'bidAmount': bidAmount,
        'coverLetter': coverLetter,
        if (deliveryDays != null) 'deliveryTime': deliveryDays,
      },
      parser: (envelope) => _proposalFromJson(
        Map<String, dynamic>.from(envelope.data as Map),
      ),
    );
  }

  @override
  Future<Result<bool>> withdraw(String id) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    return _api.deleteAction(ApiEndpoints.freelancerProposalWithdraw(id));
  }

  @override
  Future<Result<bool>> deleteProposal(String id) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    return _api.deleteAction(ApiEndpoints.freelancerProposal(id));
  }

  @override
  Future<Result<bool>> updateStatus(String id, String status) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final normalized = status.toLowerCase().trim();
    final path = switch (normalized) {
      'shortlisted' || 'shortlist' => ApiEndpoints.clientProposalShortlist(id),
      'rejected' || 'reject' => ApiEndpoints.clientProposalReject(id),
      'interview' => ApiEndpoints.clientProposalInterview(id),
      'accepted' || 'accept' => ApiEndpoints.clientProposalAccept(id),
      _ => null,
    };
    if (path == null) {
      return Err(ValidationFailure('Unsupported proposal status: $status'));
    }
    return _api.patchAction(path);
  }

  static Proposal _proposalFromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'] as String? ?? 'pending';
    final deliveryDays =
        json['deliveryDays'] ?? json['deliveryTime'] ?? json['delivery_time'];

    return Proposal(
      id: json['id']?.toString() ?? '',
      projectId:
          json['projectId']?.toString() ?? json['project_id']?.toString() ?? '',
      projectTitle:
          json['projectTitle'] as String? ??
          json['project_title'] as String? ??
          'Project',
      clientId: json['clientId']?.toString() ??
          json['client_id']?.toString() ??
          (json['project'] is Map
              ? (json['project'] as Map)['client']?.toString()
              : null),
      clientName:
          json['clientName'] as String? ?? json['client_name'] as String?,
      freelancerId: json['freelancerId']?.toString() ??
          json['freelancer_id']?.toString(),
      freelancerName:
          json['freelancerName'] as String? ??
          json['freelancer_name'] as String? ??
          'Freelancer',
      freelancerAvatar:
          json['freelancerAvatar'] as String? ??
          json['freelancer_avatar'] as String? ??
          json['avatarUrl'] as String?,
      bidAmount:
          (json['bidAmount'] as num?)?.toDouble() ??
          (json['bid_amount'] as num?)?.toDouble() ??
          0,
      isHourly:
          json['isHourly'] as bool? ?? json['is_hourly'] as bool? ?? false,
      coverLetter:
          json['coverLetter'] as String? ??
          json['cover_letter'] as String? ??
          json['coverletter'] as String? ??
          '',
      status: EntityStatus.fromString(rawStatus),
      submittedAt:
          DateTime.tryParse(
            json['createdAt'] as String? ?? json['created_at'] as String? ?? '',
          ) ??
          DateTime.now(),
      deliveryDays: (deliveryDays as num?)?.toInt() ?? 14,
      freelancerRating:
          (json['freelancerRating'] as num?)?.toDouble() ??
          (json['freelancer_rating'] as num?)?.toDouble() ??
          4.8,
      attachments:
          (json['attachments'] as List?)?.map((e) => e.toString()).toList() ??
          (json['attachmentUrls'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  static Future<Result<T>> _apiNotConfigured<T>() async =>
      const Err(ServerFailure('Live API client is not configured.'));
}
