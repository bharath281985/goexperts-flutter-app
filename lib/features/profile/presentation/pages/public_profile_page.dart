import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

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
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_shimmer.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../../../investor_dashboard/domain/repositories/investor_repository.dart';
import '../widgets/profile_view.dart';

export '../widgets/profile_view.dart' show PublicProfileType;

/// Canonical web-style deep-link: `https://goexperts.in/{type}/{id}`
String _shareLink(PublicProfileType type, String id) {
  const base = 'https://goexperts.in';
  switch (type) {
    case PublicProfileType.freelancer:
      return '$base/u/freelancer/$id';
    case PublicProfileType.company:
      return '$base/u/company/$id';
    case PublicProfileType.investor:
      return '$base/u/investor/$id';
    case PublicProfileType.founder:
      return '$base/u/founder/$id';
  }
}

/// Public profile page for any role.
/// Fetches data from the public API endpoints (no auth required).
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

  String get _bookmarkCategory {
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

  String get _followCategory {
    switch (widget.type) {
      case PublicProfileType.freelancer:
        return FollowManager.categoryFreelancers;
      case PublicProfileType.company:
        return FollowManager.categoryCompanies;
      case PublicProfileType.investor:
        return FollowManager.categoryInvestors;
      case PublicProfileType.founder:
        return FollowManager.categoryFounders;
    }
  }

  /// Builds a ProfileViewData from the raw API data map.
  ProfileViewData? _parse(Map<String, dynamic> raw) {
    final id = raw['id']?.toString() ?? widget.id;
    final fullName =
        raw['fullName']?.toString() ?? raw['full_name']?.toString() ?? 'User';
    final avatarUrl =
        raw['avatarUrl']?.toString() ?? raw['avatar_url']?.toString();
    final city = raw['city']?.toString() ?? '';
    final country = raw['country']?.toString() ?? '';
    final location = [city, country].where((e) => e.isNotEmpty).join(', ');
    final bio = raw['bio']?.toString() ?? '';
    final isVerified =
        raw['isVerified'] as bool? ?? raw['is_verified'] as bool? ?? false;
    final email = raw['email']?.toString() ?? '';
    final phone = raw['phone']?.toString() ?? '';

    switch (widget.type) {
      case PublicProfileType.freelancer:
        {
          final fp = raw['freelancerProfile'] as Map? ?? {};
          final skillsRaw = fp['skills']?.toString() ?? '';
          final skills = skillsRaw.isNotEmpty
              ? skillsRaw
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList()
              : <String>[];
          final hourlyRate = (fp['hourlyRate'] as num?)?.toDouble() ?? 0.0;
          final experience = fp['experience']?.toString() ?? '';
          return ProfileViewData(
            name: fullName,
            headline: [
              experience,
              if (hourlyRate > 0)
                '${Formatters.compactCurrency(hourlyRate)}/hr',
            ].join(' · '),
            location: location,
            avatarUrl: avatarUrl,
            isVerified: isVerified,
            about: bio,
            skills: skills,
            isFollowing: FollowManager.instance.isFollowing(
              _followCategory,
              id,
            ),
            isSaved: BookmarkManager.instance.isBookmarked(
              _bookmarkCategory,
              id,
            ),
            type: PublicProfileType.freelancer,
            primaryActionLabel: 'Hire Now',
            primaryActionIcon: Icons.handshake_outlined,
            stats: {
              'Experience': experience.isEmpty ? '—' : experience,
              'Rate': hourlyRate > 0
                  ? '${Formatters.compactCurrency(hourlyRate)}/hr'
                  : '—',
              'Skills': '${skills.length}',
            },
            phone: phone,
            email: email,
          );
        }
      case PublicProfileType.company:
        {
          final cp = raw['clientProfile'] as Map? ?? {};
          final company = cp['company']?.toString() ?? fullName;
          final industry = cp['industry']?.toString() ?? '';
          return ProfileViewData(
            name: company,
            headline: industry.isNotEmpty ? industry : 'Client',
            location: location,
            avatarUrl: avatarUrl,
            isVerified: isVerified,
            about: bio,
            isFollowing: FollowManager.instance.isFollowing(
              _followCategory,
              id,
            ),
            isSaved: BookmarkManager.instance.isBookmarked(
              _bookmarkCategory,
              id,
            ),
            type: PublicProfileType.company,
            primaryActionLabel: 'Post a Job',
            primaryActionIcon: Icons.work_outline_rounded,
            stats: {
              'Industry': industry.isEmpty ? '—' : industry,
              'Manager': fullName.split(' ').first,
            },
            phone: phone,
            email: email,
          );
        }
      case PublicProfileType.investor:
        {
          final ip = raw['investorProfile'] as Map? ?? {};
          final firm = ip['firm']?.toString() ?? '';
          final ticketMin = (ip['ticketMin'] as num?)?.toDouble() ?? 0.0;
          final ticketMax = (ip['ticketMax'] as num?)?.toDouble() ?? 0.0;
          final focusRaw = ip['focusAreas']?.toString() ?? '';
          final focus = focusRaw.isNotEmpty
              ? focusRaw
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList()
              : <String>[];
          return ProfileViewData(
            name: fullName,
            headline: firm.isNotEmpty ? firm : 'Investor',
            location: location,
            avatarUrl: avatarUrl,
            isVerified: isVerified,
            about: bio,
            skills: focus,
            isFollowing: FollowManager.instance.isFollowing(
              _followCategory,
              id,
            ),
            isSaved: BookmarkManager.instance.isBookmarked(
              _bookmarkCategory,
              id,
            ),
            type: PublicProfileType.investor,
            primaryActionLabel: 'Connect',
            primaryActionIcon: Icons.handshake_outlined,
            stats: {
              'Firm': firm.isEmpty ? '—' : firm,
              'Min Ticket': ticketMin > 0
                  ? Formatters.compactCurrency(ticketMin)
                  : '—',
              'Max Ticket': ticketMax > 0
                  ? Formatters.compactCurrency(ticketMax)
                  : '—',
            },
            phone: phone,
            email: email,
          );
        }
      case PublicProfileType.founder:
        {
          final fp = raw['founderProfile'] as Map? ?? {};
          final startupName = fp['startupName']?.toString() ?? fullName;
          final industry = fp['industry']?.toString() ?? '';
          final stage = fp['stage']?.toString() ?? '';
          final teamSize = (fp['teamSize'] as num?)?.toInt() ?? 0;
          final raised = (fp['raised'] as num?)?.toDouble() ?? 0.0;
          return ProfileViewData(
            name: fullName,
            headline: [
              startupName,
              if (industry.isNotEmpty) industry,
              if (stage.isNotEmpty) stage,
            ].join(' · '),
            location: location,
            avatarUrl: avatarUrl,
            isVerified: isVerified,
            about: bio,
            isFollowing: FollowManager.instance.isFollowing(
              _followCategory,
              id,
            ),
            isSaved: BookmarkManager.instance.isBookmarked(
              _bookmarkCategory,
              id,
            ),
            type: PublicProfileType.founder,
            primaryActionLabel:
                FollowManager.instance.isFollowing(_followCategory, id)
                ? 'Unfollow'
                : 'Follow',
            primaryActionIcon:
                FollowManager.instance.isFollowing(_followCategory, id)
                ? Icons.person_remove_outlined
                : Icons.person_add_alt_1_outlined,
            stats: {
              'Startup': startupName,
              'Stage': stage.isEmpty ? '—' : stage,
              'Team': teamSize > 0 ? '$teamSize' : '—',
              'Raised': raised > 0 ? Formatters.compactCurrency(raised) : '—',
            },
            phone: phone,
            email: email,
          );
        }
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
            final profile = snapshot.data?['profile'] as ProfileViewData?;
            final reviews =
                snapshot.data?['reviews'] as List<Review>? ?? const [];

            return Scaffold(
              appBar: AppBar(
                title: Text(
                  profile?.name ?? 'Profile',
                  overflow: TextOverflow.ellipsis,
                ),
                actions: [
                  if (profile != null)
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
                      tooltip: 'Share profile',
                      onPressed: () => _showShareSheet(context, profile),
                    ),
                ],
              ),
              body: () {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppLoadingShimmer(itemCount: 4, height: 120);
                }
                if (profile == null) return const AppErrorState();
                return ProfileView(
                  data: profile,
                  reviews: reviews,
                  onShare: () => _showShareSheet(context, profile),
                  onPrimaryAction: () {
                    if (profile.type == PublicProfileType.founder) {
                      FollowManager.instance.toggleFollow(
                        _followCategory,
                        widget.id,
                      );
                    } else {
                      context.showSnack(
                        '${profile.primaryActionLabel} · ${profile.name}',
                      );
                    }
                  },
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
                    _followCategory,
                    widget.id,
                  ),
                  onBookmark: () async {
                    if (widget.type == PublicProfileType.investor) {
                      final repo = sl<InvestorRepository>();
                      final res = await repo.toggleSave(widget.id);
                      res.fold(
                        (f) {
                          context.showSnack(f.message, isError: true);
                        },
                        (success) {
                          BookmarkManager.instance.toggle(
                            _bookmarkCategory,
                            widget.id,
                          );
                        },
                      );
                    } else if (widget.type == PublicProfileType.founder) {
                      final api = sl<ApiClientHelper>();
                      final post = await api.postAction(
                        ApiEndpoints.investorFounderSave(widget.id),
                      );
                      final res = post.isSuccess
                          ? post
                          : await api.deleteAction(
                              ApiEndpoints.investorFounderSave(widget.id),
                            );
                      res.fold(
                        (f) {
                          context.showSnack(f.message, isError: true);
                        },
                        (success) {
                          BookmarkManager.instance.toggle(
                            _bookmarkCategory,
                            widget.id,
                          );
                        },
                      );
                    } else {
                      BookmarkManager.instance.toggle(
                        _bookmarkCategory,
                        widget.id,
                      );
                    }
                  },
                );
              }(),
            );
          },
        );
      },
    );
  }
}
