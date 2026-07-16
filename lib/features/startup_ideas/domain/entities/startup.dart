import 'package:equatable/equatable.dart';

/// A startup created by a founder and discovered by investors.
class Startup extends Equatable {
  const Startup({
    required this.id,
    required this.name,
    required this.tagline,
    required this.industry,
    required this.stage,
    required this.founderName,
    required this.fundingRequired,
    required this.equityOffered,
    required this.location,
    this.founderId,
    this.logoUrl,
    this.coverUrl,
    this.founderAvatar,
    this.problem = '',
    this.solution = '',
    this.businessModel = '',
    this.revenueModel = '',
    this.marketSize = '',
    this.valuation = 0,
    this.fundingRaised = 0,
    this.pitchDeckUrl,
    this.views = 0,
    this.investorInterests = 0,
    this.isSaved = false,
    this.isFollowing = false,
    this.isVerified = true,
    this.tags = const [],
  });

  final String id;
  final String? founderId;
  final String name;
  final String tagline;
  final String industry;
  final String stage;
  final String founderName;
  final String? founderAvatar;
  final double fundingRequired;
  final double equityOffered;
  final String location;
  final String? logoUrl;
  final String? coverUrl;
  final String problem;
  final String solution;
  final String businessModel;
  final String revenueModel;
  final String marketSize;
  final double valuation;
  final double fundingRaised;
  final String? pitchDeckUrl;
  final int views;
  final int investorInterests;
  final bool isSaved;
  final bool isFollowing;
  final bool isVerified;
  final List<String> tags;

  double get fundingProgress =>
      fundingRequired == 0 ? 0 : (fundingRaised / fundingRequired).clamp(0, 1);

  Startup copyWith({
    bool? isSaved,
    bool? isFollowing,
    int? investorInterests,
    int? views,
    double? fundingRaised,
    String? founderId,
  }) => Startup(
    id: id,
    name: name,
    tagline: tagline,
    industry: industry,
    stage: stage,
    founderName: founderName,
    founderAvatar: founderAvatar,
    fundingRequired: fundingRequired,
    equityOffered: equityOffered,
    location: location,
    founderId: founderId ?? this.founderId,
    logoUrl: logoUrl,
    coverUrl: coverUrl,
    problem: problem,
    solution: solution,
    businessModel: businessModel,
    revenueModel: revenueModel,
    marketSize: marketSize,
    valuation: valuation,
    fundingRaised: fundingRaised ?? this.fundingRaised,
    pitchDeckUrl: pitchDeckUrl,
    views: views ?? this.views,
    investorInterests: investorInterests ?? this.investorInterests,
    isSaved: isSaved ?? this.isSaved,
    isFollowing: isFollowing ?? this.isFollowing,
    isVerified: isVerified,
    tags: tags,
  );

  factory Startup.fromApiJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? profile =
        (json['founderProfile'] ?? json['founder_profile']) != null
        ? Map<String, dynamic>.from(
            (json['founderProfile'] ?? json['founder_profile']) as Map,
          )
        : null;

    final id = json['id']?.toString() ?? '';
    print("Startup fromApiJson JSON payload: $json");

    final name =
        profile?['startupName']?.toString() ??
        json['name']?.toString() ??
        json['fullName']?.toString() ??
        'Startup';
    final tagline =
        profile?['tagline']?.toString() ??
        json['tagline']?.toString() ??
        json['bio']?.toString() ??
        '';
    final industry =
        profile?['industry']?.toString() ??
        json['industry']?.toString() ??
        'General';
    final stage =
        profile?['stage']?.toString() ?? json['stage']?.toString() ?? 'MVP';
    final founderName =
        json['fullName']?.toString() ??
        json['founderName']?.toString() ??
        'Founder';

    final fundingRequired =
        (profile?['raised'] as num?)?.toDouble() ??
        (profile?['fundingRequired'] as num?)?.toDouble() ??
        (json['fundingRequired'] as num?)?.toDouble() ??
        0.0;

    final equityOffered =
        (profile?['equityOffered'] as num?)?.toDouble() ??
        (json['equityOffered'] as num?)?.toDouble() ??
        0.0;

    final city = json['city'] as String?;
    final country = json['country'] as String?;
    String location =
        profile?['location'] as String? ?? json['location'] as String? ?? 'N/A';
    if (profile?['location'] == null && json['location'] == null) {
      if (city != null && country != null) {
        location = '$city, $country';
      } else if (city != null) {
        location = city;
      } else if (country != null) {
        location = country;
      }
    }

    final logoUrl =
        json['avatarUrl'] as String? ??
        json['logoUrl'] as String? ??
        profile?['logoUrl'] as String?;
    final coverUrl =
        json['coverUrl'] as String? ?? profile?['coverUrl'] as String?;
    final founderAvatar =
        json['avatarUrl'] as String? ??
        json['founderAvatar'] as String? ??
        profile?['founderAvatar'] as String?;

    bool toBool(dynamic val) {
      if (val == null) return false;
      if (val is bool) return val;
      if (val is num) return val != 0;
      if (val is String) {
        final s = val.trim().toLowerCase();
        return s == 'true' || s == '1' || s == 'yes';
      }
      return false;
    }

    return Startup(
      id: id,
      name: name,
      tagline: tagline,
      industry: industry,
      stage: stage,
      founderName: founderName,
      fundingRequired: fundingRequired,
      equityOffered: equityOffered,
      location: location,
      founderId: profile?['id']?.toString() ?? json['id']?.toString(),
      logoUrl: logoUrl,
      coverUrl: coverUrl,
      founderAvatar: founderAvatar,
      problem:
          profile?['problem'] as String? ?? json['problem'] as String? ?? '',
      solution:
          profile?['solution'] as String? ?? json['solution'] as String? ?? '',
      businessModel:
          profile?['businessModel'] as String? ??
          json['businessModel'] as String? ??
          '',
      revenueModel:
          profile?['revenueModel'] as String? ??
          json['revenueModel'] as String? ??
          '',
      marketSize:
          profile?['marketSize'] as String? ??
          json['marketSize'] as String? ??
          '',
      valuation:
          (profile?['valuation'] as num?)?.toDouble() ??
          (profile?['raised'] as num?)?.toDouble() ??
          (json['valuation'] as num?)?.toDouble() ??
          0.0,
      fundingRaised:
          (profile?['fundingRaised'] as num?)?.toDouble() ??
          (profile?['raised'] as num?)?.toDouble() ??
          (json['fundingRaised'] as num?)?.toDouble() ??
          0.0,
      pitchDeckUrl:
          profile?['pitchDeckUrl'] as String? ??
          json['pitchDeckUrl'] as String?,
      views:
          (profile?['views'] as num?)?.toInt() ??
          (json['views'] as num?)?.toInt() ??
          0,
      investorInterests:
          (profile?['investorInterests'] as num?)?.toInt() ??
          (json['investorInterests'] as num?)?.toInt() ??
          0,
      isSaved:
          toBool(json['isSaved']) ||
          toBool(profile?['isSaved']) ||
          toBool(json['is_saved']) ||
          toBool(profile?['is_saved']),
      isFollowing:
          toBool(json['isFollowing']) ||
          toBool(profile?['isFollowing']) ||
          toBool(json['is_following']) ||
          toBool(profile?['is_following']),
      isVerified:
          toBool(json['isVerified']) ||
          toBool(json['verified']) ||
          toBool(profile?['isVerified']) ||
          toBool(profile?['verified']),
      tags:
          (json['tags'] as List?)?.map((e) => e.toString()).toList() ??
          (profile?['tags'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
    );
  }

  @override
  List<Object?> get props => [id, founderId, isSaved, isFollowing];
}
