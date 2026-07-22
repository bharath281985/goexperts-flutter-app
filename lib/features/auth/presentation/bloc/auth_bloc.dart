import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/subscription_status.dart';
import '../../../subscriptions/domain/repositories/subscription_repository.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Owns the authentication + onboarding lifecycle. The router redirects based
/// on this bloc's state (role → profile → subscription → dashboard).
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository, this._subscriptionRepository)
    : super(const AuthState()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthLoginRequested>(_onLogin);
    on<AuthSignupDraftSaved>(_onSignupDraft);
    on<AuthSocialLoginRequested>(_onSocial);
    on<AuthRoleSelected>(_onRole);
    on<AuthProfileCompleted>(_onProfile);
    on<AuthSubscriptionRefreshed>(_onSubscriptionRefresh);
    on<AuthSubscriptionActivated>(_onSubscriptionActivated);
    on<AuthUserUpdated>(_onUserUpdated);
    on<AuthLoggedOut>(_onLogout);
  }

  final AuthRepository _repository;
  final SubscriptionRepository _subscriptionRepository;

  Future<SubscriptionGateStatus> _fetchSubscriptionStatus(
    UserRole? role,
  ) async {
    if (role == null) return SubscriptionGateStatus.none;
    final result = await _subscriptionRepository.getSubscriptionStatus(role);
    return result.fold((_) => SubscriptionGateStatus.none, (status) => status);
  }

  SubscriptionGateStatus _statusFromUser(AppUser user) {
    switch (user.subscriptionStatus?.toLowerCase()) {
      case 'active':
        return SubscriptionGateStatus.active;
      case 'expired':
        return SubscriptionGateStatus.expired;
      case 'none':
        return SubscriptionGateStatus.none;
      default:
        return SubscriptionGateStatus.unknown;
    }
  }

  Future<void> _emitAuthenticated(
    Emitter<AuthState> emit,
    AppUser user, {
    bool clearPendingSignup = false,
  }) async {
    // Prefer live subscription endpoint; fall back to login/me payload.
    var subStatus = await _fetchSubscriptionStatus(user.role);
    final fromUser = _statusFromUser(user);
    if (subStatus == SubscriptionGateStatus.none &&
        fromUser == SubscriptionGateStatus.active) {
      subStatus = SubscriptionGateStatus.active;
    }

    final planRes = await _subscriptionRepository.getCurrentPlanId();
    final planId = planRes.valueOrNull ?? user.subscriptionPlan;
    emit(
      state.copyWith(
        isSubmitting: false,
        status: AuthStatus.authenticated,
        user: user,
        clearPendingSignup: clearPendingSignup,
        subscriptionStatus: subStatus,
        subscriptionPlanId: planId,
        clearError: true,
      ),
    );
  }

  Future<void> _onCheck(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.unknown));
    final result = await _repository.currentUser();
    if (result.isFailure) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return;
    }
    await _emitAuthenticated(emit, result.valueOrNull!);
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _repository.login(
      email: event.email,
      password: event.password,
    );
    if (result.isFailure) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: result.failureOrNull!.message,
        ),
      );
      return;
    }
    await _emitAuthenticated(emit, result.valueOrNull!);
  }

  Future<void> _onSignupDraft(
    AuthSignupDraftSaved event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        pendingSignup: SignupDraft(
          fullName: event.fullName,
          email: event.email,
          phone: event.phone,
          countryCode: event.countryCode,
          password: event.password,
        ),
        clearError: true,
      ),
    );
  }

  Future<void> _onSocial(
    AuthSocialLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _repository.socialLogin(
      event.provider,
      role: event.role,
    );
    if (result.isFailure) {
      final msg = result.failureOrNull!.message;
      if (msg.isEmpty) {
        emit(state.copyWith(isSubmitting: false));
        return;
      }
      emit(state.copyWith(isSubmitting: false, errorMessage: msg));
      return;
    }
    await _emitAuthenticated(emit, result.valueOrNull!);
  }

  Future<void> _onRole(AuthRoleSelected event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));

    if (state.pendingSignup != null) {
      final draft = state.pendingSignup!;
      final result = await _repository.signup(
        fullName: draft.fullName,
        email: draft.email,
        phone: draft.phone,
        countryCode: draft.countryCode,
        password: draft.password,
        role: event.role,
      );
      if (result.isFailure) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: result.failureOrNull!.message,
          ),
        );
        return;
      }
      await _emitAuthenticated(
        emit,
        result.valueOrNull!,
        clearPendingSignup: true,
      );
      return;
    }

    final result = await _repository.selectRole(event.role);
    if (result.isFailure) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: result.failureOrNull!.message,
        ),
      );
      return;
    }
    emit(state.copyWith(isSubmitting: false, user: result.valueOrNull));
  }

  Future<void> _onProfile(
    AuthProfileCompleted event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true),
    );
    final result = await _repository.completeProfile(
      event.data,
      avatarBytes: event.avatarBytes,
    );
    if (result.isFailure) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: result.failureOrNull!.message,
        ),
      );
      return;
    }

    final completion = result.valueOrNull!;
    final user = completion.user;
    final subStatus = await _fetchSubscriptionStatus(user.role);
    emit(
      state.copyWith(
        isSubmitting: false,
        user: user,
        subscriptionStatus: subStatus,
        successMessage: completion.message,
      ),
    );
  }

  Future<void> _onSubscriptionRefresh(
    AuthSubscriptionRefreshed event,
    Emitter<AuthState> emit,
  ) async {
    final subStatus = await _fetchSubscriptionStatus(state.user?.role);
    final planRes = await _subscriptionRepository.getCurrentPlanId();
    emit(
      state.copyWith(
        subscriptionStatus: subStatus,
        subscriptionPlanId: planRes.valueOrNull,
      ),
    );
  }

  Future<void> _onSubscriptionActivated(
    AuthSubscriptionActivated event,
    Emitter<AuthState> emit,
  ) async {
    // Unlock immediately so the router can leave SubscriptionSelectionPage.
    emit(state.copyWith(subscriptionStatus: SubscriptionGateStatus.active));

    // Persist locally so a later refresh/login does not bounce back here
    // when the free-plan API write is missing or delayed.
    final cached = await _repository.markSubscriptionActive(
      planId:
          state.user?.subscriptionPlan ?? state.subscriptionPlanId ?? 'free',
    );
    final planRes = await _subscriptionRepository.getCurrentPlanId();
    final planId = planRes.valueOrNull ?? state.subscriptionPlanId ?? 'free';
    final planLabel =
        cached.valueOrNull?.subscriptionPlan ??
        state.user?.subscriptionPlan ??
        'Starter';

    // Best-effort live status — never downgrade after an explicit activation.
    await _fetchSubscriptionStatus(state.user?.role);

    final user =
        cached.valueOrNull ??
        state.user?.copyWith(
          subscriptionStatus: 'active',
          subscriptionPlan: planLabel,
        );

    emit(
      state.copyWith(
        subscriptionStatus: SubscriptionGateStatus.active,
        subscriptionPlanId: planId,
        user: user,
      ),
    );
  }

  void _onUserUpdated(AuthUserUpdated event, Emitter<AuthState> emit) {
    emit(state.copyWith(user: event.user));
  }

  Future<void> _onLogout(AuthLoggedOut event, Emitter<AuthState> emit) async {
    await _repository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
