import '../../../../core/errors/failures.dart';
import '../../../../app/config/app_config.dart';
import '../../../../core/auth/token_role_helper.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/subscription_status.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl([this._api, this._tokenRoleHelper]);

  final ApiClientHelper? _api;
  final TokenRoleHelper? _tokenRoleHelper;

  Future<UserRole?> _role([UserRole? override]) async =>
      override ?? await _tokenRoleHelper?.resolve();

  String _plansPath(UserRole? role) {
    switch (role) {
      case UserRole.client:
        return '/client/subscriptions/plans';
      case UserRole.investor:
        return '/investor/subscriptions/plans';
      case UserRole.founder:
        return ApiEndpoints.founderSubscriptionsPlans;
      case UserRole.freelancer:
      default:
        return ApiEndpoints.freelancerSubscriptionPlans;
    }
  }

  String _currentPath(UserRole? role) {
    switch (role) {
      case UserRole.client:
        return '/client/subscriptions/current';
      case UserRole.investor:
        return '/investor/subscriptions/current';
      case UserRole.founder:
        return ApiEndpoints.founderSubscriptionsCurrent;
      case UserRole.freelancer:
      default:
        return ApiEndpoints.freelancerSubscription;
    }
  }

  String _upgradePath(UserRole? role) {
    switch (role) {
      case UserRole.client:
        return '/client/subscriptions/upgrade';
      case UserRole.investor:
        return '/investor/subscriptions/purchase';
      case UserRole.founder:
        return '/founder/subscriptions/purchase';
      case UserRole.freelancer:
      default:
        return ApiEndpoints.freelancerSubscriptionUpgrade;
    }
  }

  String _renewPath(UserRole? role) {
    switch (role) {
      case UserRole.client:
        return '/client/subscriptions/renew';
      case UserRole.investor:
        return '/investor/subscriptions/renew';
      case UserRole.founder:
        return '/founder/subscriptions/renew';
      case UserRole.freelancer:
      default:
        return ApiEndpoints.freelancerSubscriptionRenew;
    }
  }

  String _cancelPath(UserRole? role) {
    switch (role) {
      case UserRole.client:
        return '/client/subscriptions/cancel';
      case UserRole.investor:
        return '/investor/subscriptions/cancel';
      case UserRole.founder:
        return '/founder/subscriptions/cancel';
      case UserRole.freelancer:
      default:
        return ApiEndpoints.freelancerSubscriptionCancel;
    }
  }

  @override
  Future<Result<List<SubscriptionPlan>>> getPlans() async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final role = await _role();
    return _api.get<List<SubscriptionPlan>>(
      _plansPath(role),
      parser: (raw) {
        if (raw is! List) return const <SubscriptionPlan>[];
        return raw
            .whereType<Map>()
            .map((e) => _fromJson(Map<String, dynamic>.from(e)))
            .toList();
      },
    );
  }

  @override
  Future<Result<String?>> getCurrentPlanId() async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final role = await _role();
    final res = await _api.getEnvelope<Map<String, dynamic>?>(
      _currentPath(role),
      parser: (envelope) {
        final data = envelope.data;
        if (data == null) return null;
        if (data is Map<String, dynamic>) {
          return data;
        }
        return null;
      },
    );
    return res.fold((f) => Err(f), (data) {
      if (data == null) return const Success<String?>(null);
      final status = data['status']?.toString().toLowerCase();
      if (status == 'none' || status == 'inactive') {
        return const Success<String?>(null);
      }
      return Success(
        data['planId']?.toString() ??
            (data['plan'] as Map?)?['id']?.toString() ??
            data['id']?.toString(),
      );
    });
  }

  @override
  Future<Result<SubscriptionGateStatus>> getSubscriptionStatus(
    UserRole role,
  ) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final res = await _api.getEnvelope<Map<String, dynamic>?>(
      _currentPath(role),
      parser: (envelope) {
        final data = envelope.data;
        if (data == null) return null;
        if (data is Map<String, dynamic>) return data;
        return null;
      },
    );
    return res.fold(
      (f) {
        if (f is NotFoundFailure) {
          return const Success(SubscriptionGateStatus.none);
        }
        return Err(f);
      },
      (data) {
        if (data == null || data.isEmpty) {
          return const Success(SubscriptionGateStatus.none);
        }
        final status = data['status']?.toString().toLowerCase();
        if (status == 'none' || status == 'inactive') {
          return const Success(SubscriptionGateStatus.none);
        }
        if (status == 'expired' ||
            status == 'cancelled' ||
            status == 'canceled') {
          return const Success(SubscriptionGateStatus.expired);
        }
        if (status == 'active' ||
            data['plan'] != null ||
            data['planId'] != null) {
          return const Success(SubscriptionGateStatus.active);
        }
        return const Success(SubscriptionGateStatus.none);
      },
    );
  }

  @override
  Future<Result<String>> subscribe(String planId, {bool yearly = false}) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final role = await _role();
    final billingCycle = yearly ? 'yearly' : 'monthly';

    Future<Result<String>> attempt(String id) async {
      final res = await _api.postEnvelope<({String message, Map<String, dynamic> data})>(
        _upgradePath(role),
        body: {'planId': id, 'billingCycle': billingCycle},
        parser: (envelope) {
          final raw = envelope.data;
          final data = raw is Map<String, dynamic>
              ? raw
              : raw is Map
                  ? Map<String, dynamic>.from(raw)
                  : <String, dynamic>{};
          return (
            message: envelope.message?.isNotEmpty == true
                ? envelope.message!
                : 'Starter plan activated successfully',
            data: data,
          );
        },
      );
      return res.fold(Err.new, (parsed) {
        if (parsed.data['requiresPayment'] == true) {
          return const Err(
            ValidationFailure('Payment is required for this plan'),
          );
        }
        return Success(parsed.message);
      });
    }

    final first = await attempt(planId);
    if (first.isSuccess) return first;

    // Mock id `free` may not exist on the server — retry with Starter alias.
    final key = planId.trim().toLowerCase();
    if (key == 'free' || key == 'starter') {
      final retry = await attempt('Starter');
      if (retry.isSuccess) return retry;
    }
    return first;
  }

  @override
  Future<Result<bool>> renew({bool yearly = false}) async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final role = await _role();
    return _api.postAction(
      _renewPath(role),
      body: {'billingCycle': yearly ? 'yearly' : 'monthly'},
    );
  }

  @override
  Future<Result<bool>> cancel() async {
    if (AppConfig.useMockData || _api == null) return _apiNotConfigured();
    final role = await _role();
    return _api.postAction(_cancelPath(role));
  }

  static SubscriptionPlan _fromJson(Map<String, dynamic> json) {
    final monthly =
        (json['priceMonthly'] as num?)?.toDouble() ??
        (json['monthlyPrice'] as num?)?.toDouble() ??
        (json['price'] as num?)?.toDouble() ??
        (json['amount'] as num?)?.toDouble() ??
        0;
    final yearly =
        (json['priceYearly'] as num?)?.toDouble() ??
        (json['yearlyPrice'] as num?)?.toDouble() ??
        (monthly * 10);

    List<String> features = const [];
    final rawFeatures = json['features'];
    if (rawFeatures is List) {
      features = rawFeatures.map((e) => e.toString()).toList();
    }

    return SubscriptionPlan(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Plan',
      priceMonthly: monthly,
      priceYearly: yearly,
      features: features,
      tagline: json['tagline'] as String? ?? '',
      isPopular: json['isPopular'] as bool? ??
          json['popular'] as bool? ??
          false,
    );
  }

  Future<Result<T>> _apiNotConfigured<T>() async =>
      const Err(ServerFailure('Live API client is not configured.'));
}
