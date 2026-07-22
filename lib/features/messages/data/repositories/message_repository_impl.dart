import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/config/app_config.dart';
import '../../../../core/auth/token_role_helper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/file_upload_helper.dart';
import '../../../../core/realtime/chat_socket_service.dart';
import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/enums.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  MessageRepositoryImpl([
    this._api,
    this._tokenRoleHelper,
    this._uploader,
    this._socket,
  ]);

  final ApiClientHelper? _api;
  final TokenRoleHelper? _tokenRoleHelper;
  final FileUploadHelper? _uploader;
  final ChatSocketService? _socket;

  static const _cacheKey = 'cached_conversations_v1';
  static const _maxAttachmentBytes = 10 * 1024 * 1024;

  Future<UserRole?> _role() =>
      _tokenRoleHelper?.resolve() ?? Future.value(null);

  Future<String?> _userId() => _tokenRoleHelper?.userId() ?? Future.value(null);

  Future<Result<T>> _firstSuccess<T>(
    List<Future<Result<T>> Function()> attempts,
  ) async {
    Result<T>? last;
    for (final attempt in attempts) {
      final result = await attempt();
      if (result.isSuccess) return result;
      last = result;
    }
    return last ??
        const Err(ServerFailure('Live API client is not configured.'));
  }

  @override
  Future<List<Conversation>> getCachedConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null || raw.isEmpty) return const [];
      final list = jsonDecode(raw) as List;
      return list
          .whereType<Map>()
          .map((e) => _conversationFromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _saveCache(List<Conversation> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        items
            .map(
              (c) => {
                'id': c.id,
                'name': c.name,
                'msg': c.lastMessage,
                'time': c.lastMessageAt.toIso8601String(),
                'avatar': c.avatarUrl,
                'unread': c.unreadCount,
                'online': c.isOnline,
                'typing': c.isTyping,
                'role': c.role,
              },
            )
            .toList(),
      );
      await prefs.setString(_cacheKey, encoded);
    } catch (_) {
      /* ignore cache errors */
    }
  }

  @override
  Future<Result<Paginated<Conversation>>> getConversations(
    QueryParams params,
  ) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();

    final role = await _role();
    final path = (role == UserRole.freelancer)
        ? ApiEndpoints.freelancerMessages
        : (role == UserRole.client)
        ? ApiEndpoints.clientMessagesConversations
        : (role == UserRole.investor)
        ? ApiEndpoints.investorMessagesConversations
        : (role == UserRole.founder)
        ? ApiEndpoints.founderMessagesConversations
        : ApiEndpoints.chatConversations;

    final result = await _firstSuccess<List<Conversation>>([
      () => _api.getEnvelope<List<Conversation>>(
        path,
        query: params.toApiQuery(),
        parser: (envelope) =>
            ApiResponse.parseList(envelope.data, _conversationFromJson),
      ),
      if (role == UserRole.freelancer)
        () => _api.getEnvelope<List<Conversation>>(
          ApiEndpoints.chatConversations,
          query: params.toApiQuery(),
          parser: (envelope) =>
              ApiResponse.parseList(envelope.data, _conversationFromJson),
        ),
    ]);

    final list = result.valueOrNull;
    if (list == null) {
      return result.fold(
        (f) => Err(f),
        (_) => const Err(ServerFailure('Empty')),
      );
    }
    await _saveCache(list);
    return Success(
      Paginated(
        items: list,
        page: params.page,
        totalPages: 1,
        totalItems: list.length,
      ),
    );
  }

  @override
  Future<Result<List<ChatMessage>>> getMessages(String conversationId) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();

    final role = await _role();
    final path = (role == UserRole.client)
        ? ApiEndpoints.clientMessageConversation(conversationId)
        : (role == UserRole.freelancer)
        ? ApiEndpoints.freelancerMessage(conversationId)
        : (role == UserRole.investor)
        ? '/chat/conversations/$conversationId'
        : (role == UserRole.founder)
        ? '/chat/conversations/$conversationId'
        : ApiEndpoints.chatConversation(conversationId);

    final userId = await _userId();
    return _firstSuccess<List<ChatMessage>>([
      () => _api.getEnvelope<List<ChatMessage>>(
        path,
        parser: (envelope) => ApiResponse.parseList(
          envelope.data,
          (json) => _chatMessageFromJson(json, userId),
        ),
      ),
      if (role == UserRole.client || role == UserRole.freelancer)
        () => _api.getEnvelope<List<ChatMessage>>(
          ApiEndpoints.chatConversation(conversationId),
          parser: (envelope) => ApiResponse.parseList(
            envelope.data,
            (json) => _chatMessageFromJson(json, userId),
          ),
        ),
    ]);
  }

  @override
  Future<Result<ChatMessage>> sendMessage(
    String conversationId,
    String text, {
    String? attachmentUrl,
  }) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();

    final role = await _role();
    final path = (role == UserRole.freelancer)
        ? ApiEndpoints.freelancerMessages
        : (role == UserRole.client)
        ? ApiEndpoints.clientMessagesSend
        : (role == UserRole.investor)
        ? ApiEndpoints.investorMessagesSend
        : (role == UserRole.founder)
        ? ApiEndpoints.founderMessagesSend
        : ApiEndpoints.chatSend;

    final userId = await _userId();
    final body = <String, dynamic>{
      'conversationId': conversationId,
      if (text.trim().isNotEmpty) 'text': text.trim(),
      if (attachmentUrl != null && attachmentUrl.isNotEmpty)
        'attachmentUrl': attachmentUrl,
    };
    return _firstSuccess<ChatMessage>([
      () => _api.post<ChatMessage>(
        path,
        body: body,
        parser: (data) => _chatMessageFromJson(
          Map<String, dynamic>.from(data as Map),
          userId,
        ),
        allowNullData: false,
      ),
      if (role == UserRole.client || role == UserRole.freelancer)
        () => _api.post<ChatMessage>(
          ApiEndpoints.chatSend,
          body: body,
          parser: (data) => _chatMessageFromJson(
            Map<String, dynamic>.from(data as Map),
            userId,
          ),
          allowNullData: false,
        ),
    ]);
  }

  @override
  Future<Result<ChatMessage>> startChat({
    required String recipientId,
    String? text,
    String? projectId,
  }) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();

    final role = await _role();
    final path = (role == UserRole.freelancer)
        ? ApiEndpoints.freelancerMessages
        : (role == UserRole.client)
        ? ApiEndpoints.clientMessagesSend
        : (role == UserRole.investor)
        ? ApiEndpoints.investorMessagesSend
        : (role == UserRole.founder)
        ? ApiEndpoints.founderMessagesSend
        : ApiEndpoints.chatSend;

    final trimmed = text?.trim() ?? '';

    final body = <String, dynamic>{
      'recipientId': recipientId,
      // Empty text = open conversation only (no default auto-message).
      'text': trimmed,
      if (projectId != null && projectId.isNotEmpty) 'projectId': projectId,
    };

    final userId = await _userId();
    return _firstSuccess<ChatMessage>([
      () => _api.post<ChatMessage>(
        path,
        body: body,
        parser: (data) => _chatMessageFromJson(
          Map<String, dynamic>.from(data as Map),
          userId,
        ),
        allowNullData: false,
      ),
      if (role == UserRole.client || role == UserRole.freelancer)
        () => _api.post<ChatMessage>(
          ApiEndpoints.chatSend,
          body: body,
          parser: (data) => _chatMessageFromJson(
            Map<String, dynamic>.from(data as Map),
            userId,
          ),
          allowNullData: false,
        ),
    ]);
  }

  @override
  Future<Result<String>> uploadChatAttachment(String filePath) async {
    if (AppConfig.useMockData || _api == null || _uploader == null) {
      return _apiNotConfigured();
    }
    final file = File(filePath);
    if (!await file.exists()) {
      return const Err(ValidationFailure('File not found on device.'));
    }
    final size = await file.length();
    if (size > _maxAttachmentBytes) {
      return const Err(
        ValidationFailure('File too large. Maximum size is 10MB.'),
      );
    }

    final role = await _role();
    final endpoint = role == UserRole.client
        ? ApiEndpoints.clientMessagesAttachments
        : ApiEndpoints.chatAttachments;

    final upload = await _uploader.uploadUrl(
      path: filePath,
      endpoint: endpoint,
    );
    if (upload.isSuccess || role != UserRole.client) return upload;
    return _uploader.uploadUrl(
      path: filePath,
      endpoint: ApiEndpoints.chatAttachments,
    );
  }

  @override
  Future<Result<bool>> markMessageRead(String messageId) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final role = await _role();
    final path = role == UserRole.client
        ? ApiEndpoints.clientMessageRead(messageId)
        : ApiEndpoints.chatMessageRead(messageId);
    return _firstSuccess<bool>([
      () => _api.patchAction(path),
      if (role == UserRole.client)
        () => _api.patchAction(ApiEndpoints.chatMessageRead(messageId)),
    ]);
  }

  @override
  Future<Result<bool>> markConversationRead(String conversationId) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final role = await _role();
    final path = role == UserRole.client
        ? '${ApiEndpoints.clientMessagesConversations}/$conversationId/read-all'
        : '${ApiEndpoints.chatConversations}/$conversationId/read-all';
    return _firstSuccess<bool>([
      () => _api.patchAction(path),
      if (role == UserRole.client)
        () => _api.patchAction(
          '${ApiEndpoints.chatConversations}/$conversationId/read-all',
        ),
    ]);
  }

  @override
  Future<Result<bool>> markConversationUnread(String conversationId) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final role = await _role();
    final path = role == UserRole.client
        ? '${ApiEndpoints.clientMessagesConversations}/$conversationId/unread'
        : '${ApiEndpoints.chatConversations}/$conversationId/unread';
    return _firstSuccess<bool>([
      () => _api.patchAction(path),
      if (role == UserRole.client)
        () => _api.patchAction(
          '${ApiEndpoints.chatConversations}/$conversationId/unread',
        ),
    ]);
  }

  @override
  Future<Result<bool>> deleteMessage(String messageId) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final role = await _role();
    final path = role == UserRole.client
        ? '/client/messages/$messageId'
        : role == UserRole.freelancer
        ? ApiEndpoints.freelancerMessage(messageId)
        : '/chat/messages/$messageId';
    return _firstSuccess<bool>([
      () => _api.deleteAction(path),
      if (role == UserRole.client || role == UserRole.freelancer)
        () => _api.deleteAction('/chat/messages/$messageId'),
    ]);
  }

  @override
  Future<Result<bool>> deleteConversation(String conversationId) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final role = await _role();
    final path = role == UserRole.client
        ? '${ApiEndpoints.clientMessagesConversations}/$conversationId'
        : '${ApiEndpoints.chatConversations}/$conversationId';
    return _firstSuccess<bool>([
      () => _api.deleteAction(path),
      if (role == UserRole.client)
        () => _api.deleteAction(
          '${ApiEndpoints.chatConversations}/$conversationId',
        ),
    ]);
  }

  @override
  Stream<ChatMessage> incomingMessages(String conversationId) {
    final socket = _socket;
    if (socket == null) {
      return const Stream<ChatMessage>.empty();
    }
    socket.joinConversation(conversationId);
    return socket.messages
        .where((raw) {
          final cid =
              raw['conversationId']?.toString() ??
              raw['conversation_id']?.toString() ??
              '';
          if (cid != conversationId) return false;
          // Ignore delivery/read status envelopes without message body.
          if (raw['event'] == 'delivered' || raw['event'] == 'read') {
            return false;
          }
          final id = raw['id']?.toString() ?? '';
          return id.isNotEmpty;
        })
        .asyncMap((raw) async {
          final userId = await _userId();
          return _chatMessageFromJson(raw, userId);
        });
  }

  @override
  void leaveConversation(String conversationId) {
    _socket?.leaveConversation(conversationId);
  }

  Future<Result<T>> _apiNotConfigured<T>() async =>
      const Err(ServerFailure('Live API client is not configured.'));

  static Conversation _conversationFromJson(Map<String, dynamic> json) {
    final messages =
        (json['messages'] as List?)
            ?.whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        const [];

    final last = messages.isNotEmpty ? messages.first : null;

    final lastText =
        json['msg'] as String? ??
        last?['text'] as String? ??
        json['lastMessage'] as String? ??
        '';
    final lastTimeRaw =
        json['time'] as String? ??
        last?['time'] as String? ??
        last?['createdAt'] as String? ??
        '';

    return Conversation(
      id: json['id']?.toString() ?? '',
      name:
          json['name'] as String? ??
          json['participantName'] as String? ??
          'Chat',
      lastMessage: lastText,
      lastMessageAt:
          DateTime.tryParse(lastTimeRaw) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      avatarUrl: json['avatar'] as String? ?? json['avatarUrl'] as String?,
      unreadCount: (json['unread'] as num?)?.toInt() ?? 0,
      isOnline: json['online'] as bool? ?? false,
      isPinned: false,
      isMuted: false,
      isTyping: json['typing'] as bool? ?? false,
      role: json['role']?.toString() ?? '',
    );
  }

  static ChatMessage _chatMessageFromJson(
    Map<String, dynamic> json,
    String? currentUserId,
  ) {
    final from = json['from']?.toString() ?? '';
    final senderId =
        json['senderId']?.toString() ?? json['sender_id']?.toString();
    final explicitMine = json['isMine'] as bool?;
    final isMine =
        explicitMine ??
        (from == 'me' ||
            (currentUserId != null &&
                senderId != null &&
                senderId.isNotEmpty &&
                senderId == currentUserId));

    final timeRaw =
        json['time'] as String? ?? json['createdAt'] as String? ?? '';

    final status = (json['readAt'] != null || json['isRead'] == true)
        ? MessageStatus.seen
        : (json['isDelivered'] as bool?) == true
        ? MessageStatus.delivered
        : MessageStatus.sent;

    final attachmentUrl =
        json['attachmentUrl'] as String? ?? json['attachment_url'] as String?;
    final text = json['text'] as String? ?? json['message'] as String? ?? '';

    MessageType type = MessageType.text;
    if (attachmentUrl != null && attachmentUrl.isNotEmpty) {
      final lower = attachmentUrl.toLowerCase();
      if (lower.contains('.mp4') ||
          lower.contains('.mov') ||
          lower.contains('.webm') ||
          lower.contains('video')) {
        type = MessageType.video;
      } else if (lower.contains('.jpg') ||
          lower.contains('.jpeg') ||
          lower.contains('.png') ||
          lower.contains('.gif') ||
          lower.contains('.webp') ||
          lower.contains('image')) {
        type = MessageType.image;
      } else {
        type = MessageType.document;
      }
    }

    return ChatMessage(
      id: json['id']?.toString() ?? '',
      conversationId:
          json['conversationId']?.toString() ??
          json['conversation_id']?.toString() ??
          '',
      senderId: isMine ? 'me' : (senderId ?? 'them'),
      text: text,
      sentAt: DateTime.tryParse(timeRaw) ?? DateTime.now(),
      type: type,
      status: status,
      isMine: isMine,
      attachmentUrl: attachmentUrl,
      replyTo: json['replyTo'] as String? ?? json['reply_to'] as String?,
    );
  }
}
