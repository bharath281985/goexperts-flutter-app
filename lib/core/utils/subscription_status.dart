/// Backend-validated subscription gate status.
enum SubscriptionGateStatus {
  unknown,
  active,
  expired,
  none;

  bool get allowsDashboard => this == SubscriptionGateStatus.active;
  bool get requiresPlansScreen => this == SubscriptionGateStatus.none;
  bool get requiresRenewalScreen => this == SubscriptionGateStatus.expired;
}
