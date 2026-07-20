import 'dart:convert';

import '../storage/secure_storage.dart';
import '../utils/enums.dart';

/// Decodes the JWT payload client-side to figure out the current `UserRole`.
///
/// Note: This does not verify the signature (we only read non-sensitive
/// routing-related claims). The backend remains the source of truth.
class TokenRoleHelper {
  TokenRoleHelper(this._secureStorage);

  final SecureStorage _secureStorage;

  Future<UserRole?> resolve() async {
    final storedRole = await _secureStorage.role;
    if (storedRole != null && storedRole.isNotEmpty) {
      return UserRole.fromString(storedRole);
    }
    final token = await _secureStorage.accessToken;
    if (token == null || token.isEmpty) return null;
    return roleFromToken(token);
  }

  Future<String?> userId() async {
    final token = await _secureStorage.accessToken;
    if (token == null || token.isEmpty) return null;
    return idFromToken(token);
  }

  static UserRole? roleFromToken(String token) {
    final payload = _payload(token);
    if (payload == null) return null;
    final roleRaw = payload['role'];
    if (roleRaw is! String) return null;
    for (final r in UserRole.values) {
      if (r.name == roleRaw) return r;
    }
    return null;
  }

  static String? idFromToken(String token) {
    final payload = _payload(token);
    if (payload == null) return null;
    final id = payload['id'] ?? payload['userId'] ?? payload['sub'];
    return id?.toString();
  }

  static Map<String, dynamic>? _payload(String token) {
    final parts = token.split('.');
    if (parts.length < 2) return null;
    final payloadPart = parts[1];
    final normalized = payloadPart.replaceAll('-', '+').replaceAll('_', '/');
    try {
      final payloadBytes = base64Url.decode(normalized);
      return jsonDecode(utf8.decode(payloadBytes)) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
