import 'package:equatable/equatable.dart';

/// A chat conversation summary shown in the conversation list.
class Conversation extends Equatable {
  const Conversation({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastMessageAt,
    this.avatarUrl,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isPinned = false,
    this.isMuted = false,
    this.isTyping = false,
    this.role = '',
  });

  final String id;
  final String name;
  final String lastMessage;
  final DateTime lastMessageAt;
  final String? avatarUrl;
  final int unreadCount;
  final bool isOnline;
  final bool isPinned;
  final bool isMuted;
  final bool isTyping;
  final String role;

  @override
  List<Object?> get props => [id, unreadCount, isPinned, isMuted, lastMessageAt];
}

enum MessageType { text, image, video, document, voice, location }

enum MessageStatus { sending, sent, delivered, seen }

/// A single chat message. Fields align to a realtime (WebSocket) payload.
class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.sentAt,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    this.isMine = false,
    this.attachmentUrl,
    this.replyTo,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime sentAt;
  final MessageType type;
  final MessageStatus status;
  final bool isMine;
  final String? attachmentUrl;
  final String? replyTo;

  @override
  List<Object?> get props => [id, status];
}
