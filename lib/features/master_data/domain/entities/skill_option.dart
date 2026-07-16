import 'package:equatable/equatable.dart';

class SkillOption extends Equatable {
  const SkillOption({
    required this.id,
    required this.name,
    this.categoryId,
  });

  final String id;
  final String name;
  final String? categoryId;

  factory SkillOption.fromJson(Map<String, dynamic> json) {
    return SkillOption(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      categoryId:
          json['categoryId']?.toString() ?? json['category_id']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id];
}
