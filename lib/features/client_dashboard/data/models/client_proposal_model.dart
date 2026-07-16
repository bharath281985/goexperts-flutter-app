import '../../../../core/utils/enums.dart';
import '../../../proposals/domain/entities/proposal.dart';

/// Maps client proposal API payloads to [Proposal] entities.
class ClientProposalModel {
  ClientProposalModel._();

  static Proposal fromJson(Map<String, dynamic> json) {
    final freelancer = json['freelancer'] as Map<String, dynamic>?;
    final project = json['project'] as Map<String, dynamic>?;

    return Proposal(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? project?['id']?.toString(),
      projectTitle: json['projectTitle'] as String? ??
          project?['title'] as String? ??
          'Project',
      clientId: json['clientId']?.toString() ?? project?['client']?.toString(),
      clientName: json['clientName'] as String?,
      freelancerId: json['freelancerId']?.toString() ??
          freelancer?['id']?.toString(),
      freelancerName: freelancer?['fullName'] as String? ??
          json['freelancerName'] as String? ??
          'Freelancer',
      freelancerAvatar: freelancer?['avatarUrl'] as String?,
      bidAmount: (json['bidAmount'] as num?)?.toDouble() ?? 0,
      isHourly: json['isHourly'] as bool? ?? false,
      coverLetter: json['coverLetter'] as String? ?? '',
      status: EntityStatus.fromString(json['status'] as String? ?? 'pending'),
      submittedAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      deliveryDays: json['deliveryDays'] as int? ?? 14,
      freelancerRating: (freelancer?['freelancerProfile']?['rating'] as num?)
              ?.toDouble() ??
          4.5,
      attachments: (json['attachments'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}
