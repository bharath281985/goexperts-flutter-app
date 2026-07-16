import 'package:equatable/equatable.dart';

/// A review left on a profile / project / service.
class Review extends Equatable {
  const Review({
    required this.id,
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.authorAvatar,
    this.context = '',
    this.reply,
  });

  final String id;
  final String authorName;
  final String? authorAvatar;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String context;
  final String? reply;

  @override
  List<Object?> get props => [id, rating];
}

/// A portfolio item shown on freelancer/founder profiles.
class PortfolioEntry extends Equatable {
  const PortfolioEntry({
    required this.id,
    required this.title,
    required this.category,
    this.imageUrl,
    this.description = '',
    this.link,
  });

  final String id;
  final String title;
  final String category;
  final String? imageUrl;
  final String description;
  final String? link;

  @override
  List<Object?> get props => [id];
}
