import 'package:equatable/equatable.dart';

/// A subscription plan offered to a role.
class SubscriptionPlan extends Equatable {
  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.priceMonthly,
    required this.priceYearly,
    required this.features,
    this.isPopular = false,
    this.tagline = '',
    this.duration = '',
    this.limits = const {},
  });

  final String id;
  final String name;
  final double priceMonthly;
  final double priceYearly;
  final List<String> features;
  final bool isPopular;
  final String tagline;
  final String duration;
  final Map<String, dynamic> limits;

  @override
  List<Object?> get props => [id, name, priceMonthly, duration, limits];
}
