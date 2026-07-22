part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.email, required this.password});
  final String email;
  final String password;
  @override
  List<Object?> get props => [email, password];
}

/// Saves signup form locally and navigates to role selection (no API call yet).
class AuthSignupDraftSaved extends AuthEvent {
  const AuthSignupDraftSaved({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.countryCode,
    required this.password,
  });
  final String fullName;
  final String email;
  final String phone;
  final String countryCode;
  final String password;
  @override
  List<Object?> get props => [fullName, email, phone, countryCode, password];
}

class AuthSocialLoginRequested extends AuthEvent {
  const AuthSocialLoginRequested({required this.provider, required this.role});
  final String provider;
  final UserRole role;
  @override
  List<Object?> get props => [provider, role];
}

class AuthRoleSelected extends AuthEvent {
  const AuthRoleSelected(this.role);
  final UserRole role;
  @override
  List<Object?> get props => [role];
}

class AuthProfileCompleted extends AuthEvent {
  const AuthProfileCompleted(this.data, {this.avatarBytes});
  final Map<String, dynamic> data;
  final List<int>? avatarBytes;
  @override
  List<Object?> get props => [data, avatarBytes];
}

/// Re-validates subscription from backend after plan selection or renewal.
class AuthSubscriptionRefreshed extends AuthEvent {
  const AuthSubscriptionRefreshed();
}

/// Optimistically marks subscription as active (e.g. after free plan success),
/// then refreshes from the API.
class AuthSubscriptionActivated extends AuthEvent {
  const AuthSubscriptionActivated();
}

/// Patches the in-memory authenticated user after a profile edit.
class AuthUserUpdated extends AuthEvent {
  const AuthUserUpdated(this.user);
  final AppUser user;
  @override
  List<Object?> get props => [user];
}

class AuthLoggedOut extends AuthEvent {
  const AuthLoggedOut();
}

/// Refreshes the user profile from the remote API in the background.
class AuthProfileRefreshed extends AuthEvent {
  const AuthProfileRefreshed();
}
