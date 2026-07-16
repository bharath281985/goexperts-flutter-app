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

  Startup copyWith({bool? isSaved, bool? isFollowing}) => Startup(
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
        logoUrl: logoUrl,
        coverUrl: coverUrl,
        problem: problem,
        solution: solution,
        businessModel: businessModel,
        revenueModel: revenueModel,
        marketSize: marketSize,
        valuation: valuation,
        fundingRaised: fundingRaised,
        pitchDeckUrl: pitchDeckUrl,
        views: views,
        investorInterests: investorInterests,
        isSaved: isSaved ?? this.isSaved,
        isFollowing: isFollowing ?? this.isFollowing,
        isVerified: isVerified,
        tags: tags,
      );

  @override
  List<Object?> get props => [id, isSaved, isFollowing];
}
