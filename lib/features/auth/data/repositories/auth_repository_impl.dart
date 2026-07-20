import '../../../../app/config/app_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/realtime/chat_socket_service.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/profile_completion_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/social_auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this._remote,
    required this._secureStorage,
    required this._localStorage,
    this._socialAuth,
    this._chatSocket,
  });

  final AuthRemoteDatasource? _remote;
  final SecureStorage _secureStorage;
  final LocalStorage _localStorage;
  final SocialAuthService? _socialAuth;
  final ChatSocketService? _chatSocket;

  AuthRemoteDatasource get _api {
    final remote = _remote;
    if (remote == null) {
      throw StateError('AuthRemoteDatasource not configured');
    }
    return remote;
  }

  Future<void> _cacheUser(AppUser user) {
    return _localStorage.setJson(LocalStorage.kCachedUser, user.toJson());
  }

  AppUser? _readCachedUser() {
    final json = _localStorage.getJson(LocalStorage.kCachedUser);
    if (json == null) return null;
    return AppUser.fromApiJson(json);
  }

  AppUser _mergeWithCachedCompletion(AppUser remote) {
    final cached = _readCachedUser();
    if (cached == null || cached.id != remote.id) return remote;

    var merged = remote;
    if (!remote.isProfileComplete && cached.isProfileComplete) {
      merged = merged.copyWith(isProfileComplete: true);
    }

    final remoteSub = remote.subscriptionStatus?.toLowerCase();
    final cachedSub = cached.subscriptionStatus?.toLowerCase();
    if ((remoteSub == null || remoteSub == 'none') && cachedSub == 'active') {
      merged = merged.copyWith(
        subscriptionStatus: 'active',
        subscriptionPlan: cached.subscriptionPlan ?? remote.subscriptionPlan,
      );
    }
    return merged;
  }

  @override
  Future<Result<AppUser>> markSubscriptionActive({String? planId}) async {
    if (AppConfig.useMockData) {
      return _mockModeDisabled();
    }

    AppUser? current = _readCachedUser();
    if (current == null) {
      try {
        current = await _api.getMe();
      } catch (e) {
        return Err(_mapError(e));
      }
    }

    final uuidPattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    final incoming = planId?.trim();
    final readablePlan =
        (incoming != null &&
            incoming.isNotEmpty &&
            !uuidPattern.hasMatch(incoming))
        ? incoming
        : (current.subscriptionPlan != null &&
              !uuidPattern.hasMatch(current.subscriptionPlan!))
        ? current.subscriptionPlan
        : 'Starter';

    final updated = current.copyWith(
      subscriptionStatus: 'active',
      subscriptionPlan: readablePlan,
    );
    await _cacheUser(updated);
    return Success(updated);
  }

  @override
  Future<Result<String>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (AppConfig.useMockData) {
      return const Success('Password changed successfully');
    }
    try {
      final message = await _api.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return Success(message);
    } catch (e) {
      return Err(_mapError(e));
    }
  }

  @override
  Future<Result<AppUser>> login({
    required String email,
    required String password,
  }) async {
    if (AppConfig.useMockData) {
      return _mockModeDisabled();
    }
    try {
      final user = await _api.login(email: email, password: password);
      final merged = _mergeWithCachedCompletion(user);
      await _cacheUser(merged);
      await _chatSocket?.connect();
      return Success(merged);
    } catch (e) {
      return Err(_mapError(e));
    }
  }

  @override
  Future<Result<AppUser>> signup({
    required String fullName,
    required String email,
    required String phone,
    required String countryCode,
    required String password,
    required UserRole role,
  }) async {
    if (AppConfig.useMockData) {
      return _mockModeDisabled();
    }
    try {
      final user = await _api.signup(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        countryCode: countryCode,
        role: role,
      );
      await _cacheUser(user);
      await _chatSocket?.connect();
      return Success(user);
    } catch (e) {
      return Err(_mapError(e));
    }
  }

  @override
  Future<Result<AppUser>> socialLogin(
    String provider, {
    required UserRole role,
  }) async {
    if (AppConfig.useMockData) {
      return _mockModeDisabled();
    }
    final social = _socialAuth;
    if (social == null) {
      return const Err(ServerFailure('Social login is not configured.'));
    }
    try {
      final SocialAuthResult credentials;
      switch (provider) {
        case 'google':
          credentials = await social.signInWithGoogle();
        case 'apple':
          credentials = await social.signInWithApple();
        default:
          return Err(ServerFailure('Unsupported provider: $provider'));
      }
      final user = await _api.socialLogin(
        endpoint: social.endpointForProvider(provider),
        role: role,
        idToken: credentials.idToken,
        accessToken: credentials.accessToken,
        email: credentials.email,
        fullName: credentials.fullName,
      );
      final merged = _mergeWithCachedCompletion(user);
      await _cacheUser(merged);
      await _chatSocket?.connect();
      return Success(merged);
    } on SocialAuthCancelledException {
      return const Err(UnknownFailure(''));
    } catch (e) {
      return Err(_mapError(e));
    }
  }

  @override
  Future<Result<bool>> sendOtp({
    required String phone,
    required String countryCode,
  }) async {
    if (AppConfig.useMockData) return _mockModeDisabled();
    try {
      await _api.sendOtp(phone: phone, countryCode: countryCode);
      return const Success(true);
    } catch (e) {
      return Err(_mapError(e));
    }
  }

  @override
  Future<Result<bool>> verifyOtp({
    required String code,
    String? phone,
    String? countryCode,
  }) async {
    if (AppConfig.useMockData) return _mockModeDisabled();
    try {
      await _api.verifyOtp(code: code, phone: phone, countryCode: countryCode);
      return const Success(true);
    } catch (e) {
      return Err(_mapError(e));
    }
  }

  @override
  Future<Result<bool>> forgotPassword(String email) async {
    if (AppConfig.useMockData) return _mockModeDisabled();
    try {
      await _api.forgotPassword(email);
      return const Success(true);
    } catch (e) {
      return Err(_mapError(e));
    }
  }

  @override
  Future<Result<AppUser>> selectRole(UserRole role) async {
    if (AppConfig.useMockData) {
      return _mockModeDisabled();
    }
    try {
      final result = await _api.updateProfile({'role': role.apiValue});
      await _cacheUser(result.user);
      return Success(result.user);
    } catch (e) {
      return Err(_mapError(e));
    }
  }

  @override
  Future<Result<ProfileCompletionResult>> completeProfile(
    Map<String, dynamic> data, {
    List<int>? avatarBytes,
  }) async {
    if (AppConfig.useMockData) {
      return _mockModeDisabled();
    }
    try {
      if (avatarBytes != null && avatarBytes.isNotEmpty) {
        await _api.uploadAvatarBytes(avatarBytes);
      }
      final result = await _api.updateProfile(data);
      await _cacheUser(result.user);
      return Success(result);
    } catch (e) {
      return Err(_mapError(e));
    }
  }

  @override
  Future<Result<AppUser>> currentUser() async {
    if (AppConfig.useMockData) {
      return _mockModeDisabled();
    }
    final token = await _secureStorage.accessToken;
    if (token == null || token.isEmpty) {
      return const Err(AuthFailure('No active session'));
    }
    try {
      final remote = await _api.getMe();
      final merged = _mergeWithCachedCompletion(remote);
      await _cacheUser(merged);
      await _chatSocket?.connect();
      return Success(merged);
    } catch (e) {
      final cached = _readCachedUser();
      if (cached != null) {
        return Success(cached);
      }
      return Err(_mapError(e));
    }
  }

  @override
  Future<void> updateCachedUser(AppUser user) async {
    await _cacheUser(user);
  }

  @override
  Future<void> logout() async {
    if (AppConfig.useMockData) {
      return;
    }
    try {
      await _api.logout();
    } catch (_) {
      await _secureStorage.deleteAll();
    }
    await _chatSocket?.disconnect();
    await _localStorage.remove(LocalStorage.kCachedUser);
  }

  Failure _mapError(Object e) {
    if (e is ServerException) {
      return ServerFailure(e.message, code: e.code, errorCode: e.errorCode);
    }
    final msg = e.toString().replaceFirst('Exception: ', '');
    return ServerFailure(msg);
  }

  Future<Result<T>> _mockModeDisabled<T>() async =>
      const Err(ServerFailure('Live API data is required for this screen.'));
}
