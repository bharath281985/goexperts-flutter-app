import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../app/config/app_config.dart';
import '../storage/secure_storage.dart';

/// Production Socket.IO client for chat/presence.
/// REST polling remains the fallback when this service is disconnected.
class ChatSocketService {
  ChatSocketService(this._secureStorage);

  final SecureStorage _secureStorage;
  io.Socket? _socket;
  bool _connecting = false;
  final Set<String> _joinedConversations = {};

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _presenceController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _statusController = StreamController<bool>.broadcast();

  Stream<Map<String, dynamic>> get messages => _messageController.stream;
  Stream<Map<String, dynamic>> get typing => _typingController.stream;
  Stream<Map<String, dynamic>> get presence => _presenceController.stream;
  Stream<bool> get connectionStatus => _statusController.stream;
  bool get isConnected => _socket?.connected == true;

  Future<void> connect() async {
    if (AppConfig.realtimeProvider != RealtimeProvider.socketIo) return;
    if (_socket?.connected == true || _connecting) return;

    final token = await _secureStorage.accessToken;
    if (token == null || token.isEmpty) return;

    _connecting = true;
    try {
      await disconnect(emitStatus: false);

      final socket = io.io(
        AppConfig.socketUrl,
        io.OptionBuilder()
            .setTransports(['polling', 'websocket'])
            .disableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(12)
            .setReconnectionDelay(1500)
            .setAuth({'token': token})
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .build(),
      );

      socket.onConnect((_) {
        _statusController.add(true);
        for (final id in _joinedConversations) {
          socket.emit('conversation:join', {'conversationId': id});
        }
      });
      socket.onDisconnect((_) => _statusController.add(false));
      socket.onConnectError((err) {
        debugPrint('Socket connect error: $err');
        _statusController.add(false);
      });
      socket.on('message:new', (data) {
        final map = _asMap(data);
        if (map != null) _messageController.add(map);
      });
      socket.on('typing:start', (data) {
        final map = _asMap(data);
        if (map != null) {
          map['typing'] = true;
          _typingController.add(map);
        }
      });
      socket.on('typing:stop', (data) {
        final map = _asMap(data);
        if (map != null) {
          map['typing'] = false;
          _typingController.add(map);
        }
      });
      socket.on('presence:update', (data) {
        final map = _asMap(data);
        if (map != null) {
          map['online'] = map['isOnline'] == true;
          _presenceController.add(map);
        }
      });
      socket.on('presence:online', (data) {
        final map = _asMap(data);
        if (map != null) {
          map['online'] = true;
          _presenceController.add(map);
        }
      });
      socket.on('presence:offline', (data) {
        final map = _asMap(data);
        if (map != null) {
          map['online'] = false;
          _presenceController.add(map);
        }
      });
      socket.on('message:delivered', (data) {
        final map = _asMap(data);
        if (map != null) {
          map['event'] = 'delivered';
          _messageController.add(map);
        }
      });
      socket.on('message:read', (data) {
        final map = _asMap(data);
        if (map != null) {
          map['event'] = 'read';
          _messageController.add(map);
        }
      });

      _socket = socket;
      socket.connect();
    } finally {
      _connecting = false;
    }
  }

  /// Reconnect with a freshly refreshed access token.
  Future<void> reconnectWithToken() async {
    await disconnect(emitStatus: false);
    await connect();
  }

  Future<void> disconnect({bool emitStatus = true}) async {
    final socket = _socket;
    _socket = null;
    if (socket != null) {
      socket.clearListeners();
      socket.disconnect();
      socket.dispose();
    }
    if (emitStatus) _statusController.add(false);
  }

  void joinConversation(String conversationId) {
    if (conversationId.isEmpty) return;
    _joinedConversations.add(conversationId);
    _socket?.emit('conversation:join', {'conversationId': conversationId});
  }

  void leaveConversation(String conversationId) {
    _joinedConversations.remove(conversationId);
    _socket?.emit('conversation:leave', {'conversationId': conversationId});
  }

  void emitTypingStart({required String conversationId, String? recipientId}) {
    _socket?.emit('typing:start', {
      'conversationId': conversationId,
      if (recipientId != null) 'recipientId': recipientId,
    });
  }

  void emitTypingStop({required String conversationId, String? recipientId}) {
    _socket?.emit('typing:stop', {
      'conversationId': conversationId,
      if (recipientId != null) 'recipientId': recipientId,
    });
  }

  void emitDelivered({
    required String messageId,
    required String conversationId,
    required String senderId,
  }) {
    _socket?.emit('message:delivered', {
      'messageId': messageId,
      'conversationId': conversationId,
      'senderId': senderId,
    });
  }

  void emitRead({
    required String messageId,
    required String conversationId,
    required String senderId,
  }) {
    _socket?.emit('message:read', {
      'messageId': messageId,
      'conversationId': conversationId,
      'senderId': senderId,
    });
  }

  Map<String, dynamic>? _asMap(dynamic data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  Future<void> dispose() async {
    await disconnect();
    await _messageController.close();
    await _typingController.close();
    await _presenceController.close();
    await _statusController.close();
  }
}
