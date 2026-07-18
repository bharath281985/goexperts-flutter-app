import '../../../../core/utils/enums.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/subscription_status.dart';
import '../entities/current_subscription.dart';
import '../entities/subscription_plan.dart';

abstract class SubscriptionRepository {
  Future<Result<List<SubscriptionPlan>>> getPlans();
  Future<Result<CurrentSubscription?>> getCurrentSubscription();
  Future<Result<String?>> getCurrentPlanId();
  Future<Result<SubscriptionGateStatus>> getSubscriptionStatus(UserRole role);

  /// Activates a free plan. Returns the API success message.
  Future<Result<String>> subscribe(String planId, {bool yearly});
  Future<Result<bool>> renew({bool yearly});
  Future<Result<bool>> cancel();
}
