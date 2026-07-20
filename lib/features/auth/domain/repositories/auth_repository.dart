import '../../../../core/utils/enums.dart';
import '../../../../core/utils/result.dart';
import '../entities/app_user.dart';
import '../entities/profile_completion_result.dart';

abstract class AuthRepository {
  Future<Result<AppUser>> login({
    required String email,
    required String password,
  });
  Future<Result<AppUser>> signup({
    required String fullName,
    required String email,
    required String phone,
    required String countryCode,
    required String password,
    required UserRole role,
  });
  Future<Result<AppUser>> socialLogin(
    String provider, {
    required UserRole role,
  });
  Future<Result<bool>> sendOtp({
    required String phone,
    required String countryCode,
  });
  Future<Result<bool>> verifyOtp({
    required String code,
    String? phone,
    String? countryCode,
  });
  Future<Result<bool>> forgotPassword(String email);
  Future<Result<AppUser>> selectRole(UserRole role);
  Future<Result<ProfileCompletionResult>> completeProfile(
    Map<String, dynamic> data, {
    List<int>? avatarBytes,
  });

  /// Persists a local "subscription active" flag so Skip / free activation
  /// survives router refreshes and re-login when the API has not caught up.
  Future<Result<AppUser>> markSubscriptionActive({String? planId});

  Future<Result<String>> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<Result<AppUser>> currentUser();
  Future<void> updateCachedUser(AppUser user);
  Future<void> logout();
}
