import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../entities/meeting.dart';

abstract class MeetingRepository {
  Future<Result<Paginated<Meeting>>> getMeetings(QueryParams params);
  Future<Result<Meeting>> getMeeting(String id);
  Future<Result<bool>> schedule(Meeting meeting);
  Future<Result<bool>> cancel(String id);
  Future<Result<bool>> reschedule(String id, DateTime newStartTime);
}
