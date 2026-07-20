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
    this.businessPlanUrl,
    this.views = 0,
    this.investorInterests = 0,
    this.isSaved = false,
    this.isFollowing = false,
    this.isVerified = true,
    this.hasInvested = false,
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
  final String? businessPlanUrl;
  final int views;
  final int investorInterests;
  final bool isSaved;
  final bool isFollowing;
  final bool isVerified;
  final bool hasInvested;
  final List<String> tags;

  double get fundingProgress =>
      fundingRequired == 0 ? 0 : (fundingRaised / fundingRequired).clamp(0, 1);

  Startup copyWith({
    bool? isSaved,
    bool? isFollowing,
    bool? hasInvested,
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
    businessPlanUrl: businessPlanUrl,
    views: views ?? this.views,
    investorInterests: investorInterests ?? this.investorInterests,
    isSaved: isSaved ?? this.isSaved,
    isFollowing: isFollowing ?? this.isFollowing,
    isVerified: isVerified,
    hasInvested: hasInvested ?? this.hasInvested,
    tags: tags,
  );

  factory Startup.fromApiJson(Map<String, dynamic> json) {
    final dynamic founderField =
        json['founderProfile'] ?? json['founder_profile'] ?? json['founder'];
    final Map<String, dynamic>? profile = (founderField is Map)
        ? Map<String, dynamic>.from(founderField)
        : null;

    final String? explicitFounderId = (founderField is String)
        ? founderField
        : null;

    final id = json['id']?.toString() ?? '';
    print("Startup fromApiJson JSON payload: $json");

    final name =
        json['startup']?.toString() ??
        json['name']?.toString() ??
        profile?['startupName']?.toString() ??
        json['fullName']?.toString() ??
        'Startup';
    final tagline =
        json['tagline']?.toString() ??
        profile?['tagline']?.toString() ??
        json['bio']?.toString() ??
        '';
    final industry =
        json['industry']?.toString() ??
        profile?['industry']?.toString() ??
        'General';
    final stage =
        json['stage']?.toString() ?? profile?['stage']?.toString() ?? 'MVP';
    final founderName =
        json['founderName']?.toString() ??
        profile?['fullName']?.toString() ??
        profile?['name']?.toString() ??
        json['fullName']?.toString() ??
        'Founder';

    final fundingRequired =
        (json['fundingRequired'] as num?)?.toDouble() ??
        (json['funding'] as num?)?.toDouble() ??
        (profile?['raised'] as num?)?.toDouble() ??
        (profile?['fundingRequired'] as num?)?.toDouble() ??
        0.0;

    final equityOffered =
        (json['equityOffered'] as num?)?.toDouble() ??
        (json['equity'] as num?)?.toDouble() ??
        (profile?['equityOffered'] as num?)?.toDouble() ??
        0.0;

    final city = json['city'] as String? ?? profile?['city'] as String?;
    final country =
        json['country'] as String? ?? profile?['country'] as String?;
    String location =
        json['location'] as String? ?? profile?['location'] as String? ?? 'N/A';
    if (json['location'] == null && profile?['location'] == null) {
      if (city != null && country != null) {
        location = '$city, $country';
      } else if (city != null) {
        location = city;
      } else if (country != null) {
        location = country;
      }
    }

    final logoUrl =
        json['logoUrl'] as String? ??
        json['logo'] as String? ??
        json['avatarUrl'] as String? ??
        profile?['logoUrl'] as String?;
    final coverUrl =
        json['coverUrl'] as String? ??
        json['coverimage'] as String? ??
        profile?['coverUrl'] as String?;
    final founderAvatar =
        profile?['avatarUrl'] as String? ??
        json['founderAvatar'] as String? ??
        json['avatarUrl'] as String? ??
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
      founderId:
          json['founderId']?.toString() ??
          explicitFounderId ??
          profile?['id']?.toString() ??
          '',
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
          (json['valuation'] as num?)?.toDouble() ??
          (profile?['valuation'] as num?)?.toDouble() ??
          (profile?['raised'] as num?)?.toDouble() ??
          0.0,
      fundingRaised:
          (json['fundingRaised'] as num?)?.toDouble() ??
          (profile?['fundingRaised'] as num?)?.toDouble() ??
          (profile?['raised'] as num?)?.toDouble() ??
          0.0,
      pitchDeckUrl:
          json['pitchDeck'] as String? ??
          json['pitchDeckUrl'] as String? ??
          json['pitchDisk'] as String? ??
          profile?['pitchDeckUrl'] as String? ??
          profile?['pitchDisk'] as String?,
      businessPlanUrl:
          json['businessPlan'] as String? ??
          json['businessPlanUrl'] as String? ??
          json['Businessplan'] as String? ??
          profile?['businessPlanUrl'] as String? ??
          profile?['Businessplan'] as String?,
      views:
          (json['views'] as num?)?.toInt() ??
          (profile?['views'] as num?)?.toInt() ??
          0,
      investorInterests:
          (json['interestedInvestors'] as num?)?.toInt() ??
          (json['investorInterests'] as num?)?.toInt() ??
          (profile?['investorInterests'] as num?)?.toInt() ??
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
      hasInvested:
          toBool(json['hasInvested']) ||
          toBool(profile?['hasInvested']) ||
          toBool(json['has_invested']) ||
          toBool(profile?['has_invested']),
      tags:
          (json['tags'] as List?)?.map((e) => e.toString()).toList() ??
          (profile?['tags'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
    );
  }

  @override
  List<Object?> get props => [
    id,
    founderId,
    isSaved,
    isFollowing,
    hasInvested,
    pitchDeckUrl,
    businessPlanUrl,
  ];
}
