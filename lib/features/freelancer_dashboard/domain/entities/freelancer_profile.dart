import 'package:equatable/equatable.dart';

class FreelancerProfile extends Equatable {
  const FreelancerProfile({
    required this.skills,
    required this.experience,
    required this.education,
    required this.languages,
    required this.hourlyRate,
    required this.bio,
    required this.availability,
    this.avatarUrl,
    this.resumeUrl,
  });

  final List<String> skills;
  final List<String> experience;
  final List<String> education;
  final List<String> languages;
  final double hourlyRate;
  final String bio;
  final String availability;
  final String? avatarUrl;
  final String? resumeUrl;

  factory FreelancerProfile.fromApiJson(Map<String, dynamic> json) {
    List<String> toStrings(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
      }
      if (raw is String && raw.isNotEmpty) {
        return raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      return const [];
    }

    return FreelancerProfile(
      skills: toStrings(json['skills']),
      experience: toStrings(json['experience']),
      education: toStrings(json['education']),
      languages: toStrings(json['languages']),
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ??
          (json['hourly_rate'] as num?)?.toDouble() ??
          0,
      bio: json['bio'] as String? ?? '',
      availability: json['availability'] as String? ?? '',
      avatarUrl: (json['user'] as Map?)?['avatarUrl'] as String? ??
          json['avatarUrl'] as String?,
      resumeUrl: json['resume'] as String? ?? json['resumeUrl'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        skills,
        experience,
        education,
        languages,
        hourlyRate,
        bio,
        availability,
        avatarUrl,
        resumeUrl,
      ];
}
