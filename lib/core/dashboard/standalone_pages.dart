import 'package:flutter/material.dart';
import '../../features/founder_dashboard/presentation/pages/my_startup_view.dart';
import '../../features/freelancer_dashboard/presentation/pages/freelancers_list_view.dart';
import '../../features/investor_dashboard/presentation/pages/deals_list_view.dart';
import '../../features/investor_dashboard/presentation/pages/investors_list_view.dart';
import '../../features/investor_dashboard/presentation/pages/portfolio_list_view.dart';
import '../../features/meetings/presentation/pages/meetings_list_view.dart';
import '../../features/messages/presentation/pages/conversations_list_view.dart';
import '../../features/profile/presentation/pages/my_profile_page.dart';
import '../../features/projects/presentation/pages/projects_list_view.dart';
import '../../features/proposals/presentation/pages/proposals_list_view.dart';
import '../../features/startup_ideas/presentation/pages/startups_list_view.dart';
import '../widgets/app_scaffold.dart';

/// Thin standalone pages that wrap the embeddable catalog views with an
/// app bar, used when reached from the drawer / deep links (not as tabs).
AppScaffold _wrap(String title, Widget body) => AppScaffold(
  appBar: AppBar(title: Text(title)),
  body: body,
);

class ProjectsStandalonePage extends StatelessWidget {
  const ProjectsStandalonePage({super.key});
  @override
  Widget build(BuildContext context) =>
      _wrap('Projects', const ProjectsListView());
}

class ProposalsStandalonePage extends StatelessWidget {
  const ProposalsStandalonePage({super.key});
  @override
  Widget build(BuildContext context) =>
      _wrap('Proposals', const ProposalsListView());
}

class FreelancersStandalonePage extends StatelessWidget {
  const FreelancersStandalonePage({super.key});
  @override
  Widget build(BuildContext context) =>
      _wrap('Freelancers', const FreelancersListView());
}

class StartupsStandalonePage extends StatelessWidget {
  const StartupsStandalonePage({super.key});
  @override
  Widget build(BuildContext context) =>
      _wrap('Startups', const StartupsListView());
}

class InvestorsStandalonePage extends StatelessWidget {
  const InvestorsStandalonePage({super.key});
  @override
  Widget build(BuildContext context) =>
      _wrap('Investors', const InvestorsListView());
}

class DealsStandalonePage extends StatelessWidget {
  const DealsStandalonePage({super.key});
  @override
  Widget build(BuildContext context) =>
      _wrap('Deal Rooms', const DealsListView());
}

class PortfolioStandalonePage extends StatelessWidget {
  const PortfolioStandalonePage({super.key});
  @override
  Widget build(BuildContext context) =>
      _wrap('Portfolio', const PortfolioListView());
}

class MeetingsStandalonePage extends StatelessWidget {
  const MeetingsStandalonePage({super.key});
  @override
  Widget build(BuildContext context) =>
      _wrap('Meetings', const MeetingsListView());
}

class MessagesStandalonePage extends StatelessWidget {
  const MessagesStandalonePage({super.key});
  @override
  Widget build(BuildContext context) =>
      _wrap('Messages', const ConversationsListView());
}

class MyStartupStandalonePage extends StatelessWidget {
  const MyStartupStandalonePage({super.key});
  @override
  Widget build(BuildContext context) =>
      _wrap('My Startup', const MyStartupView());
}

class FundingStandalonePage extends StatelessWidget {
  const FundingStandalonePage({super.key});
  @override
  Widget build(BuildContext context) => _wrap('Funding', const MyStartupView());
}

class ProfileStandalonePage extends StatelessWidget {
  const ProfileStandalonePage({super.key});
  @override
  Widget build(BuildContext context) =>
      const AppScaffold(constrainWidth: true, body: MyProfilePage());
}
