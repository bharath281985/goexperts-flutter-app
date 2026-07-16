import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/result.dart';
import '../entities/conversation.dart';

abstract class MessageRepository {
  Future<Result<Paginated<Conversation>>> getConversations(QueryParams params);

  /// Instant cache for Messages tab (no network).
  Future<List<Conversation>> getCachedConversations();

  Future<Result<List<ChatMessage>>> getMessages(String conversationId);
  Future<Result<ChatMessage>> sendMessage(
    String conversationId,
    String text, {
    String? attachmentUrl,
  });
  Future<Result<ChatMessage>> startChat({
    required String recipientId,
    String? text,
    String? projectId,
  });
  Future<Result<String>> uploadChatAttachment(String filePath);
  Future<Result<bool>> markMessageRead(String messageId);
  Future<Result<bool>> markConversationRead(String conversationId);
  Future<Result<bool>> markConversationUnread(String conversationId);
  Future<Result<bool>> deleteMessage(String messageId);
  Future<Result<bool>> deleteConversation(String conversationId);

  /// Realtime stream stub. A concrete impl will bind this to the configured
  /// [RealtimeProvider] (Socket.IO / Supabase / Firebase / Pusher / Ably).
  Stream<ChatMessage> incomingMessages(String conversationId);

  /// Leave a conversation room (Socket.IO). No-op when offline.
  void leaveConversation(String conversationId);
}
