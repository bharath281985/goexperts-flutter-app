import 'package:equatable/equatable.dart';

class SkillCategory extends Equatable {
  const SkillCategory({
    required this.id,
    required this.name,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final int sortOrder;

  factory SkillCategory.fromJson(Map<String, dynamic> json) {
    return SkillCategory(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      sortOrder: json['sortOrder'] as int? ?? json['sort_order'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [id];
}
