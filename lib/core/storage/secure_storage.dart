import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted token and session storage.
class SecureStorage {
  SecureStorage([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  final FlutterSecureStorage _storage;

  static const kAccessToken = 'access_token';
  static const kRefreshToken = 'refresh_token';
  static const kUserId = 'user_id';
  static const kRole = 'user_role';

  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> delete(String key) => _storage.delete(key: key);

  Future<void> deleteAll() => _storage.deleteAll();

  Future<String?> get accessToken => read(kAccessToken);
  Future<void> saveAccessToken(String token) => write(kAccessToken, token);

  Future<String?> get refreshToken => read(kRefreshToken);
  Future<void> saveRefreshToken(String token) => write(kRefreshToken, token);

  Future<String?> get userId => read(kUserId);
  Future<String?> get role => read(kRole);

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    String? userId,
    String? role,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
    if (userId != null) await write(kUserId, userId);
    if (role != null) await write(kRole, role);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) =>
      saveSession(accessToken: accessToken, refreshToken: refreshToken);
}
