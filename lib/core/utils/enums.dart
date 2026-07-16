import 'package:flutter/material.dart';

/// The four public roles supported by the mobile app.
/// `superAdmin` exists on the web panel only and is intentionally never shown.
enum UserRole {
  freelancer,
  client,
  investor,
  founder;

  String get apiValue => name;

  String get label {
    switch (this) {
      case UserRole.freelancer:
        return 'Freelancer';
      case UserRole.client:
        return 'Client / Business Owner';
      case UserRole.investor:
        return 'Investor';
      case UserRole.founder:
        return 'Startup Founder';
    }
  }

  String get shortLabel {
    switch (this) {
      case UserRole.freelancer:
        return 'Freelancer';
      case UserRole.client:
        return 'Client';
      case UserRole.investor:
        return 'Investor';
      case UserRole.founder:
        return 'Founder';
    }
  }

  String get description {
    switch (this) {
      case UserRole.freelancer:
        return 'Find projects, submit proposals and grow your freelance career.';
      case UserRole.client:
        return 'Post projects, hire top talent and manage your business teams.';
      case UserRole.investor:
        return 'Discover startups, run due diligence and build your portfolio.';
      case UserRole.founder:
        return 'Pitch your startup, raise funding and connect with investors.';
    }
  }

  List<String> get benefits {
    switch (this) {
      case UserRole.freelancer:
        return ['Verified projects', 'Secure escrow payments', 'AI job matching'];
      case UserRole.client:
        return ['Vetted freelancers', 'Milestone contracts', 'Team management'];
      case UserRole.investor:
        return ['Curated deal flow', 'Secure deal rooms', 'Portfolio analytics'];
      case UserRole.founder:
        return ['Investor network', 'Pitch deck hosting', 'Funding pipeline'];
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.freelancer:
        return Icons.work_outline_rounded;
      case UserRole.client:
        return Icons.business_center_outlined;
      case UserRole.investor:
        return Icons.trending_up_rounded;
      case UserRole.founder:
        return Icons.rocket_launch_outlined;
    }
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (r) => r.name == value,
      orElse: () => UserRole.freelancer,
    );
  }
}

/// Generic lifecycle status for BLoC-driven screens.
enum ViewStatus { initial, loading, refreshing, loadingMore, success, empty, failure }

/// Common domain status used by projects, proposals, deals, etc.
enum EntityStatus {
  draft,
  open,
  pending,
  active,
  inProgress,
  underReview,
  interview,
  shortlisted,
  accepted,
  rejected,
  completed,
  cancelled,
  expired,
  withdrawn;

  String get label {
    switch (this) {
      case EntityStatus.draft:
        return 'Draft';
      case EntityStatus.open:
        return 'Open';
      case EntityStatus.pending:
        return 'Pending';
      case EntityStatus.active:
        return 'Active';
      case EntityStatus.inProgress:
        return 'In Progress';
      case EntityStatus.underReview:
        return 'Under Review';
      case EntityStatus.interview:
        return 'Interview';
      case EntityStatus.shortlisted:
        return 'Shortlisted';
      case EntityStatus.accepted:
        return 'Accepted';
      case EntityStatus.rejected:
        return 'Rejected';
      case EntityStatus.completed:
        return 'Completed';
      case EntityStatus.cancelled:
        return 'Cancelled';
      case EntityStatus.expired:
        return 'Expired';
      case EntityStatus.withdrawn:
        return 'Withdrawn';
    }
  }

  static EntityStatus fromString(String value) {
    final normalized = value.replaceAll('_', '').toLowerCase();
    return EntityStatus.values.firstWhere(
      (s) => s.name.toLowerCase() == normalized,
      orElse: () => EntityStatus.pending,
    );
  }
}
