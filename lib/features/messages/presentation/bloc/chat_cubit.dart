import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/enums.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/message_repository.dart';

import '../../../../core/utils/result.dart';

class ChatState extends Equatable {
  const ChatState({
    this.status = ViewStatus.initial,
    this.messages = const [],
    this.peerTyping = false,
    this.uploading = false,
  });
  final ViewStatus status;
  final List<ChatMessage> messages;
  final bool peerTyping;
  final bool uploading;

  ChatState copyWith({
    ViewStatus? status,
    List<ChatMessage>? messages,
    bool? peerTyping,
    bool? uploading,
  }) => ChatState(
    status: status ?? this.status,
    messages: messages ?? this.messages,
    peerTyping: peerTyping ?? this.peerTyping,
    uploading: uploading ?? this.uploading,
  );

  @override
  List<Object?> get props => [status, messages, peerTyping, uploading];
}

/// Chat controller. `incomingMessages` binds to the realtime transport
/// (Socket.IO / Supabase / Firebase / Pusher / Ably) once wired.
class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._repository, this.conversationId) : super(const ChatState()) {
    _convoId = conversationId;
  }

  final MessageRepository _repository;
  final String conversationId;
  late String _convoId;
  StreamSubscription<ChatMessage>? _sub;
  Timer? _pollTimer;

  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading));
    var result = await _repository.getMessages(_convoId);

    if (result.isFailure) {
      final failure = result.failureOrNull;
      final isNewChat =
          failure != null &&
          (failure.message.contains('404') ||
              failure.message.contains('not found') ||
              failure.message.contains('NOT_FOUND') ||
              failure.message.contains('400') ||
              failure.message.contains('Record not found'));
      if (isNewChat) {
        final startResult = await _repository.startChat(recipientId: _convoId);
        if (startResult.isSuccess) {
          final starter = startResult.valueOrNull;
          if (starter != null && starter.conversationId.isNotEmpty) {
            _convoId = starter.conversationId;
            result = await _repository.getMessages(_convoId);
          } else {
            result = const Success([]);
          }
        } else {
          result = const Success([]);
        }
      }
    }

    result.fold(
      (_) => emit(state.copyWith(status: ViewStatus.failure)),
      (messages) =>
          emit(state.copyWith(status: ViewStatus.success, messages: messages)),
    );
    await _repository.markConversationRead(_convoId);

    _subscribeToMessages();
    _startPolling();
  }

  void _subscribeToMessages() {
    _sub?.cancel();
    _sub = _repository.incomingMessages(_convoId).listen((msg) {
      if (msg.id.isEmpty) return;
      if (state.messages.any((m) => m.id == msg.id)) return;
      emit(state.copyWith(messages: [...state.messages, msg]));
    });
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      final next = await _repository.getMessages(_convoId);
      next.fold((_) {}, (messages) {
        if (messages.length != state.messages.length ||
            messages.map((m) => m.id).join() !=
                state.messages.map((m) => m.id).join()) {
          emit(state.copyWith(messages: messages));
        }
      });
    });
  }

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;
    final result = await _repository.sendMessage(_convoId, text.trim());
    final msg = result.valueOrNull;
    if (msg != null) {
      if (msg.id.isNotEmpty && state.messages.any((m) => m.id == msg.id)) {
        return;
      }
      emit(state.copyWith(messages: [...state.messages, msg]));
    }
  }

  Future<String?> sendAttachment(String filePath) async {
    emit(state.copyWith(uploading: true));
    final upload = await _repository.uploadChatAttachment(filePath);
    final url = upload.valueOrNull;
    if (url == null || url.isEmpty) {
      emit(state.copyWith(uploading: false));
      return upload.fold((f) => f.message, (_) => 'Upload failed');
    }
    final result = await _repository.sendMessage(
      _convoId,
      '',
      attachmentUrl: url,
    );
    emit(state.copyWith(uploading: false));
    final msg = result.valueOrNull;
    if (msg != null) {
      if (msg.id.isEmpty || !state.messages.any((m) => m.id == msg.id)) {
        emit(state.copyWith(messages: [...state.messages, msg]));
      }
      return null;
    }
    return result.fold((f) => f.message, (_) => 'Failed to send attachment');
  }

  Future<void> deleteMessage(String messageId) async {
    final result = await _repository.deleteMessage(messageId);
    if (result.valueOrNull == true) {
      emit(
        state.copyWith(
          messages: state.messages.where((m) => m.id != messageId).toList(),
        ),
      );
    }
  }

  Future<void> markMessageRead(String messageId) async {
    await _repository.markMessageRead(messageId);
    final updated = state.messages
        .map(
          (m) => m.id == messageId
              ? ChatMessage(
                  id: m.id,
                  conversationId: m.conversationId,
                  senderId: m.senderId,
                  text: m.text,
                  sentAt: m.sentAt,
                  type: m.type,
                  status: MessageStatus.seen,
                  isMine: m.isMine,
                  attachmentUrl: m.attachmentUrl,
                  replyTo: m.replyTo,
                )
              : m,
        )
        .toList();
    emit(state.copyWith(messages: updated));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    _pollTimer?.cancel();
    _repository.leaveConversation(_convoId);
    return super.close();
  }
}
