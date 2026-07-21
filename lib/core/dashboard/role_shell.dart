import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/dependency_injection/service_locator.dart';
import '../../features/client_dashboard/presentation/pages/client_home_page.dart';
import '../../features/founder_dashboard/presentation/pages/founder_home_page.dart';
import '../../features/freelancer_dashboard/domain/repositories/freelancer_repository.dart';
import '../../features/freelancer_dashboard/presentation/pages/freelancer_home_page.dart';
import '../../features/freelancer_dashboard/presentation/pages/freelancers_list_view.dart';
import '../../features/investor_dashboard/domain/repositories/investor_repository.dart';
import '../../features/investor_dashboard/presentation/pages/deals_list_view.dart';
import '../../features/investor_dashboard/presentation/pages/investor_home_page.dart';
import '../../features/investor_dashboard/presentation/pages/investors_list_view.dart';
import '../../features/meetings/domain/repositories/meeting_repository.dart';
import '../../features/meetings/presentation/pages/meetings_list_view.dart';
import '../../features/messages/domain/repositories/message_repository.dart';
import '../../features/messages/presentation/pages/conversations_list_view.dart';
import '../../features/profile/presentation/pages/my_profile_page.dart';
import '../../features/projects/domain/repositories/project_repository.dart';
import '../../features/projects/presentation/pages/projects_list_view.dart';
import '../../features/startup_ideas/domain/repositories/startup_repository.dart';
import '../../features/startup_ideas/presentation/pages/startups_list_view.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/wallet/presentation/pages/wallet_page.dart';
import '../network/api_client_helper.dart';
import '../extensions/context_extensions.dart';
import '../utils/enums.dart';
import '../widgets/app_bottom_navigation.dart';
import '../widgets/app_drawer.dart';
import 'dashboard_cubit.dart';

/// A single tab within a role shell.
class _Tab {
  const _Tab(this.item, this.body, {this.title});
  final AppNavItem item;
  final Widget body;
  final String? title;
}

/// The stateful shell hosting bottom navigation, drawer and role tabs.
class RoleShell extends StatefulWidget {
  const RoleShell({super.key, required this.role, this.initialIndex = 0});
  final UserRole role;
  final int initialIndex;

  @override
  State<RoleShell> createState() => _RoleShellState();
}

class _RoleShellState extends State<RoleShell> {
  late int _index = widget.initialIndex;
  int _walletRefreshToken = 0;
  int _messagesRefreshToken = 0;

  DashboardCubit _cubit() => DashboardCubit(
    role: widget.role,
    projectRepository: sl<ProjectRepository>(),
    freelancerRepository: sl<FreelancerRepository>(),
    startupRepository: sl<StartupRepository>(),
    investorRepository: sl<InvestorRepository>(),
    meetingRepository: sl<MeetingRepository>(),
    messageRepository: sl<MessageRepository>(),
    walletRepository: sl<WalletRepository>(),
    apiClient: sl<ApiClientHelper>(),
  )..load();

  List<_Tab> _buildTabs({Future<void> Function()? onMessagesRefreshed}) {
    switch (widget.role) {
      case UserRole.freelancer:
        return [
          const _Tab(
            AppNavItem(
              label: 'Home',
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
            ),
            FreelancerHomePage(),
          ),
          const _Tab(
            AppNavItem(
              label: 'Projects',
              icon: Icons.work_outline_rounded,
              activeIcon: Icons.work_rounded,
            ),
            ProjectsListView(),
            title: 'Discover Projects',
          ),
          _Tab(
            AppNavItem(
              label: 'Chats',
              icon: Icons.chat_bubble_outline_rounded,
              activeIcon: Icons.chat_bubble_rounded,
            ),
            ConversationsListView(
              refreshToken: _messagesRefreshToken,
              onRefreshed: onMessagesRefreshed,
            ),
            title: 'Messages',
          ),
          _Tab(
            AppNavItem(
              label: 'Wallet',
              icon: Icons.account_balance_wallet_outlined,
              activeIcon: Icons.account_balance_wallet_rounded,
            ),
            WalletPage(embedded: true, refreshToken: _walletRefreshToken),
            title: 'Wallet',
          ),
          const _Tab(
            AppNavItem(
              label: 'Profile',
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
            ),
            MyProfilePage(),
          ),
        ];
      case UserRole.client:
        return [
          const _Tab(
            AppNavItem(
              label: 'Home',
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
            ),
            ClientHomePage(),
          ),
          const _Tab(
            AppNavItem(
              label: 'Projects',
              icon: Icons.work_outline_rounded,
              activeIcon: Icons.work_rounded,
            ),
            ProjectsListView(),
            title: 'My Projects',
          ),
          const _Tab(
            AppNavItem(
              label: 'Talent',
              icon: Icons.groups_outlined,
              activeIcon: Icons.groups_rounded,
            ),
            FreelancersListView(),
            title: 'Hire Freelancers',
          ),
          _Tab(
            AppNavItem(
              label: 'Chats',
              icon: Icons.chat_bubble_outline_rounded,
              activeIcon: Icons.chat_bubble_rounded,
            ),
            ConversationsListView(
              refreshToken: _messagesRefreshToken,
              onRefreshed: onMessagesRefreshed,
            ),
            title: 'Messages',
          ),
          const _Tab(
            AppNavItem(
              label: 'Profile',
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
            ),
            MyProfilePage(),
          ),
        ];
      case UserRole.investor:
        return [
          const _Tab(
            AppNavItem(
              label: 'Home',
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
            ),
            InvestorHomePage(),
          ),
          _Tab(
            AppNavItem(
              label: 'Startups',
              icon: Icons.rocket_launch_outlined,
              activeIcon: Icons.rocket_launch_rounded,
            ),
            StartupsListView(),
            title: 'Discover Startups',
          ),
          _Tab(
            AppNavItem(
              label: 'Deals',
              icon: Icons.handshake_outlined,
              activeIcon: Icons.handshake_rounded,
            ),
            DealsListView(),
            title: 'Deal Rooms',
          ),
          _Tab(
            AppNavItem(
              label: 'Meetings',
              icon: Icons.event_outlined,
              activeIcon: Icons.event_rounded,
            ),
            MeetingsListView(),
            title: 'Meetings',
          ),
          _Tab(
            AppNavItem(
              label: 'Profile',
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
            ),
            MyProfilePage(),
          ),
        ];
      case UserRole.founder:
        return [
          _Tab(
            AppNavItem(
              label: 'Home',
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
            ),
            FounderHomePage(),
          ),
          const _Tab(
            AppNavItem(
              label: 'Startup',
              icon: Icons.rocket_launch_outlined,
              activeIcon: Icons.rocket_launch_rounded,
            ),
            StartupsListView(isFounderOverride: true),
            title: 'My Startup Ideas',
          ),
          const _Tab(
            AppNavItem(
              label: 'Investors',
              icon: Icons.trending_up_rounded,
              activeIcon: Icons.trending_up_rounded,
            ),
            InvestorsListView(),
            title: 'Investors',
          ),
          _Tab(
            AppNavItem(
              label: 'Chats',
              icon: Icons.chat_bubble_outline_rounded,
              activeIcon: Icons.chat_bubble_rounded,
            ),
            ConversationsListView(
              refreshToken: _messagesRefreshToken,
              onRefreshed: onMessagesRefreshed,
            ),
            title: 'Messages',
          ),
          const _Tab(
            AppNavItem(
              label: 'Profile',
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
            ),
            MyProfilePage(),
          ),
        ];
    }
  }

  List<AppNavItem> _navItems(List<_Tab> tabs, int unreadMessages) {
    return [
      for (final tab in tabs)
        AppNavItem(
          label: tab.item.label,
          icon: tab.item.icon,
          activeIcon: tab.item.activeIcon,
          badgeText: tab.item.label == 'Chats'
              ? (unreadMessages == 0
                    ? null
                    : (unreadMessages > 99 ? '99+' : '$unreadMessages'))
              : null,
        ),
    ];
  }

  void _selectTab(BuildContext dashboardContext, List<_Tab> tabs, int index) {
    setState(() {
      if (tabs[index].item.label == 'Wallet') {
        _walletRefreshToken++;
      }
      if (tabs[index].item.label == 'Chats') {
        _messagesRefreshToken++;
        dashboardContext.read<DashboardCubit>().refresh();
      }
      _index = index;
    });
  }

  Future<void> _showExitDialog() async {
    if (!mounted) return;
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.tr('Exit app?')),
        content: Text(dialogContext.tr('Do you want to close the app?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.tr('Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(dialogContext.tr('Exit')),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (shouldExit == true) exit(0);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _showExitDialog();
      },
      child: BlocProvider<DashboardCubit>(
        create: (_) => _cubit(),
        child: BlocBuilder<DashboardCubit, DashboardState>(
          buildWhen: (prev, next) =>
              prev.unreadMessagesCount != next.unreadMessagesCount ||
              prev.unreadNotificationsCount != next.unreadNotificationsCount,
          builder: (context, state) {
            final tabs = _buildTabs(
              onMessagesRefreshed: () =>
                  context.read<DashboardCubit>().refresh(),
            );
            final current = tabs[_index];
            return Scaffold(
              drawer: AppDrawer(
                role: widget.role,
                unreadNotifications: state.unreadNotificationsCount,
                unreadMessages: state.unreadMessagesCount,
              ),
              appBar: current.title == null
                  ? null
                  : AppBar(title: Text(context.tr(current.title!))),
              body: IndexedStack(
                index: _index,
                children: [for (final t in tabs) t.body],
              ),
              bottomNavigationBar: AppBottomNavigation(
                items: _navItems(tabs, state.unreadMessagesCount),
                currentIndex: _index,
                onTap: (i) => _selectTab(context, tabs, i),
              ),
            );
          },
        ),
      ),
    );
  }
}
