import 'package:equatable/equatable.dart';
import '../../../../core/utils/enums.dart';

/// A project posted by a client that freelancers can apply to.
class Project extends Equatable {
  const Project({
    required this.id,
    required this.title,
    required this.description,
    required this.clientName,
    required this.category,
    required this.skills,
    required this.budgetMin,
    required this.budgetMax,
    required this.isHourly,
    required this.timeline,
    required this.status,
    required this.postedAt,
    this.clientId,
    this.clientAvatar,
    this.categoryId,
    this.skillIds = const [],
    this.proposalsCount = 0,
    this.workMode = 'Remote',
    this.experienceLevel = 'intermediate',
    this.isSaved = false,
    this.isApplied = false,
    this.isOwner = false,
    this.location = 'Remote',
    this.techStack = const [],
    this.attachments = const [],
    this.clientVerified = true,
  });

  final String id;
  final String title;
  final String description;
  final String? clientId;
  final String clientName;
  final String? clientAvatar;
  final String category;
  final String? categoryId;
  final List<String> skills;
  final List<String> skillIds;
  final List<String> techStack;
  final double budgetMin;
  final double budgetMax;
  final bool isHourly;
  final String timeline;
  final EntityStatus status;
  final DateTime postedAt;
  final int proposalsCount;
  final String workMode;
  final String experienceLevel;
  final bool isSaved;
  final bool isApplied;
  final bool isOwner;
  final String location;
  final List<String> attachments;
  final bool clientVerified;

  Project copyWith({
    bool? isSaved,
    bool? isApplied,
    bool? isOwner,
    EntityStatus? status,
    int? proposalsCount,
  }) =>
      Project(
        id: id,
        title: title,
        description: description,
        clientId: clientId,
        clientName: clientName,
        clientAvatar: clientAvatar,
        category: category,
        categoryId: categoryId,
        skills: skills,
        skillIds: skillIds,
        techStack: techStack,
        budgetMin: budgetMin,
        budgetMax: budgetMax,
        isHourly: isHourly,
        timeline: timeline,
        status: status ?? this.status,
        postedAt: postedAt,
        proposalsCount: proposalsCount ?? this.proposalsCount,
        workMode: workMode,
        experienceLevel: experienceLevel,
        isSaved: isSaved ?? this.isSaved,
        isApplied: isApplied ?? this.isApplied,
        isOwner: isOwner ?? this.isOwner,
        location: location,
        attachments: attachments,
        clientVerified: clientVerified,
      );

  static final _uuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  static String _displayName(String? value, {String fallback = 'Client'}) {
    final v = value?.trim();
    if (v == null || v.isEmpty || _uuid.hasMatch(v)) return fallback;
    return v;
  }

  static List<String> _nameList(dynamic raw) {
    if (raw is List) {
      return raw
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty && !_uuid.hasMatch(e))
          .toList();
    }
    if (raw is String && raw.trim().isNotEmpty) {
      return raw
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty && !_uuid.hasMatch(e))
          .toList();
    }
    return const [];
  }

  static List<String> _idList(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return const [];
  }

  static List<String> _attachments(dynamic raw) {
    if (raw is List) {
      return raw.map((e) {
        if (e is Map) return e['url']?.toString() ?? e['name']?.toString() ?? '';
        return e.toString();
      }).where((e) => e.isNotEmpty).toList();
    }
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        // handled as plain string URL list
      } catch (_) {}
      return raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return const [];
  }

  factory Project.fromApiJson(Map<String, dynamic> json) {
    final clientObj = json['client'];
    final clientNameRaw = clientObj is Map
        ? clientObj['fullName']?.toString() ?? clientObj['name']?.toString()
        : json['clientName'] as String? ??
            (clientObj is String && !_uuid.hasMatch(clientObj) ? clientObj : null);

    final categoryRaw = json['category'] as String? ?? 'General';
    final skillNames = _nameList(json['skills']).isNotEmpty
        ? _nameList(json['skills'])
        : _nameList(json['techStack']).isNotEmpty
            ? _nameList(json['techStack'])
            : _nameList(json['technology']);

    return Project(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      clientId: json['clientId']?.toString() ??
          (clientObj is String && _uuid.hasMatch(clientObj) ? clientObj : null) ??
          (clientObj is Map ? clientObj['id']?.toString() : null),
      clientName: _displayName(clientNameRaw),
      clientAvatar: (json['clientAvatar'] as String?) ??
          (json['avatarUrl'] as String?) ??
          (clientObj is Map ? clientObj['avatarUrl']?.toString() : null),
      category: _uuid.hasMatch(categoryRaw) ? 'General' : categoryRaw,
      categoryId: json['categoryId']?.toString() ??
          (_uuid.hasMatch(categoryRaw) ? categoryRaw : null),
      skills: skillNames,
      skillIds: _idList(json['skillIds']).isNotEmpty
          ? _idList(json['skillIds'])
          : _idList(json['technology']).where(_uuid.hasMatch).toList(),
      techStack: _nameList(json['techStack']).isNotEmpty
          ? _nameList(json['techStack'])
          : skillNames,
      budgetMin: (json['budgetMin'] as num?)?.toDouble() ??
          (json['budget'] as num?)?.toDouble() ??
          0,
      budgetMax: (json['budgetMax'] as num?)?.toDouble() ??
          (json['budget'] as num?)?.toDouble() ??
          0,
      isHourly: json['isHourly'] as bool? ??
          (json['is_hourly'] as bool?) ??
          false,
      timeline: json['timeline'] as String? ?? '',
      status: EntityStatus.fromString(json['status'] as String? ?? 'open'),
      postedAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      proposalsCount: (json['proposalsCount'] as num?)?.toInt() ?? 0,
      workMode: json['workMode'] as String? ?? 'Remote',
      experienceLevel: json['experienceLevel'] as String? ?? 'intermediate',
      location: json['location'] as String? ??
          json['city'] as String? ??
          'Remote',
      attachments: _attachments(json['attachments']),
      clientVerified: json['clientVerified'] as bool? ?? true,
      isOwner: json['isOwner'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, isSaved, isApplied, isOwner, status];
}

/// A milestone within a contract.
class Milestone extends Equatable {
  const Milestone({
    required this.title,
    required this.amount,
    required this.status,
    required this.dueDate,
  });

  final String title;
  final double amount;
  final EntityStatus status;
  final DateTime dueDate;

  @override
  List<Object?> get props => [title, status];
}

/// An active or completed contract between a client and freelancer.
class Contract extends Equatable {
  const Contract({
    required this.id,
    required this.projectTitle,
    required this.counterpartyName,
    required this.amount,
    required this.status,
    required this.startDate,
    required this.milestones,
    this.counterpartyAvatar,
    this.progress = 0,
  });

  final String id;
  final String projectTitle;
  final String counterpartyName;
  final String? counterpartyAvatar;
  final double amount;
  final EntityStatus status;
  final DateTime startDate;
  final List<Milestone> milestones;
  final double progress;

  @override
  List<Object?> get props => [id, status, progress];
}
