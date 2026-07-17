import '../../../../app/config/app_config.dart';
import '../../../../core/auth/token_role_helper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/enums.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl([this._api, this._tokenRoleHelper]);

  final ApiClientHelper? _api;
  final TokenRoleHelper? _tokenRoleHelper;

  @override
  Future<Result<int>> unreadCount() async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final role = await _tokenRoleHelper?.resolve();
    final path = (role == UserRole.freelancer)
        ? ApiEndpoints.freelancerNotificationsUnreadCount
        : ApiEndpoints.notificationsUnreadCount;
    final res = await _api.get<Map<String, dynamic>>(
      path,
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    return res.fold(
      (f) => Err(f),
      (m) => Success((m['count'] as num?)?.toInt() ?? 0),
    );
  }

  @override
  Future<Result<Paginated<AppNotification>>> getNotifications(
    QueryParams params,
  ) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();

    final role = await _tokenRoleHelper?.resolve();
    final path = (role == UserRole.freelancer)
        ? ApiEndpoints.freelancerNotifications
        : ApiEndpoints.notifications;

    final result = await _api.getEnvelope<Paginated<AppNotification>>(
      path,
      query: params.toApiQuery(),
      parser: (envelope) => ApiResponse.parsePaginated(
        envelope.data,
        envelope.meta,
        _fromJson,
        fallbackPage: params.page,
      ),
    );
    return result;
  }

  @override
  Future<Result<bool>> markAllRead() async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final role = await _tokenRoleHelper?.resolve();
    final path = (role == UserRole.freelancer)
        ? ApiEndpoints.freelancerNotificationsReadAll
        : ApiEndpoints.notificationsReadAll;
    return _api.patchAction(path);
  }

  @override
  Future<Result<bool>> markRead(String id) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final role = await _tokenRoleHelper?.resolve();
    final path = (role == UserRole.freelancer)
        ? ApiEndpoints.freelancerNotificationRead(id)
        : ApiEndpoints.notificationRead(id);
    return _api.patchAction(path);
  }

  @override
  Future<Result<bool>> delete(String id) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final role = await _tokenRoleHelper?.resolve();
    final path = (role == UserRole.freelancer)
        ? ApiEndpoints.freelancerNotificationDelete(id)
        : ApiEndpoints.notificationDelete(id);
    return _api.deleteAction(path);
  }

  @override
  Future<Result<Map<String, dynamic>>> getPreferences() async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final role = await _tokenRoleHelper?.resolve();
    final path = (role == UserRole.freelancer)
        ? ApiEndpoints.freelancerNotificationPreferences
        : ApiEndpoints.notificationsPreferences;
    return _api.get<Map<String, dynamic>>(
      path,
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
  }

  @override
  Future<Result<bool>> updatePreferences(Map<String, dynamic> data) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final role = await _tokenRoleHelper?.resolve();
    final path = (role == UserRole.freelancer)
        ? ApiEndpoints.freelancerNotificationPreferences
        : ApiEndpoints.notificationsPreferences;
    final res = await _api.put<Map<String, dynamic>>(
      path,
      body: data,
      parser: (raw) => Map<String, dynamic>.from(raw as Map),
    );
    return res.fold((f) => Err(f), (_) => const Success(true));
  }

  static AppNotification _fromJson(Map<String, dynamic> json) {
    final categoryRaw =
        json['category'] as String? ?? json['type'] as String? ?? 'system';
    final category = NotificationCategory.values.firstWhere(
      (c) => c.name == categoryRaw,
      orElse: () => NotificationCategory.system,
    );
    final readAt = json['readAt'] ?? json['read_at'];
    final isRead =
        json['isRead'] as bool? ??
        json['read'] as bool? ??
        (readAt != null && readAt.toString().isNotEmpty);
    return AppNotification(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? json['message'] as String? ?? '',
      category: category,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      isRead: isRead,
    );
  }

  Future<Result<T>> _apiNotConfigured<T>() async =>
      const Err(ServerFailure('Live API client is not configured.'));
}
