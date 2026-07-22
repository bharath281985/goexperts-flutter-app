import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/bookmark_manager.dart';
import '../../../../core/utils/follow_manager.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/paginated.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_shimmer.dart';
import '../../../client_dashboard/domain/repositories/company_repository.dart';
import '../../../founder_dashboard/domain/repositories/founder_repository.dart';
import '../../../freelancer_dashboard/domain/repositories/freelancer_repository.dart';
import '../../../investor_dashboard/domain/repositories/investor_repository.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../widgets/profile_view.dart';

export '../widgets/profile_view.dart' show PublicProfileType;

/// Public profile page for any role. Fetches by type + id, maps to a shared
/// [ProfileViewData] and renders the reusable [ProfileView].
class PublicProfilePage extends StatefulWidget {
  const PublicProfilePage({super.key, required this.type, required this.id});

  final PublicProfileType type;
  final String id;

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadAll();
  }

  String get _category {
    switch (widget.type) {
      case PublicProfileType.freelancer:
        return BookmarkManager.categoryFreelancers;
      case PublicProfileType.company:
        return BookmarkManager.categoryCompanies;
      case PublicProfileType.investor:
        return BookmarkManager.categoryInvestors;
      case PublicProfileType.founder:
        return BookmarkManager.categoryFounders;
    }
  }

  Future<ProfileViewData?> _load() async {
    switch (widget.type) {
      case PublicProfileType.freelancer:
        final r = await sl<FreelancerRepository>().getFreelancer(widget.id);
        final f = r.valueOrNull;
        if (f == null) return null;
        return ProfileViewData(
          name: f.name,
          headline: f.headline,
          location: f.location,
          avatarUrl: f.avatarUrl,
          isVerified: f.isVerified,
          about: f.bio,
          rating: f.rating,
          reviewsCount: f.reviewsCount,
          followers: f.followers,
          skills: f.skills,
          isFollowing: FollowManager.instance.isFollowing(
            FollowManager.categoryFreelancers,
            f.id,
          ),
          isSaved: BookmarkManager.instance.isBookmarked(
            BookmarkManager.categoryFreelancers,
            f.id,
          ),
          type: PublicProfileType.freelancer,
          primaryActionLabel: 'Hire Now',
          primaryActionIcon: Icons.handshake_outlined,
          stats: {
            'Projects': '${f.completedProjects}',
            'Success': '${f.successRate}%',
            'Rate': '${Formatters.compactCurrency(f.hourlyRate)}/hr',
          },
        );
      case PublicProfileType.company:
        final r = await sl<CompanyRepository>().getCompany(widget.id);
        final c = r.valueOrNull;
        if (c == null) return null;
        return ProfileViewData(
          name: c.name,
          headline: '${c.industry} · ${c.teamSize} employees',
          location: c.location,
          avatarUrl: c.logoUrl,
          isVerified: c.isVerified,
          about: c.description,
          rating: c.rating,
          isFollowing: FollowManager.instance.isFollowing(
            FollowManager.categoryCompanies,
            c.id,
          ),
          isSaved: BookmarkManager.instance.isBookmarked(
            BookmarkManager.categoryCompanies,
            c.id,
          ),
          type: PublicProfileType.company,
          primaryActionLabel: 'Follow',
          primaryActionIcon: Icons.person_add_alt_1_outlined,
          stats: {
            'Projects': '${c.projectsPosted}',
            'Hires': '${c.hiresCount}',
            'Owner': c.ownerName.split(' ').first,
          },
        );
      case PublicProfileType.investor:
        final r = await sl<InvestorRepository>().getInvestor(widget.id);
        final i = r.valueOrNull;
        if (i == null) return null;
        return ProfileViewData(
          name: i.name,
          headline: '${i.investorType} · ${i.company}',
          location: i.location,
          avatarUrl: i.avatarUrl,
          isVerified: i.isVerified,
          about: i.bio,
          skills: i.interestedIndustries,
          isFollowing: FollowManager.instance.isFollowing(
            FollowManager.categoryInvestors,
            i.id,
          ),
          isSaved: BookmarkManager.instance.isBookmarked(
            BookmarkManager.categoryInvestors,
            i.id,
          ),
          type: PublicProfileType.investor,
          primaryActionLabel: 'Connect',
          primaryActionIcon: Icons.handshake_outlined,
          stats: {
            'Deals': '${i.dealsCount}',
            'Portfolio': '${i.portfolioCount}',
            'Ticket': Formatters.compactCurrency(i.maxInvestment),
          },
        );
      case PublicProfileType.founder:
        final r = await sl<FounderRepository>().getFounder(widget.id);
        final f = r.valueOrNull;
        if (f == null) return null;
        return ProfileViewData(
          name: f.name,
          headline: '${f.founderType} · ${f.startupName}',
          location: f.location,
          avatarUrl: f.avatarUrl,
          isVerified: f.isVerified,
          about: f.bio,
          skills: f.skills,
          followers: f.followers,
          isFollowing: FollowManager.instance.isFollowing(
            FollowManager.categoryFounders,
            f.id,
          ),
          isSaved: BookmarkManager.instance.isBookmarked(
            BookmarkManager.categoryFounders,
            f.id,
          ),
          type: PublicProfileType.founder,
          primaryActionLabel: 'Invest',
          primaryActionIcon: Icons.trending_up_rounded,
          stats: {
            'Followers': '${f.followers}',
            'Experience': '${f.experienceYears}y',
            'Startup': f.startupName,
          },
        );
    }
  }

  Future<Map<String, dynamic>> _loadAll() async {
    final profile = await _load();
    List<Review> reviews = [];
    if (profile != null) {
      final reviewsRes = await sl<ReviewRepository>().getReviews(
        QueryParams(
          filters: {'targetId': widget.id, 'targetType': widget.type.name},
        ),
      );
      reviews = reviewsRes.fold((_) => [], (page) => page.items);
    }
    return {'profile': profile, 'reviews': reviews};
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        BookmarkManager.instance,
        FollowManager.instance,
      ]),
      builder: (context, _) {
        return FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            final data = snapshot.data;
            final profile = data?['profile'] as ProfileViewData?;
            final reviews = data?['reviews'] as List<Review>? ?? const [];
            return Scaffold(
              appBar: AppBar(
                title: Text(context.tr('Profile')),
                actions: [
                  IconButton(
                    tooltip: context.tr('Share'),
                    onPressed: profile == null
                        ? null
                        : () => context.showSnack('Share link copied'),
                    icon: const Icon(Icons.share_outlined),
                  ),
                  IconButton(
                    tooltip: context.tr('Scan'),
                    onPressed: profile == null
                        ? null
                        : () => ProfileActions.showQr(context, profile),
                    icon: const Icon(Icons.qr_code_rounded),
                  ),
                  IconButton(
                    tooltip: context.tr('More'),
                    onPressed: profile == null
                        ? null
                        : () => ProfileActions.showMore(context, profile),
                    icon: const Icon(Icons.more_vert_rounded),
                  ),
                ],
              ),
              body: snapshot.connectionState == ConnectionState.waiting
                  ? const AppLoadingShimmer(itemCount: 4, height: 120)
                  : profile == null
                  ? const AppErrorState()
                  : ProfileView(
                      data: profile,
                      reviews: reviews,
                      onPrimaryAction: () => context.showSnack(
                        '${profile.primaryActionLabel} · ${profile.name}',
                      ),
                      onMessage: () {
                        final nameEncoded = Uri.encodeComponent(profile.name);
                        final avatarEncoded = Uri.encodeComponent(
                          profile.avatarUrl ?? '',
                        );
                        context.push(
                          '${Routes.chat}/${widget.id}?name=$nameEncoded&avatarUrl=$avatarEncoded',
                        );
                      },
                      onFollow: () => FollowManager.instance.toggleFollow(
                        _category,
                        widget.id,
                      ),
                      onBookmark: () =>
                          BookmarkManager.instance.toggle(_category, widget.id),
                    ),
            );
          },
        );
      },
    );
  }
}
