import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../entities/app_notification.dart';

abstract class NotificationRepository {
  Future<Result<Paginated<AppNotification>>> getNotifications(QueryParams params);
  Future<Result<int>> unreadCount();
  Future<Result<bool>> markAllRead();
  Future<Result<bool>> markRead(String id);
  Future<Result<bool>> delete(String id);
  Future<Result<Map<String, dynamic>>> getPreferences();
  Future<Result<bool>> updatePreferences(Map<String, dynamic> data);
}
