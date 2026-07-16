import 'package:equatable/equatable.dart';

class FreelancerTask extends Equatable {
  const FreelancerTask({
    required this.id,
    required this.title,
    required this.status,
    this.priority = 'Medium',
    this.progress = 0,
  });

  final String id;
  final String title;
  final String status;
  final String priority;
  final int progress;

  bool get isCompleted => status.toLowerCase() == 'completed';

  factory FreelancerTask.fromApiJson(Map<String, dynamic> json) {
    return FreelancerTask(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? 'Task',
      status: json['status'] as String? ?? 'pending',
      priority: json['priority'] as String? ?? 'Medium',
      progress: (json['progress'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, title, status, priority, progress];
}

class TaskComment extends Equatable {
  const TaskComment({
    required this.id,
    required this.text,
    required this.createdAt,
    this.author = 'User',
  });

  final String id;
  final String text;
  final DateTime createdAt;
  final String author;

  factory TaskComment.fromApiJson(Map<String, dynamic> json) {
    return TaskComment(
      id: json['id']?.toString() ?? '',
      text: json['comment'] as String? ?? json['text'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      author: json['author'] as String? ?? json['userId']?.toString() ?? 'User',
    );
  }

  @override
  List<Object?> get props => [id, text, createdAt, author];
}

class TaskAttachment extends Equatable {
  const TaskAttachment({required this.id, required this.name, this.url});
  final String id;
  final String name;
  final String? url;

  factory TaskAttachment.fromApiJson(Map<String, dynamic> json) {
    return TaskAttachment(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? json['fileName'] as String? ?? 'Attachment',
      url: json['url'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, url];
}

class TaskTimeLog extends Equatable {
  const TaskTimeLog({
    required this.id,
    required this.hours,
    required this.date,
    this.notes = '',
  });
  final String id;
  final String hours;
  final String date;
  final String notes;

  factory TaskTimeLog.fromApiJson(Map<String, dynamic> json) {
    return TaskTimeLog(
      id: json['id']?.toString() ?? '',
      hours: json['hours']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      notes: json['taskDesc'] as String? ?? json['description'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, hours, date, notes];
}
