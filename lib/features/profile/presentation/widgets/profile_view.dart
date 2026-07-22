import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/contact_workflow.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_action_sheet.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../domain/entities/review.dart';

enum PublicProfileType { freelancer, company, investor, founder }

/// View-model that adapts any role entity into a public profile layout.
class ProfileViewData {
  const ProfileViewData({
    required this.name,
    required this.headline,
    required this.location,
    this.avatarUrl,
    this.isVerified = true,
    this.about = '',
    this.rating,
    this.reviewsCount = 0,
    this.followers = 0,
    this.stats = const {},
    this.skills = const [],
    this.primaryActionLabel = 'Contact',
    this.primaryActionIcon = Icons.mail_outline_rounded,
    this.isFollowing = false,
    this.isSaved = false,
    this.type = PublicProfileType.freelancer,
    this.phone = '+91 98765 43210',
    this.email = 'info@goexperts.example',
  });

  final String name;
  final String headline;
  final String location;
  final String? avatarUrl;
  final bool isVerified;
  final String about;
  final double? rating;
  final int reviewsCount;
  final int followers;
  final Map<String, String> stats;
  final List<String> skills;
  final String primaryActionLabel;
  final IconData primaryActionIcon;
  final bool isFollowing;
  final bool isSaved;
  final PublicProfileType type;
  final String phone;
  final String email;
}

/// Rich, reusable public profile layout with a full action set.
class ProfileView extends StatelessWidget {
  const ProfileView({
    super.key,
    required this.data,
    this.reviews = const [],
    this.onPrimaryAction,
    this.onMessage,
    this.onFollow,
    this.onBookmark,
  });

  final ProfileViewData data;
  final List<Review> reviews;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onMessage;
  final VoidCallback? onFollow;
  final VoidCallback? onBookmark;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _banner(),
        Transform.translate(
          offset: const Offset(0, -40),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.screenPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppAvatar(name: data.name, imageUrl: data.avatarUrl, size: 84),
                AppSizes.vGapMd,
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        data.name,
                        style: context.text.headlineSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (data.isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.verified_rounded,
                        color: AppColors.info,
                        size: 20,
                      ),
                    ],
                  ],
                ),
                Text(data.headline, style: context.text.bodyMedium),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: AppColors.mutedText,
                    ),
                    const SizedBox(width: 4),
                    Text(data.location, style: context.text.bodySmall),
                    if (data.rating != null) ...[
                      AppSizes.hGapMd,
                      const Icon(
                        Icons.star_rounded,
                        size: 15,
                        color: AppColors.warning,
                      ),
                      Text(
                        ' ${data.rating} (${data.reviewsCount})',
                        style: context.text.bodySmall,
                      ),
                    ],
                  ],
                ),
                AppSizes.vGapLg,
                _actions(context),
                AppSizes.vGapLg,
                if (data.stats.isNotEmpty) _statsCard(context),
                if (data.about.isNotEmpty) ...[
                  AppSizes.vGapLg,
                  const AppSectionHeader(title: 'About'),
                  AppSizes.vGapSm,
                  Text(data.about, style: context.text.bodyMedium),
                ],
                if (data.skills.isNotEmpty) ...[
                  AppSizes.vGapLg,
                  const AppSectionHeader(title: 'Skills & Expertise'),
                  AppSizes.vGapSm,
                  Wrap(
                    spacing: AppSizes.sm,
                    runSpacing: AppSizes.sm,
                    children: [for (final s in data.skills) _chip(context, s)],
                  ),
                ],
                if (reviews.isNotEmpty) ...[
                  AppSizes.vGapLg,
                  const AppSectionHeader(title: 'Reviews'),
                  AppSizes.vGapSm,
                  for (final r in reviews) _review(context, r),
                ],
                AppSizes.vGapXxl,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _banner() => Container(
    height: 150,
    decoration: BoxDecoration(
      gradient: AppColors.primaryGradient,
      image: const DecorationImage(
        image: AssetImage('assets/images/profile_cover.png'),
        fit: BoxFit.cover,
      ),
    ),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.15),
            Colors.black.withValues(alpha: 0.45),
          ],
        ),
      ),
    ),
  );

  Widget _actions(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 430;
        final primary = FilledButton.icon(
          onPressed: onPrimaryAction,
          icon: Icon(data.primaryActionIcon, size: 18),
          label: Text(context.tr(data.primaryActionLabel)),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size.fromHeight(46),
          ),
        );
        final message = OutlinedButton.icon(
          onPressed: onMessage,
          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
          label: Text(context.tr('Message')),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(46),
          ),
        );
        final follow = _iconAction(
          context,
          data.isFollowing
              ? Icons.person_remove_outlined
              : Icons.person_add_alt_1_outlined,
          onFollow,
        );
        final bookmark = _iconAction(
          context,
          data.isSaved
              ? Icons.bookmark_rounded
              : Icons.bookmark_outline_rounded,
          onBookmark,
        );

        if (!compact) {
          return Row(
            children: [
              Expanded(child: primary),
              AppSizes.hGapMd,
              Expanded(child: message),
              AppSizes.hGapMd,
              follow,
              AppSizes.hGapMd,
              bookmark,
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: primary),
                AppSizes.hGapMd,
                Expanded(child: message),
              ],
            ),
            AppSizes.vGapSm,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [follow, AppSizes.hGapMd, bookmark],
            ),
          ],
        );
      },
    );
  }

  Widget _iconAction(
    BuildContext context,
    IconData icon,
    VoidCallback? onTap,
  ) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: context.theme.dividerColor),
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
    ),
    child: IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        size: 20,
        color: icon == Icons.bookmark_rounded ? AppColors.primary : null,
      ),
    ),
  );

  Widget _statsCard(BuildContext context) => AppCard(
    child: Row(
      children: [
        for (final entry in data.stats.entries)
          Expanded(
            child: Column(
              children: [
                Text(entry.value, style: context.text.titleMedium),
                Text(
                  context.tr(entry.key),
                  style: context.text.labelSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
      ],
    ),
  );

  Widget _chip(BuildContext context, String s) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
    ),
    child: Text(
      s,
      style: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    ),
  );

  Widget _review(BuildContext context, Review r) => Padding(
    padding: const EdgeInsets.only(bottom: AppSizes.md),
    child: AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(name: r.authorName, imageUrl: r.authorAvatar, size: 34),
              AppSizes.hGapSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.authorName, style: context.text.titleSmall),
                    Text(r.context, style: context.text.labelSmall),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 15,
                    color: AppColors.warning,
                  ),
                  Text(' ${r.rating}', style: context.text.labelMedium),
                ],
              ),
            ],
          ),
          AppSizes.vGapSm,
          Text(r.comment, style: context.text.bodySmall),
          const SizedBox(height: 4),
          Text(
            Formatters.relative(r.createdAt),
            style: context.text.labelSmall,
          ),
        ],
      ),
    ),
  );
}

class ProfileActions {
  ProfileActions._();

  static void showMore(BuildContext context, ProfileViewData data) =>
      AppActionSheet.show(
        context,
        title: data.name,
        actions: [
          AppAction(
            label: 'Contact Now (Call/Email/WA)',
            icon: Icons.contact_phone_outlined,
            onTap: () => ContactWorkflow.showContactOptions(
              context,
              name: data.name,
              phone: data.phone,
              emailAddress: data.email,
            ),
          ),
          AppAction(
            label: 'Schedule Meeting',
            icon: Icons.event_outlined,
            onTap: () => ContactWorkflow.scheduleMeeting(context, data.name),
          ),
          AppAction(
            label: 'Book Consultation',
            icon: Icons.calendar_today_outlined,
            onTap: () => ContactWorkflow.bookConsultation(context, data.name),
          ),
          AppAction(
            label: 'Voice Call Placeholder',
            icon: Icons.phone_callback_outlined,
            onTap: () =>
                context.showSnack('Voice calling ${data.name} (WebRTC ready)…'),
          ),
          AppAction(
            label: 'Video Call Placeholder',
            icon: Icons.video_call_outlined,
            onTap: () =>
                context.showSnack('Video calling ${data.name} (WebRTC ready)…'),
          ),
          AppAction(
            label: 'Invite ${data.name}',
            icon: Icons.person_add_alt_1_outlined,
            onTap: () => ContactWorkflow.invite(context, data.name),
          ),
          if (data.type == PublicProfileType.freelancer)
            AppAction(
              label: 'Hire Now',
              icon: Icons.handshake_outlined,
              onTap: () => ContactWorkflow.hire(context, data.name),
            ),
          if (data.type == PublicProfileType.investor ||
              data.type == PublicProfileType.founder)
            AppAction(
              label: 'Express Interest',
              icon: Icons.favorite_border_rounded,
              onTap: () => ContactWorkflow.expressInterest(context, data.name),
            ),
          AppAction(
            label: 'Copy Profile Link',
            icon: Icons.link_rounded,
            onTap: () {
              context.showSnack('Profile link copied to clipboard!');
            },
          ),
          if (data.type == PublicProfileType.freelancer)
            AppAction(
              label: 'Download Resume',
              icon: Icons.download_rounded,
              onTap: () =>
                  context.showSnack('Downloading Resume of ${data.name}…'),
            ),
          if (data.type == PublicProfileType.company)
            AppAction(
              label: 'Download Company Profile',
              icon: Icons.download_rounded,
              onTap: () => context.showSnack('Downloading Company Profile…'),
            ),
          if (data.type == PublicProfileType.founder)
            AppAction(
              label: 'Download Pitch Deck',
              icon: Icons.download_rounded,
              onTap: () => context.showSnack('Downloading Pitch Deck…'),
            ),
          AppAction(
            label: 'Download Portfolio',
            icon: Icons.download_rounded,
            onTap: () => context.showSnack('Downloading Portfolio…'),
          ),
          AppAction(
            label: 'Report Profile',
            icon: Icons.flag_outlined,
            isDestructive: true,
            onTap: () =>
                context.showSnack('Report submitted for investigation.'),
          ),
        ],
      );

  static void showQr(BuildContext context, ProfileViewData data) => showDialog(
    context: context,
    builder: (_) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(data.name, style: context.text.titleMedium),
            AppSizes.vGapLg,
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: context.theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: const Icon(Icons.qr_code_2_rounded, size: 150),
            ),
            AppSizes.vGapMd,
            Text('Scan to view public profile', style: context.text.bodySmall),
          ],
        ),
      ),
    ),
  );
}
