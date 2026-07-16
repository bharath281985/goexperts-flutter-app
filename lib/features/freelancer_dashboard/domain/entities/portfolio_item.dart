import 'package:equatable/equatable.dart';

class PortfolioItem extends Equatable {
  const PortfolioItem({
    required this.id,
    required this.title,
    required this.description,
    this.projectUrl,
    this.technologies = const [],
    this.role = '',
    this.category = '',
    this.completionDate,
    this.responseMessage,
  });

  final String id;
  final String title;
  final String description;
  final String? projectUrl;
  final List<String> technologies;
  final String role;
  final String category;
  final DateTime? completionDate;
  final String? responseMessage;

  factory PortfolioItem.fromApiJson(
    Map<String, dynamic> json, {
    String? responseMessage,
  }) {
    return PortfolioItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? 'Portfolio item',
      description: json['description'] as String? ?? '',
      projectUrl: json['projectUrl'] as String? ?? json['url'] as String?,
      technologies: (json['technologies'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      role: json['role'] as String? ?? '',
      category: json['category'] as String? ?? '',
      completionDate: DateTime.tryParse(
        json['completionDate'] as String? ?? '',
      ),
      responseMessage: responseMessage,
    );
  }

  @override
  List<Object?> get props => [id, title, description];
}
