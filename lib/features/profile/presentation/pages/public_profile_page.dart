import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/network/api_client_helper.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/bookmark_manager.dart';
import '../../../../core/utils/follow_manager.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/paginated.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_shimmer.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../../../investor_dashboard/domain/repositories/investor_repository.dart';
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
    final api = sl<ApiClientHelper>();
    final String endpoint;
    switch (widget.type) {
      case PublicProfileType.freelancer:
        endpoint = ApiEndpoints.publicFreelancer(widget.id);
        break;
      case PublicProfileType.company:
        endpoint = ApiEndpoints.publicClient(widget.id);
        break;
      case PublicProfileType.investor:
        endpoint = ApiEndpoints.publicInvestor(widget.id);
        break;
      case PublicProfileType.founder:
        endpoint = ApiEndpoints.publicStartup(widget.id);
        break;
    }

    final rawResult = await api.get<Map<String, dynamic>>(
      endpoint,
      parser: (data) => Map<String, dynamic>.from(data as Map),
    );

    final raw = rawResult.valueOrNull ?? {};
    final profile = raw.isNotEmpty ? _parse(raw) : null;

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

  void _share(ProfileViewData data) {
    final link = _shareLink(widget.type, widget.id);
    final text = '${data.name} — ${data.headline}\n\nView profile: $link';
    Share.share(text, subject: '${data.name} on GoExperts');
  }

  void _copyLink() {
    final link = _shareLink(widget.type, widget.id);
    Clipboard.setData(ClipboardData(text: link));
    context.showSnack('Profile link copied!');
  }

  void _showShareSheet(BuildContext context, ProfileViewData data) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.screenPadding,
                0,
                AppSizes.screenPadding,
                8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Share ${data.name}\'s Profile',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _shareLink(widget.type, widget.id),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.mutedText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: const Text('Share via apps (WhatsApp, Gmail…)'),
              onTap: () {
                Navigator.of(context).pop();
                _share(data);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: const Text('Copy link'),
              onTap: () {
                Navigator.of(context).pop();
                _copyLink();
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_rounded),
              title: const Text('Show QR code'),
              onTap: () {
                Navigator.of(context).pop();
                _showQr(context, data);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showQr(BuildContext context, ProfileViewData data) => showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppAvatar(name: data.name, imageUrl: data.avatarUrl, size: 52),
            const SizedBox(height: 12),
            Text(data.name, style: Theme.of(context).textTheme.titleMedium),
            Text(
              data.headline,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            AppSizes.vGapLg,
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: const Icon(Icons.qr_code_2_rounded, size: 150),
            ),
            AppSizes.vGapMd,
            Text(
              'Scan to view public profile',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            AppSizes.vGapMd,
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _copyLink();
              },
              child: const Text('Copy Link'),
            ),
          ],
        ),
      ),
    ),
  );

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
