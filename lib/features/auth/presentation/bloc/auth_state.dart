part of 'auth_bloc.dart';

/// Holds signup form data until role is selected and register API is called.
class SignupDraft extends Equatable {
  const SignupDraft({
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

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isSubmitting = false,
    this.errorMessage,
    this.pendingSignup,
    this.subscriptionStatus = SubscriptionGateStatus.unknown,
    this.subscriptionPlanId,
    this.successMessage,
  });

  final AuthStatus status;
  final AppUser? user;
  final bool isSubmitting;
  final String? errorMessage;
  final SignupDraft? pendingSignup;
  final SubscriptionGateStatus subscriptionStatus;
  final String? subscriptionPlanId;
  final String? successMessage;

  bool get hasRole => user?.role != null;
  bool get isProfileComplete => user?.isProfileComplete ?? false;
  bool get hasSubscription => subscriptionStatus == SubscriptionGateStatus.active;
  bool get needsSubscription => !hasSubscription;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    bool? isSubmitting,
    String? errorMessage,
    SignupDraft? pendingSignup,
    bool clearPendingSignup = false,
    SubscriptionGateStatus? subscriptionStatus,
    String? subscriptionPlanId,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      pendingSignup: clearPendingSignup ? null : (pendingSignup ?? this.pendingSignup),
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionPlanId: subscriptionPlanId ?? this.subscriptionPlanId,
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        user,
        isSubmitting,
        errorMessage,
        pendingSignup,
        subscriptionStatus,
        subscriptionPlanId,
        successMessage,
      ];
}
