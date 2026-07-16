import 'package:equatable/equatable.dart';

/// A marketable service offering (fixed-scope package).
class ServiceItem extends Equatable {
  const ServiceItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.priceFrom,
    required this.deliveryDays,
    this.rating = 4.8,
    this.ordersCount = 0,
    this.providerName = '',
    this.providerAvatar,
    this.tags = const [],
    this.deliverables = const [],
  });

  final String id;
  final String name;
  final String category;
  final String description;
  final double priceFrom;
  final int deliveryDays;
  final double rating;
  final int ordersCount;
  final String providerName;
  final String? providerAvatar;
  final List<String> tags;
  final List<String> deliverables;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'description': description,
        'price_from': priceFrom,
        'delivery_days': deliveryDays,
        'rating': rating,
        'orders_count': ordersCount,
        'provider_name': providerName,
        'tags': tags,
        'deliverables': deliverables,
      };

  @override
  List<Object?> get props => [id];
}

/// A technology / stack entry (React, Flutter, AWS, …).
class Technology extends Equatable {
  const Technology({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.popularity = 0,
    this.projectsCount = 0,
    this.freelancersCount = 0,
    this.iconUrl,
    this.relatedSkills = const [],
    this.resources = const [],
  });

  final String id;
  final String name;
  final String category;
  final String description;
  final int popularity; // 0-100
  final int projectsCount;
  final int freelancersCount;
  final String? iconUrl;
  final List<String> relatedSkills;
  final List<String> resources;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'description': description,
        'popularity': popularity,
        'projects_count': projectsCount,
        'freelancers_count': freelancersCount,
        'related_skills': relatedSkills,
      };

  @override
  List<Object?> get props => [id];
}

/// A top-level marketplace category.
class CategoryItem extends Equatable {
  const CategoryItem({
    required this.id,
    required this.name,
    required this.description,
    this.projectsCount = 0,
    this.freelancersCount = 0,
    this.avgBudget = 0,
    this.subcategories = const [],
    this.trendingSkills = const [],
  });

  final String id;
  final String name;
  final String description;
  final int projectsCount;
  final int freelancersCount;
  final double avgBudget;
  final List<String> subcategories;
  final List<String> trendingSkills;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'projects_count': projectsCount,
        'freelancers_count': freelancersCount,
        'avg_budget': avgBudget,
        'subcategories': subcategories,
        'trending_skills': trendingSkills,
      };

  @override
  List<Object?> get props => [id];
}

/// A professional certificate shown on a profile.
class Certificate extends Equatable {
  const Certificate({
    required this.id,
    required this.title,
    required this.issuer,
    required this.issuedAt,
    this.credentialId = '',
    this.url,
    this.skills = const [],
    this.expiresAt,
  });

  final String id;
  final String title;
  final String issuer;
  final DateTime issuedAt;
  final String credentialId;
  final String? url;
  final List<String> skills;
  final DateTime? expiresAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'issuer': issuer,
        'issued_at': issuedAt.toIso8601String(),
        'credential_id': credentialId,
        'url': url,
        'skills': skills,
      };

  @override
  List<Object?> get props => [id];
}

/// An investment opportunity surfaced to investors.
class InvestmentOpportunity extends Equatable {
  const InvestmentOpportunity({
    required this.id,
    required this.startupName,
    required this.industry,
    required this.stage,
    required this.amountSought,
    required this.equityOffered,
    required this.minTicket,
    required this.valuation,
    required this.summary,
    this.highlights = const [],
    this.founderName = '',
    this.logoUrl,
    this.deadline,
    this.raisedSoFar = 0,
  });

  final String id;
  final String startupName;
  final String industry;
  final String stage;
  final double amountSought;
  final double equityOffered;
  final double minTicket;
  final double valuation;
  final String summary;
  final List<String> highlights;
  final String founderName;
  final String? logoUrl;
  final DateTime? deadline;
  final double raisedSoFar;

  double get progress => amountSought == 0 ? 0 : (raisedSoFar / amountSought).clamp(0, 1);

  Map<String, dynamic> toJson() => {
        'id': id,
        'startup_name': startupName,
        'industry': industry,
        'stage': stage,
        'amount_sought': amountSought,
        'equity_offered': equityOffered,
        'min_ticket': minTicket,
        'valuation': valuation,
        'summary': summary,
        'highlights': highlights,
        'raised_so_far': raisedSoFar,
      };

  @override
  List<Object?> get props => [id];
}

/// A section within a business plan.
class PlanSection extends Equatable {
  const PlanSection({required this.title, required this.content});
  final String title;
  final String content;
  @override
  List<Object?> get props => [title];
}

/// A startup business plan document.
class BusinessPlan extends Equatable {
  const BusinessPlan({
    required this.id,
    required this.startupName,
    required this.sections,
    required this.updatedAt,
    this.summary = '',
  });

  final String id;
  final String startupName;
  final List<PlanSection> sections;
  final DateTime updatedAt;
  final String summary;

  @override
  List<Object?> get props => [id, updatedAt];
}

/// A single pitch-deck slide.
class DeckSlide extends Equatable {
  const DeckSlide({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  List<Object?> get props => [title];
}

/// A startup pitch deck.
class PitchDeck extends Equatable {
  const PitchDeck({
    required this.id,
    required this.startupName,
    required this.slides,
    required this.updatedAt,
    this.views = 0,
  });

  final String id;
  final String startupName;
  final List<DeckSlide> slides;
  final DateTime updatedAt;
  final int views;

  @override
  List<Object?> get props => [id, updatedAt, views];
}
