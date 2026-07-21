import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_sizes.dart';
import '../../../../core/dashboard/analytics_page.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_confirm_dialog.dart';
import '../../../../core/widgets/app_gradient_header.dart';
import '../../../../core/widgets/app_list_tile.dart';
import '../../../../app/dependency_injection/service_locator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../freelancer_dashboard/presentation/pages/freelancer_subpages.dart';
import '../../domain/repositories/review_repository.dart';
import 'my_reviews_page.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  double _rating = 0.0;
  int _reviewsCount = 0;
  bool _loadingAverage = true;

  @override
  void initState() {
    super.initState();
    _fetchAverage();
    context.read<AuthBloc>().add(const AuthProfileRefreshed());
  }

  Future<void> _fetchAverage() async {
    final repo = sl<ReviewRepository>();
    final result = await repo.getReviewsAverage();
    if (!mounted) return;
    result.fold(
      (f) {
        setState(() {
          _loadingAverage = false;
        });
      },
      (data) {
        final avgRating =
            data['averageRating'] ??
            data['average_rating'] ??
            data['average'] ??
            data['rating'] ??
            0.0;
        final totalReviews =
            data['totalReviews'] ??
            data['total_reviews'] ??
            data['total'] ??
            data['count'] ??
            0;
        setState(() {
          _rating = double.tryParse(avgRating.toString()) ?? 0.0;
          _reviewsCount = int.tryParse(totalReviews.toString()) ?? 0;
          _loadingAverage = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    final user = state.user;
    final role = user?.role ?? UserRole.freelancer;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        AppGradientHeader(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    context.tr('My Profile'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => context.push(Routes.settings),
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              AppSizes.vGapMd,
              Row(
                children: [
                  AppAvatar(
                    name: user?.fullName ?? 'User',
                    imageUrl: user?.avatarUrl,
                    size: 64,
                  ),
                  AppSizes.hGapMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user?.fullName ?? 'Guest',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (user?.isVerified ?? false) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          user?.headline ?? role.label,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: _stat(
                        context,
                        _loadingAverage ? '…' : _rating.toStringAsFixed(1),
                        'Rating',
                      ),
                    ),
                    _divider(context),
                    Expanded(
                      child: _stat(
                        context,
                        _loadingAverage ? '…' : _reviewsCount.toString(),
                        'Reviews',
                      ),
                    ),
                    _divider(context),
                    Expanded(child: _stat(context, '1.2K', 'Followers')),
                    _divider(context),
                    Expanded(child: _stat(context, '94', 'Projects')),
                  ],
                ),
              ),
              AppSizes.vGapLg,
              _group(context, 'Profile', [
                _tile(context, Icons.edit_outlined, 'Edit Profile', () async {
                  switch (role) {
                    case UserRole.investor:
                      await context.push(Routes.investorProfile);
                      break;
                    case UserRole.founder:
                      await context.push(Routes.founderProfile);
                      break;
                    case UserRole.client:
                      await context.push(Routes.clientProfile);
                      break;
                    case UserRole.freelancer:
                      context.push(Routes.freelancerProfile);
                      break;
                  }
                  if (context.mounted) {
                    context.read<AuthBloc>().add(const AuthProfileRefreshed());
                  }
                }),
                _tile(
                  context,
                  Icons.public_rounded,
                  'View Public Profile',
                  () => _viewPublic(context, role, user?.id ?? 'me'),
                ),
                if (role == UserRole.freelancer || role == UserRole.investor)
                  _tile(context, Icons.collections_outlined, 'Portfolio', () {
                    if (role == UserRole.investor) {
                      context.push(Routes.investorPortfolio);
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FreelancerPortfolioPage(),
                        ),
                      );
                    }
                  }),
                _tile(
                  context,
                  Icons.star_outline_rounded,
                  'Reviews',
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MyReviewsPage()),
                  ),
                ),
                _tile(context, Icons.insights_outlined, 'Analytics', () {
                  switch (role) {
                    case UserRole.investor:
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const RoleAnalyticsPage(role: UserRole.investor),
                        ),
                      );
                      break;
                    case UserRole.founder:
                      context.push(Routes.founderAnalytics);
                      break;
                    case UserRole.client:
                      context.push(Routes.clientAnalytics);
                      break;
                    case UserRole.freelancer:
                      context.push(Routes.freelancerAnalytics);
                      break;
                  }
                }),
              ]),
              AppSizes.vGapLg,
              _group(context, 'Account', [
                _tile(
                  context,
                  Icons.workspace_premium_outlined,
                  'Subscription',
                  () => context.push(Routes.subscriptionsManage),
                ),
                _tile(
                  context,
                  Icons.account_balance_wallet_outlined,
                  'Wallet',
                  () => context.push(Routes.wallet),
                ),
                _tile(
                  context,
                  Icons.shield_outlined,
                  'Security Center',
                  () => context.push(Routes.securityCenter),
                ),
                _tile(
                  context,
                  Icons.bookmark_outline_rounded,
                  'Bookmarks',
                  () => context.push(Routes.bookmarks),
                ),
                _tile(
                  context,
                  Icons.settings_outlined,
                  'Settings',
                  () => context.push(Routes.settings),
                ),
                _tile(
                  context,
                  Icons.help_outline_rounded,
                  'Support',
                  () => context.push(Routes.support),
                ),
              ]),
              AppSizes.vGapLg,
              AppCard(
                onTap: () async {
                  final confirm = await AppConfirmDialog.show(
                    context,
                    title: 'Log out?',
                    message: 'You will need to sign in again.',
                    confirmLabel: 'Log Out',
                    isDestructive: true,
                    icon: Icons.logout_rounded,
                  );
                  if (confirm && context.mounted) {
                    context.read<AuthBloc>().add(const AuthLoggedOut());
                  }
                },
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, color: AppColors.danger),
                    const SizedBox(width: AppSizes.md),
                    Text(
                      context.tr('Log Out'),
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _viewPublic(BuildContext context, UserRole role, String id) {
    switch (role) {
      case UserRole.freelancer:
        context.push('${Routes.publicFreelancer}/$id');
        break;
      case UserRole.client:
        context.push('${Routes.publicCompany}/$id');
        break;
      case UserRole.investor:
        context.push('${Routes.publicInvestor}/$id');
        break;
      case UserRole.founder:
        context.push('${Routes.publicFounder}/$id');
        break;
    }
  }

  Widget _stat(BuildContext context, String value, String label) => Column(
    children: [
      Text(value, style: context.text.titleMedium),
      Text(context.tr(label), style: context.text.labelSmall),
    ],
  );

  Widget _divider(BuildContext context) =>
      Container(width: 1, height: 28, color: context.theme.dividerColor);

  Widget _group(BuildContext context, String title, List<Widget> children) =>
      AppCard(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.sm,
                AppSizes.md,
                AppSizes.xs,
              ),
              child: Text(
                context.tr(title).toUpperCase(),
                style: context.text.labelSmall?.copyWith(letterSpacing: 1),
              ),
            ),
            ...children,
          ],
        ),
      );

  Widget _tile(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) => AppListTile(title: label, leadingIcon: icon, onTap: onTap);
}
