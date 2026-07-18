import '../../../../app/config/app_config.dart';
import '../../../../core/auth/token_role_helper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/enums.dart';
import '../../domain/entities/meeting.dart';
import '../../domain/repositories/meeting_repository.dart';

class MeetingRepositoryImpl implements MeetingRepository {
  MeetingRepositoryImpl([this._api, this._tokenRoleHelper]);

  final ApiClientHelper? _api;
  final TokenRoleHelper? _tokenRoleHelper;

  @override
  Future<Result<Paginated<Meeting>>> getMeetings(QueryParams params) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();

    final role = await _tokenRoleHelper?.resolve();
    final path = (role == UserRole.freelancer)
        ? ApiEndpoints.freelancerMeetings
        : (role == UserRole.client)
        ? ApiEndpoints.clientMeetings
        : (role == UserRole.investor)
        ? ApiEndpoints.investorMeetings
        : (role == UserRole.founder)
        ? ApiEndpoints.founderMeetings
        : ApiEndpoints.meetings;

    final result = await _api.getEnvelope<List<Meeting>>(
      path,
      query: params.toApiQuery(),
      parser: (envelope) {
        final rawData = envelope.data;
        dynamic listRaw = rawData;
        if (rawData is Map) {
          listRaw =
              rawData['meetings'] ??
              rawData['items'] ??
              rawData['data'] ??
              rawData;
        }
        return ApiResponse.parseList(listRaw, _meetingFromJson);
      },
    );

    return result.fold(
      (failure) => Err(failure),
      (list) => Success(
        Paginated(
          items: list,
          page: params.page,
          totalPages: 1,
          totalItems: list.length,
        ),
      ),
    );
  }

  @override
  Future<Result<Meeting>> getMeeting(String id) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();

    final role = await _tokenRoleHelper?.resolve();
    final path = (role == UserRole.freelancer)
        ? ApiEndpoints.freelancerMeeting(id)
        : (role == UserRole.client)
        ? '${ApiEndpoints.clientMeetings}/$id'
        : (role == UserRole.investor)
        ? '${ApiEndpoints.investorMeetings}/$id'
        : (role == UserRole.founder)
        ? '${ApiEndpoints.founderMeetings}/$id'
        : '${ApiEndpoints.meetings}/$id';

    return _api.get<Meeting>(
      path,
      parser: (data) =>
          _meetingFromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  @override
  Future<Result<bool>> schedule(Meeting meeting) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final role = await _tokenRoleHelper?.resolve();
    if (role == UserRole.freelancer) {
      return const Err(
        ServerFailure('Freelancer cannot schedule meetings via this API.'),
      );
    }
    final path = (role == UserRole.client)
        ? ApiEndpoints.clientMeetings
        : (role == UserRole.investor)
        ? ApiEndpoints.investorMeetings
        : (role == UserRole.founder)
        ? ApiEndpoints.founderMeetings
        : ApiEndpoints.meetings;

    final start = meeting.startTime;
    final date =
        '${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
    final time =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final withUserId = meeting.participants.isNotEmpty
        ? meeting.participants.first
        : null;

    final body = <String, dynamic>{
      'date': date,
      'time': time,
      'mode': meeting.isVideo ? 'Online' : 'Offline',
    };
    if (role == UserRole.founder) {
      body['investorId'] = withUserId;
    } else {
      body['founderId'] = withUserId;
    }

    return _api.postAction(path, body: body);
  }

  @override
  Future<Result<bool>> cancel(String id) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final role = await _tokenRoleHelper?.resolve();
    if (role == UserRole.freelancer) {
      return const Err(
        ServerFailure('Freelancer cannot cancel meetings via this API.'),
      );
    }
    final base = (role == UserRole.client)
        ? ApiEndpoints.clientMeetings
        : (role == UserRole.investor)
        ? ApiEndpoints.investorMeetings
        : (role == UserRole.founder)
        ? ApiEndpoints.founderMeetings
        : ApiEndpoints.meetings;
    return _api.patchAction('$base/$id/cancel');
  }

  @override
  Future<Result<bool>> reschedule(String id, DateTime newStartTime) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final role = await _tokenRoleHelper?.resolve();
    final base = (role == UserRole.client)
        ? ApiEndpoints.clientMeetings
        : (role == UserRole.investor)
        ? ApiEndpoints.investorMeetings
        : (role == UserRole.founder)
        ? ApiEndpoints.founderMeetings
        : ApiEndpoints.meetings;

    final date =
        '${newStartTime.year.toString().padLeft(4, '0')}-${newStartTime.month.toString().padLeft(2, '0')}-${newStartTime.day.toString().padLeft(2, '0')}';
    final time =
        '${newStartTime.hour.toString().padLeft(2, '0')}:${newStartTime.minute.toString().padLeft(2, '0')}';

    return _api.patchAction(
      '$base/$id/reschedule',
      body: {'date': date, 'time': time},
    );
  }

  static Meeting _meetingFromJson(Map<String, dynamic> json) {
    final date = json['date'] as String?;
    final time = json['time'] as String?;
    final start =
        DateTime.tryParse(
          json['createdAt'] as String? ??
              json['startTime'] as String? ??
              ((date != null && time != null) ? '$date $time' : ''),
        ) ??
        DateTime.now();

    return Meeting(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? 'Meeting',
      withName:
          json['withName'] as String? ??
          json['founder'] as String? ??
          json['investor'] as String? ??
          'Participant',
      withAvatar:
          json['withAvatar'] as String? ??
          json['avatar'] as String? ??
          json['participantAvatar'] as String?,
      startTime: start,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 45,
      status: EntityStatus.fromString(json['status'] as String? ?? 'scheduled'),
      isVideo: (json['isVideo'] as bool?) ?? true,
      meetingLink:
          json['meetingLink'] as String? ?? json['link'] as String? ?? '',
      agenda: json['agenda'] as String? ?? '',
      participants:
          (json['participants'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
    );
  }

  Future<Result<T>> _apiNotConfigured<T>() async =>
      const Err(ServerFailure('Live API client is not configured.'));
}
