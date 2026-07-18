import 'dart:convert';

import 'package:equatable/equatable.dart';

class CurrentSubscription extends Equatable {
  const CurrentSubscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.autoRenew,
    required this.plan,
  });

  final String id;
  final String userId;
  final String planId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final bool autoRenew;
  final CurrentSubscriptionPlan plan;

  bool get isActive => status.toLowerCase() == 'active';

  factory CurrentSubscription.fromApiJson(Map<String, dynamic> json) {
    final planRaw = json['plan'];
    return CurrentSubscription(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      planId: json['planId']?.toString() ?? '',
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? ''),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? ''),
      status: json['status']?.toString() ?? '',
      autoRenew: json['autoRenew'] == true,
      plan: CurrentSubscriptionPlan.fromApiJson(
        planRaw is Map ? Map<String, dynamic>.from(planRaw) : const {},
      ),
    );
  }

  @override
  List<Object?> get props => [id, planId, status, endDate, plan];
}

class CurrentSubscriptionPlan extends Equatable {
  const CurrentSubscriptionPlan({
    required this.id,
    required this.name,
    required this.role,
    required this.amount,
    required this.currency,
    required this.duration,
    required this.features,
    required this.limits,
  });

  final String id;
  final String name;
  final String role;
  final double amount;
  final String currency;
  final String duration;
  final List<String> features;
  final Map<String, dynamic> limits;

  factory CurrentSubscriptionPlan.fromApiJson(Map<String, dynamic> json) {
    return CurrentSubscriptionPlan(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Current plan',
      role: json['role']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? 'INR',
      duration: json['duration']?.toString() ?? '',
      features: _stringList(json['features']),
      limits: _map(json['limits']),
    );
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded
              .map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList();
        }
      } catch (_) {}
      return [raw];
    }
    return const [];
  }

  static Map<String, dynamic> _map(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return const {};
  }

  @override
  List<Object?> get props => [id, name, amount, duration];
}
