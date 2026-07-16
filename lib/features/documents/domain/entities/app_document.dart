import 'package:equatable/equatable.dart';

class AppDocument extends Equatable {
  const AppDocument({
    required this.id,
    required this.name,
    required this.category,
    required this.createdAt,
    this.sizeBytes = 0,
    this.url,
    this.mimeType,
  });

  final String id;
  final String name;
  final String category;
  final DateTime createdAt;
  final int sizeBytes;
  final String? url;
  final String? mimeType;

  factory AppDocument.fromApiJson(Map<String, dynamic> json) {
    return AppDocument(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? json['title'] as String? ?? 'Document',
      category: json['category'] as String? ?? 'other',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ??
          (json['size'] as num?)?.toInt() ??
          0,
      url: json['url'] as String? ?? json['previewUrl'] as String?,
      mimeType: json['mimeType'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, category, createdAt, sizeBytes, url];
}
