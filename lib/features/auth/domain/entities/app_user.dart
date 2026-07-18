import 'package:equatable/equatable.dart';
import '../../../../core/utils/enums.dart';

/// Authenticated user across all roles.
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.countryCode,
    this.role,
    this.avatarUrl,
    this.isVerified = false,
    this.isProfileComplete = false,
    this.subscriptionPlan,
    this.subscriptionStatus,
    this.headline,
    this.location,
  });

  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? countryCode;
  final UserRole? role;
  final String? avatarUrl;
  final bool isVerified;
  final bool isProfileComplete;
  final String? subscriptionPlan;

  /// Backend gate: `active` | `expired` | `none` (optional until login/me returns it).
  final String? subscriptionStatus;
  final String? headline;
  final String? location;

  AppUser copyWith({
    String? fullName,
    UserRole? role,
    String? avatarUrl,
    bool? isVerified,
    bool? isProfileComplete,
    String? subscriptionPlan,
    String? subscriptionStatus,
    String? headline,
    String? location,
    String? phone,
    String? countryCode,
  }) {
    return AppUser(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      headline: headline ?? this.headline,
      location: location ?? this.location,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      AppUser.fromApiJson(json);

  /// Parses API user payloads (camelCase or snake_case).
  static final _uuidPattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  static String? _readablePlan(String? value) {
    final v = value?.trim();
    if (v == null || v.isEmpty || _uuidPattern.hasMatch(v)) return null;
    return v;
  }

  factory AppUser.fromApiJson(Map<String, dynamic> json) {
    String? str(String camel, String snake) =>
        json[camel] as String? ?? json[snake] as String?;
    bool flag(String camel, String snake) =>
        json[camel] as bool? ?? json[snake] as bool? ?? false;

    final profileCompletion =
        json['profileCompletion'] as int? ??
        json['profile_completion'] as int? ??
        0;
    final roleRaw = str('role', 'role');

    final city = str('city', 'city');
    final country = str('country', 'country');
    final locationParts = [
      city,
      country,
    ].whereType<String>().where((s) => s.isNotEmpty);
    final joinedLocation = locationParts.isEmpty
        ? null
        : locationParts.join(', ');

    return AppUser(
      id: str('id', 'id') ?? '',
      fullName: str('fullName', 'full_name') ?? '',
      email: str('email', 'email') ?? '',
      phone: str('phone', 'phone'),
      countryCode: str('countryCode', 'country_code'),
      role: roleRaw != null ? UserRole.fromString(roleRaw) : null,
      avatarUrl: str('avatarUrl', 'avatar_url'),
      isVerified: flag('isVerified', 'is_verified'),
      isProfileComplete:
          flag('isProfileComplete', 'is_profile_complete') ||
          profileCompletion >= 80,
      // Prefer human-readable plan name; never store raw plan UUIDs.
      subscriptionPlan:
          _readablePlan(str('subscriptionPlan', 'subscription_plan')) ??
          _readablePlan(
            str('subscriptionPlanName', 'subscription_plan_name'),
          ) ??
          _readablePlan(str('subscriptionPlanId', 'subscription_plan_id')),
      subscriptionStatus: str('subscriptionStatus', 'subscription_status'),
      headline: str('headline', 'headline') ?? str('bio', 'bio'),
      location: str('location', 'location') ?? joinedLocation,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'email': email,
    'phone': phone,
    'country_code': countryCode,
    'role': role?.apiValue,
    'avatar_url': avatarUrl,
    'is_verified': isVerified,
    'is_profile_complete': isProfileComplete,
    'subscription_plan': subscriptionPlan,
    'subscription_status': subscriptionStatus,
    'headline': headline,
    'location': location,
  };

  @override
  List<Object?> get props => [
    id,
    email,
    phone,
    countryCode,
    role,
    isVerified,
    isProfileComplete,
    subscriptionPlan,
    subscriptionStatus,
  ];
}
