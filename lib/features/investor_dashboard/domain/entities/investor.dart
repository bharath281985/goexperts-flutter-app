import 'package:equatable/equatable.dart';
import '../../../../core/utils/enums.dart';

/// An investor profile discovered by founders.
class Investor extends Equatable {
  const Investor({
    required this.id,
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
    this.partnerRole = 'Sleeping Partner',
    this.stagePreferences = const ['Seed', 'Series A'],
    this.dealsCount = 0,
    this.portfolioCount = 0,
    this.isVerified = true,
    this.isFollowing = false,
    this.isSaved = false,
  });

  final String id;
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

  @override
  List<Object?> get props => [id, isFollowing, isSaved];
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

  double get roi =>
      investedAmount == 0 ? 0 : ((currentValue - investedAmount) / investedAmount) * 100;

  @override
  List<Object?> get props => [id, currentValue];
}
