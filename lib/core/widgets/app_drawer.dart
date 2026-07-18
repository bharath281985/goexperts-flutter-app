import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_sizes.dart';
import '../../app/router/route_names.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../extensions/context_extensions.dart';
import '../utils/enums.dart';
import 'app_avatar.dart';
import 'app_confirm_dialog.dart';

/// A drawer menu entry.
class DrawerEntry {
  const DrawerEntry(
    this.label,
    this.icon, {
    this.route,
    this.onTap,
    this.badge,
  });
  final String label;
  final IconData icon;
  final String? route;
  final VoidCallback? onTap;
  final int? badge;
}

/// A grouped section of drawer entries.
class DrawerSection {
  const DrawerSection(this.title, this.entries);
  final String title;
  final List<DrawerEntry> entries;
}

/// Role-aware navigation drawer used by all dashboards.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.role,
    this.unreadNotifications = 0,
    this.unreadMessages = 0,
  });

  final UserRole role;
  final int unreadNotifications;
  final int unreadMessages;

  static final _uuidPattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  static String _planLabel(String? plan) {
    final value = plan?.trim();
    if (value == null || value.isEmpty || _uuidPattern.hasMatch(value)) {
      return 'Starter plan';
    }
    final lower = value.toLowerCase();
    return lower.endsWith(' plan') ? value : '$value plan';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc b) => b.state.user);
    return Drawer(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppAvatar(
                        name: user?.fullName ?? 'User',
                        imageUrl: user?.avatarUrl,
                        size: 52,
                      ),
                      AppSizes.hGapMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? context.tr('Guest'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              context.tr(role.label),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppSizes.vGapMd,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.workspace_premium_outlined,
                          size: 15,
                          color: Colors.white,
                        ),
                        AppSizes.hGapSm,
                        Flexible(
                          child: Text(
                            context.tr(_planLabel(user?.subscriptionPlan)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                children: [
                  for (final section in _sections(role)) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.lg,
                        AppSizes.md,
                        AppSizes.lg,
                        AppSizes.xs,
                      ),
                      child: Text(
                        context.tr(section.title).toUpperCase(),
                        style: context.text.labelSmall?.copyWith(
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    for (final e in section.entries)
                      ListTile(
                        dense: true,
                        leading: Icon(
                          e.icon,
                          size: 20,
                          color: AppColors.mutedText,
                        ),
                        title: Text(
                          context.tr(e.label),
                          style: context.text.bodyMedium,
                        ),
                        trailing: e.badge != null && e.badge! > 0
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${e.badge}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              )
                            : null,
                        onTap: () {
                          Navigator.of(context).pop();
                          if (e.onTap != null) {
                            e.onTap!();
                          } else if (e.route != null) {
                            context.push(e.route!);
                          }
                        },
                      ),
                  ],
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.logout_rounded,
                      size: 20,
                      color: AppColors.danger,
                    ),
                    title: Text(
                      context.tr('Log Out'),
                      style: const TextStyle(color: AppColors.danger),
                    ),
                    onTap: () async {
                      final confirm = await AppConfirmDialog.show(
                        context,
                        title: 'Log out?',
                        message:
                            'You will need to sign in again to access your account.',
                        confirmLabel: 'Log Out',
                        isDestructive: true,
                        icon: Icons.logout_rounded,
                      );
                      if (confirm && context.mounted) {
                        context.read<AuthBloc>().add(const AuthLoggedOut());
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DrawerSection> _sections(UserRole role) {
    final common = DrawerSection('Workspace', [
      DrawerEntry(
        'Messages',
        Icons.chat_bubble_outline_rounded,
        route: Routes.messages,
        badge: unreadMessages > 0 ? unreadMessages : null,
      ),
      DrawerEntry('Meetings', Icons.event_outlined, route: Routes.meetings),
      DrawerEntry(
        'Notifications',
        Icons.notifications_outlined,
        route: Routes.notifications,
        badge: unreadNotifications > 0 ? unreadNotifications : null,
      ),
      const DrawerEntry(
        'Bookmarks',
        Icons.bookmark_outline_rounded,
        route: Routes.bookmarks,
      ),
      const DrawerEntry(
        'Wallet',
        Icons.account_balance_wallet_outlined,
        route: Routes.wallet,
      ),
      const DrawerEntry(
        'Subscriptions',
        Icons.workspace_premium_outlined,
        route: Routes.subscriptionsManage,
      ),
    ]);
    const account = DrawerSection('Account', [
      DrawerEntry(
        'Security Center',
        Icons.shield_outlined,
        route: Routes.securityCenter,
      ),
      DrawerEntry('Settings', Icons.settings_outlined, route: Routes.settings),
      DrawerEntry('Support', Icons.help_outline_rounded, route: Routes.support),
    ]);

    switch (role) {
      case UserRole.freelancer:
        return [
          DrawerSection('Freelancer', [
            DrawerEntry(
              'Dashboard',
              Icons.dashboard_outlined,
              route: Routes.freelancerDashboard,
            ),
            DrawerEntry(
              'My Profile',
              Icons.person_outline_rounded,
              route: Routes.freelancerProfile,
            ),
            DrawerEntry(
              'Discover Projects',
              Icons.work_outline_rounded,
              route: Routes.freelancerProjects,
            ),
            DrawerEntry(
              'Proposals',
              Icons.description_outlined,
              route: Routes.freelancerProposals,
            ),
            DrawerEntry(
              'Contracts',
              Icons.assignment_turned_in_outlined,
              route: Routes.freelancerProposals,
            ),
            DrawerEntry(
              'Analytics',
              Icons.insights_outlined,
              route: Routes.freelancerDashboard,
            ),
          ]),
          common,
          account,
        ];
      case UserRole.client:
        return [
          DrawerSection('Business', [
            DrawerEntry(
              'Dashboard',
              Icons.dashboard_outlined,
              route: Routes.clientDashboard,
            ),
            DrawerEntry(
              'Company Profile',
              Icons.business_outlined,
              route: Routes.clientProfile,
            ),
            DrawerEntry(
              'My Projects',
              Icons.work_outline_rounded,
              route: Routes.clientProjects,
            ),
            DrawerEntry(
              'Applications',
              Icons.inbox_outlined,
              route: Routes.clientApplications,
            ),
            DrawerEntry(
              'Create Project',
              Icons.add_box_outlined,
              route: Routes.clientCreateProject,
            ),
            DrawerEntry(
              'Hire Freelancers',
              Icons.groups_outlined,
              route: Routes.clientFreelancers,
            ),
            DrawerEntry(
              'Payments',
              Icons.payments_outlined,
              route: Routes.clientPayments,
            ),
          ]),
          common,
          account,
        ];
      case UserRole.investor:
        return [
          DrawerSection('Investor', [
            DrawerEntry(
              'Dashboard',
              Icons.dashboard_outlined,
              route: Routes.investorDashboard,
            ),
            DrawerEntry(
              'Investor Profile',
              Icons.person_outline_rounded,
              route: Routes.investorProfile,
            ),
            DrawerEntry(
              'Discover Startups',
              Icons.rocket_launch_outlined,
              route: Routes.investorStartups,
            ),
            DrawerEntry(
              'Deal Rooms',
              Icons.handshake_outlined,
              route: Routes.investorDeals,
            ),
            DrawerEntry(
              'Portfolio',
              Icons.pie_chart_outline_rounded,
              route: Routes.investorPortfolio,
            ),
          ]),
          common,
          account,
        ];
      case UserRole.founder:
        return [
          DrawerSection('Founder', [
            DrawerEntry(
              'Dashboard',
              Icons.dashboard_outlined,
              route: Routes.founderDashboard,
            ),
            DrawerEntry(
              'Founder Profile',
              Icons.person_outline_rounded,
              route: Routes.founderProfile,
            ),
            DrawerEntry(
              'My Startup',
              Icons.rocket_launch_outlined,
              route: Routes.founderStartup,
            ),
            DrawerEntry(
              'Investors',
              Icons.trending_up_rounded,
              route: Routes.founderInvestors,
            ),
            DrawerEntry(
              'Funding',
              Icons.savings_outlined,
              route: Routes.founderFunding,
            ),
          ]),
          common,
          account,
        ];
    }
  }
}
