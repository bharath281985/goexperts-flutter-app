import 'package:equatable/equatable.dart';

/// A freelancer profile shown in discovery, cards and public profile pages.
class Freelancer extends Equatable {
  const Freelancer({
    required this.id,
    required this.name,
    required this.headline,
    required this.category,
    required this.skills,
    required this.hourlyRate,
    required this.rating,
    required this.reviewsCount,
    required this.location,
    this.avatarUrl,
    this.coverUrl,
    this.bio = '',
    this.experienceYears = 3,
    this.completedProjects = 0,
    this.isVerified = true,
    this.isAvailable = true,
    this.isSaved = false,
    this.isFollowing = false,
    this.languages = const ['English'],
    this.followers = 0,
    this.successRate = 96,
  });

  final String id;
  final String name;
  final String headline;
  final String category;
  final List<String> skills;
  final double hourlyRate;
  final double rating;
  final int reviewsCount;
  final String location;
  final String? avatarUrl;
  final String? coverUrl;
  final String bio;
  final int experienceYears;
  final int completedProjects;
  final bool isVerified;
  final bool isAvailable;
  final bool isSaved;
  final bool isFollowing;
  final List<String> languages;
  final int followers;
  final int successRate;

  Freelancer copyWith({bool? isSaved, bool? isFollowing}) => Freelancer(
        id: id,
        name: name,
        headline: headline,
        category: category,
        skills: skills,
        hourlyRate: hourlyRate,
        rating: rating,
        reviewsCount: reviewsCount,
        location: location,
        avatarUrl: avatarUrl,
        coverUrl: coverUrl,
        bio: bio,
        experienceYears: experienceYears,
        completedProjects: completedProjects,
        isVerified: isVerified,
        isAvailable: isAvailable,
        isSaved: isSaved ?? this.isSaved,
        isFollowing: isFollowing ?? this.isFollowing,
        languages: languages,
        followers: followers,
        successRate: successRate,
      );

  @override
  List<Object?> get props => [id, isSaved, isFollowing];
}
