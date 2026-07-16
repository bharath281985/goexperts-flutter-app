import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';

enum NotificationCategory {
  project,
  payment,
  meeting,
  contract,
  message,
  follower,
  bookmark,
  review,
  investment,
  startup,
  marketing,
  security,
  system;

  String get label {
    final n = name;
    return n[0].toUpperCase() + n.substring(1);
  }

  IconData get icon {
    switch (this) {
      case NotificationCategory.project:
        return Icons.work_outline_rounded;
      case NotificationCategory.payment:
        return Icons.account_balance_wallet_outlined;
      case NotificationCategory.meeting:
        return Icons.event_outlined;
      case NotificationCategory.contract:
        return Icons.description_outlined;
      case NotificationCategory.message:
        return Icons.chat_bubble_outline_rounded;
      case NotificationCategory.follower:
        return Icons.person_add_alt_1_outlined;
      case NotificationCategory.bookmark:
        return Icons.bookmark_outline_rounded;
      case NotificationCategory.review:
        return Icons.star_outline_rounded;
      case NotificationCategory.investment:
        return Icons.trending_up_rounded;
      case NotificationCategory.startup:
        return Icons.rocket_launch_outlined;
      case NotificationCategory.marketing:
        return Icons.campaign_outlined;
      case NotificationCategory.security:
        return Icons.shield_outlined;
      case NotificationCategory.system:
        return Icons.settings_outlined;
    }
  }

  Color get color {
    switch (this) {
      case NotificationCategory.payment:
        return AppColors.success;
      case NotificationCategory.security:
        return AppColors.danger;
      case NotificationCategory.meeting:
        return AppColors.info;
      case NotificationCategory.investment:
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }
}

/// A notification item.
class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final NotificationCategory category;
  final DateTime createdAt;
  final bool isRead;

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        body: body,
        category: category,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
      );

  @override
  List<Object?> get props => [id, isRead];
}
