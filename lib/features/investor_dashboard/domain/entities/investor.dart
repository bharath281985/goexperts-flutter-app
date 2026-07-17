import 'package:equatable/equatable.dart';
import '../../../../core/utils/enums.dart';

/// An investor profile discovered by founders.
class Investor extends Equatable {
  const Investor({
    required this.id,
    this.investorId = '',
    required this.name,
    required this.investorType,
    required this.company,
    required this.location,
    required this.minInvestment,
    required this.maxInvestment,
    required this.interestedIndustries,
    this.avatarUrl,
    this.coverUrl,
    this.bio = '',
    this.partnerRole = '',
    this.stagePreferences = const ['Seed', 'Series A'],
    this.dealsCount = 0,
    this.portfolioCount = 0,
    this.isVerified = true,
    this.isFollowing = false,
    this.isSaved = false,
  });

  final String id;
  final String investorId;
  final String name;
  final String investorType;
  final String company;
  final String location;
  final double minInvestment;
  final double maxInvestment;
  final List<String> interestedIndustries;
  final String? avatarUrl;
  final String? coverUrl;
  final String bio;
  final String partnerRole;
  final List<String> stagePreferences;
  final int dealsCount;
  final int portfolioCount;
  final bool isVerified;
  final bool isFollowing;
  final bool isSaved;

  Investor copyWith({bool? isFollowing, bool? isSaved}) => Investor(
    id: id,
    investorId: investorId,
    name: name,
    investorType: investorType,
    company: company,
    location: location,
    minInvestment: minInvestment,
    maxInvestment: maxInvestment,
    interestedIndustries: interestedIndustries,
    avatarUrl: avatarUrl,
    coverUrl: coverUrl,
    bio: bio,
    partnerRole: partnerRole,
    stagePreferences: stagePreferences,
    dealsCount: dealsCount,
    portfolioCount: portfolioCount,
    isVerified: isVerified,
    isFollowing: isFollowing ?? this.isFollowing,
    isSaved: isSaved ?? this.isSaved,
  );

  factory Investor.fromApiJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? profile =
        (json['investorProfile'] ?? json['investor_profile']) != null
        ? Map<String, dynamic>.from(
            (json['investorProfile'] ?? json['investor_profile']) as Map,
          )
        : null;

    final id = (json['id']?.toString() ?? '');
    final profileId =
        (profile?['id']?.toString() ?? json['investorId']?.toString() ?? '')
            ;
    final name =
        json['fullName']?.toString() ?? json['name']?.toString() ?? 'Investor';
    final bio = json['bio']?.toString() ?? '';
    final avatarUrl = json['avatarUrl'] as String?;

    final country = json['country'] as String?;
    final city = json['city'] as String?;
    String location = 'N/A';
    if (city != null && country != null) {
      location = '$city, $country';
    } else if (city != null) {
      location = city;
    } else if (country != null) {
      location = country;
    }

    final ticketMin =
        (profile?['ticketMin'] as num?)?.toDouble() ??
        (json['minInvestment'] as num?)?.toDouble() ??
        0.0;
    final ticketMax =
        (profile?['ticketMax'] as num?)?.toDouble() ??
        (json['maxInvestment'] as num?)?.toDouble() ??
        0.0;
    final company =
        profile?['firm']?.toString() ?? json['company']?.toString() ?? '';

    final focusAreasStr = profile?['focusAreas']?.toString() ?? '';
    List<String> interestedIndustries = const [];
    if (focusAreasStr.isNotEmpty) {
      interestedIndustries = focusAreasStr
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (json['interestedIndustries'] is List) {
      interestedIndustries = (json['interestedIndustries'] as List)
          .map((e) => e.toString())
          .toList();
    }

    final role = json['role']?.toString() ?? '';
    final focusAreasStrForType = profile?['focusAreas']?.toString() ?? '';
    final investorType = focusAreasStrForType.trim().isNotEmpty
        ? focusAreasStrForType
        : 'All';

    final isVerified =
        json['isVerified'] as bool? ?? json['verified'] as bool? ?? false;
    final isFollowing = json['isFollowing'] as bool? ?? false;
    final isSaved = json['isSaved'] as bool? ?? false;

    return Investor(
      id: id,
      investorId: profileId,
      name: name,
      investorType: investorType,
      company: company,
      location: location,
      minInvestment: ticketMin,
      maxInvestment: ticketMax,
      interestedIndustries: interestedIndustries,
      avatarUrl: avatarUrl,
      bio: bio,
      partnerRole: role,
      dealsCount: (profile?['deals'] as num?)?.toInt() ?? 0,
      portfolioCount: 0,
      isVerified: isVerified,
      isFollowing: isFollowing,
      isSaved: isSaved,
    );
  }

  @override
  List<Object?> get props => [id, investorId, isFollowing, isSaved];
}

/// A deal / investment opportunity in the pipeline.
class Deal extends Equatable {
  const Deal({
    required this.id,
    required this.startupName,
    required this.founderName,
    required this.stage,
    required this.amount,
    required this.equity,
    required this.status,
    required this.updatedAt,
    this.startupLogo,
    this.hasNda = false,
    this.documentsCount = 0,
  });

  final String id;
  final String startupName;
  final String founderName;
  final String stage;
  final double amount;
  final double equity;
  final EntityStatus status;
  final DateTime updatedAt;
  final String? startupLogo;
  final bool hasNda;
  final int documentsCount;

  @override
  List<Object?> get props => [id, status];
}

/// A holding in the investor's portfolio.
class PortfolioItem extends Equatable {
  const PortfolioItem({
    required this.id,
    required this.startupName,
    required this.investedAmount,
    required this.currentValue,
    required this.equity,
    required this.investedAt,
    this.logoUrl,
  });

  final String id;
  final String startupName;
  final double investedAmount;
  final double currentValue;
  final double equity;
  final DateTime investedAt;
  final String? logoUrl;

  double get roi => investedAmount == 0
      ? 0
      : ((currentValue - investedAmount) / investedAmount) * 100;

  @override
  List<Object?> get props => [id, currentValue];
}
