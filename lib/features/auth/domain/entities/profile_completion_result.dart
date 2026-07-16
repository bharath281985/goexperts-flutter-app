import '../entities/app_user.dart';

class ProfileCompletionResult {
  const ProfileCompletionResult({
    required this.user,
    required this.message,
  });

  final AppUser user;
  final String message;
}
