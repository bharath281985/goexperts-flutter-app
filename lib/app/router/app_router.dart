import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/dashboard/role_shell.dart';
import '../../core/storage/local_storage.dart';
import '../../app/dependency_injection/service_locator.dart';
import '../../core/dashboard/standalone_pages.dart';
import '../../core/utils/enums.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/email_verification_page.dart';
import '../../features/auth/presentation/models/otp_verification_args.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/phone_verification_page.dart';
import '../../features/auth/presentation/pages/profile_completion_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/success_page.dart';
import '../../features/catalog/presentation/pages/business_plan_page.dart';
import '../../features/catalog/presentation/pages/category_details_page.dart';
import '../../features/catalog/presentation/pages/certificate_details_page.dart';
import '../../features/catalog/presentation/pages/opportunity_details_page.dart';
import '../../features/catalog/presentation/pages/pitch_deck_page.dart';
import '../../features/catalog/presentation/pages/service_details_page.dart';
import '../../features/catalog/presentation/pages/technology_details_page.dart';
import '../../features/profile/presentation/pages/review_details_page.dart';
import '../../features/projects/presentation/pages/contract_details_page.dart';
import '../../features/wallet/presentation/pages/invoice_details_page.dart';
import '../../features/wallet/presentation/pages/transaction_details_page.dart';
import '../../features/applications/presentation/pages/apply_form_page.dart';
import '../../features/invitations/presentation/pages/invitations_page.dart';
import '../../features/documents/presentation/pages/document_viewer_page.dart';
import '../../features/meetings/presentation/pages/calendar_page.dart';
import '../../core/dashboard/analytics_page.dart';
import '../../features/freelancer_dashboard/presentation/pages/freelancer_subpages.dart';
import '../../features/client_dashboard/presentation/pages/client_subpages.dart';
import '../../features/client_dashboard/presentation/pages/client_blocker_pages.dart';
import '../../features/investor_dashboard/presentation/pages/investor_subpages.dart';
import '../../features/investor_dashboard/presentation/pages/investor_live_pages.dart';
import '../../features/founder_dashboard/presentation/pages/founder_subpages.dart';
import '../../features/founder_dashboard/presentation/pages/founder_live_pages.dart';
import '../../features/client_dashboard/presentation/pages/create_project_page.dart';
import '../../features/meetings/presentation/pages/meeting_details_page.dart';
import '../../features/messages/domain/entities/conversation.dart';
import '../../features/messages/presentation/pages/chat_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/presentation/pages/public_profile_page.dart';
import '../../features/profile/presentation/pages/role_profile_edit_pages.dart';
import '../../features/projects/presentation/pages/project_details_page.dart';
import '../../features/proposals/presentation/pages/proposal_details_page.dart';
import '../../features/role_selection/presentation/pages/role_selection_page.dart';
import '../../features/settings/presentation/pages/legal_document_page.dart';
import '../../features/settings/presentation/pages/bookmarks_page.dart';
import '../../features/settings/presentation/pages/change_password_page.dart';
import '../../features/settings/presentation/pages/global_search_page.dart';
import '../../features/settings/presentation/pages/security_center_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/startup_ideas/presentation/pages/startup_details_page.dart';
import '../../features/subscriptions/presentation/pages/current_subscription_page.dart';
import '../../features/subscriptions/presentation/pages/subscription_selection_page.dart';
import '../../features/support/presentation/pages/support_page.dart';
import '../../features/wallet/presentation/pages/wallet_page.dart';
import 'route_names.dart';

/// Bridges a Bloc stream to a [Listenable] so GoRouter re-evaluates redirects.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

String dashboardPathFor(UserRole role) {
  switch (role) {
    case UserRole.freelancer:
      return Routes.freelancerDashboard;
    case UserRole.client:
      return Routes.clientDashboard;
    case UserRole.investor:
      return Routes.investorDashboard;
    case UserRole.founder:
      return Routes.founderDashboard;
  }
}

const _publicRoutes = {
  Routes.splash,
  Routes.onboarding,
  Routes.login,
  Routes.signup,
  Routes.forgotPassword,
  Routes.emailVerification,
  Routes.phoneVerification,
  Routes.otp,
  Routes.resetPassword,
  Routes.privacyPolicy,
  Routes.termsOfService,
};

const _onboardingRoutes = {
  Routes.roleSelection,
  Routes.profileCompletion,
  Routes.subscription,
};

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final auth = authBloc.state;
      final loc = state.matchedLocation;
      final isPublic = _publicRoutes.contains(loc);

      // While unknown, stay on splash.
      if (auth.status == AuthStatus.unknown) {
        return loc == Routes.splash ? null : Routes.splash;
      }

      final authed = auth.status == AuthStatus.authenticated;

      if (!authed) {
        if (auth.pendingSignup != null) {
          if (loc == Routes.roleSelection || loc == Routes.signup) return null;
          return '${Routes.roleSelection}?from=signup';
        }
        if (loc == Routes.splash) {
          final seen = sl<LocalStorage>().getBool(LocalStorage.kOnboardingSeen);
          return seen ? Routes.login : Routes.onboarding;
        }
        return isPublic ? null : Routes.login;
      }

      // Authenticated — enforce onboarding completeness.
      if (!auth.hasRole) {
        return loc == Routes.roleSelection ? null : Routes.roleSelection;
      }
      if (!auth.isProfileComplete) {
        return loc == Routes.profileCompletion
            ? null
            : Routes.profileCompletion;
      }
      if (auth.needsSubscription) {
        return loc == Routes.subscription ? null : Routes.subscription;
      }

      // Fully onboarded — keep them out of auth/onboarding routes.
      if (isPublic || _onboardingRoutes.contains(loc)) {
        return dashboardPathFor(auth.user!.role!);
      }
      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, __) => const SplashPage()),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(path: Routes.login, builder: (_, __) => const LoginPage()),
      GoRoute(path: Routes.signup, builder: (_, __) => const SignupPage()),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (_, __) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: Routes.emailVerification,
        builder: (_, __) => const EmailVerificationPage(),
      ),
      GoRoute(
        path: Routes.phoneVerification,
        builder: (_, __) => const PhoneVerificationPage(),
      ),
      GoRoute(
        path: Routes.otp,
        builder: (_, s) {
          final extra = s.extra;
          if (extra is OtpVerificationArgs) {
            return OtpVerificationPage(args: extra);
          }
          return OtpVerificationPage(
            args: OtpVerificationArgs(destination: extra as String? ?? ''),
          );
        },
      ),
      GoRoute(
        path: Routes.resetPassword,
        builder: (_, s) => ResetPasswordPage(
          email: (s.extra as String?) ?? s.uri.queryParameters['email'] ?? '',
        ),
      ),
      GoRoute(
        path: Routes.authSuccess,
        builder: (_, s) =>
            SuccessPage(args: (s.extra as SuccessArgs?) ?? const SuccessArgs()),
      ),
      GoRoute(
        path: Routes.roleSelection,
        builder: (_, s) => RoleSelectionPage(
          fromSignup:
              s.uri.queryParameters['from'] == 'signup' ||
              authBloc.state.pendingSignup != null,
        ),
      ),
      GoRoute(
        path: Routes.profileCompletion,
        builder: (_, __) => const ProfileCompletionPage(),
      ),
      GoRoute(
        path: Routes.subscription,
        builder: (_, __) => const SubscriptionSelectionPage(),
      ),

      // Dashboards
      GoRoute(
        path: Routes.freelancerDashboard,
        builder: (_, __) => const RoleShell(role: UserRole.freelancer),
      ),
      GoRoute(
        path: Routes.clientDashboard,
        builder: (_, __) => const RoleShell(role: UserRole.client),
      ),
      GoRoute(
        path: Routes.investorDashboard,
        builder: (_, __) => const RoleShell(role: UserRole.investor),
      ),
      GoRoute(
        path: Routes.founderDashboard,
        builder: (_, __) => const RoleShell(role: UserRole.founder),
      ),

      // Freelancer standalone
      GoRoute(
        path: Routes.freelancerProjects,
        builder: (_, __) => const ProjectsStandalonePage(),
      ),
      GoRoute(
        path: Routes.freelancerProposals,
        builder: (_, __) => const ProposalsStandalonePage(),
      ),
      GoRoute(
        path: Routes.freelancerProfile,
        builder: (_, __) => const FreelancerEditProfilePage(),
      ),
      GoRoute(
        path: Routes.freelancerWallet,
        builder: (_, __) => const WalletPage(),
      ),

      // Client standalone
      GoRoute(
        path: Routes.clientProjects,
        builder: (_, __) => const ProjectsStandalonePage(),
      ),
      GoRoute(
        path: Routes.clientCreateProject,
        builder: (_, s) =>
            CreateProjectPage(projectId: s.uri.queryParameters['projectId']),
      ),
      GoRoute(
        path: Routes.clientFreelancers,
        builder: (_, __) => const FreelancersStandalonePage(),
      ),
      GoRoute(
        path: Routes.clientPayments,
        builder: (_, __) => const WalletPage(),
      ),
      GoRoute(
        path: Routes.clientProfile,
        builder: (_, __) => const ClientEditProfilePage(),
      ),

      // Investor standalone
      GoRoute(
        path: Routes.investorStartups,
        builder: (_, __) => const StartupsStandalonePage(),
      ),
      GoRoute(
        path: Routes.investorDeals,
        builder: (_, __) => const DealsStandalonePage(),
      ),
      GoRoute(
        path: Routes.investorPortfolio,
        builder: (_, __) => const PortfolioStandalonePage(),
      ),
      GoRoute(
        path: Routes.investorProfile,
        builder: (_, __) => const InvestorProfilePage(),
      ),

      // Founder standalone
      GoRoute(
        path: Routes.founderStartup,
        builder: (_, s) =>
            MyStartupStandalonePage(startupId: s.uri.queryParameters['id']),
      ),
      GoRoute(
        path: Routes.founderListStartup,
        builder: (_, __) =>
            const RoleShell(role: UserRole.founder, initialIndex: 1),
      ),
      GoRoute(
        path: Routes.founderInvestors,
        builder: (_, __) => const InvestorsStandalonePage(),
      ),
      GoRoute(
        path: Routes.founderFunding,
        builder: (_, __) => const FounderFundingLivePage(),
      ),
      GoRoute(
        path: Routes.founderProfile,
        builder: (_, __) => const FounderProfileLivePage(),
      ),

      // Common
      GoRoute(
        path: Routes.messages,
        builder: (_, __) => const MessagesStandalonePage(),
      ),
      GoRoute(
        path: Routes.meetings,
        builder: (_, __) => const MeetingsStandalonePage(),
      ),
      GoRoute(
        path: Routes.notifications,
        builder: (_, __) => const NotificationsPage(),
      ),
      GoRoute(path: Routes.settings, builder: (_, __) => const SettingsPage()),
      GoRoute(path: Routes.support, builder: (_, __) => const SupportPage()),
      GoRoute(
        path: Routes.privacyPolicy,
        builder: (_, __) => LegalDocumentPage.privacy(),
      ),
      GoRoute(
        path: Routes.termsOfService,
        builder: (_, __) => LegalDocumentPage.terms(),
      ),
      GoRoute(
        path: Routes.search,
        builder: (_, __) => const GlobalSearchPage(),
      ),
      GoRoute(
        path: Routes.bookmarks,
        builder: (_, __) => const BookmarksPage(),
      ),
      GoRoute(path: Routes.wallet, builder: (_, __) => const WalletPage()),
      GoRoute(
        path: Routes.securityCenter,
        builder: (_, __) => const SecurityCenterPage(),
      ),
      GoRoute(
        path: Routes.changePassword,
        builder: (_, __) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: Routes.subscriptionsManage,
        builder: (_, __) => const CurrentSubscriptionPage(),
      ),

      // Detail / deep-link routes
      GoRoute(
        path: '${Routes.chat}/:id',
        builder: (_, s) {
          final id = s.pathParameters['id']!;
          Conversation? conversation = s.extra as Conversation?;
          final qName = s.uri.queryParameters['name'];
          final qAvatar = s.uri.queryParameters['avatarUrl'];
          if (conversation == null && qName != null) {
            conversation = Conversation(
              id: id,
              name: qName,
              avatarUrl: qAvatar,
              lastMessage: '',
              lastMessageAt: DateTime.now(),
              unreadCount: 0,
              isOnline: true,
            );
          }
          return ChatPage(conversationId: id, conversation: conversation);
        },
      ),
      GoRoute(
        path: '${Routes.projectDetails}/:id',
        builder: (_, s) => ProjectDetailsPage(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '${Routes.startupDetails}/:id',
        builder: (_, s) => StartupDetailsPage(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '${Routes.proposalDetails}/:id',
        builder: (_, s) => ProposalDetailsPage(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '${Routes.meetingDetails}/:id',
        builder: (_, s) => MeetingDetailsPage(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '${Routes.contractDetails}/:id',
        builder: (_, s) => ContractDetailsPage(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '${Routes.invoiceDetails}/:id',
        builder: (_, s) => InvoiceDetailsPage(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '${Routes.transactionDetails}/:id',
        builder: (_, s) => TransactionDetailsPage(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '${Routes.certificateDetails}/:id',
        builder: (_, s) => CertificateDetailsPage(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '${Routes.reviewDetails}/:id',
        builder: (_, s) => ReviewDetailsPage(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '${Routes.opportunityDetails}/:id',
        builder: (_, s) => OpportunityDetailsPage(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '${Routes.businessPlanDetails}/:id',
        builder: (_, s) => BusinessPlanPage(startupId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '${Routes.pitchDeckDetails}/:id',
        builder: (_, s) => PitchDeckPage(startupId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '${Routes.serviceDetails}/:id',
        builder: (_, s) => ServiceDetailsPage(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '${Routes.technologyDetails}/:id',
        builder: (_, s) => TechnologyDetailsPage(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '${Routes.categoryDetails}/:id',
        builder: (_, s) => CategoryDetailsPage(id: s.pathParameters['id']!),
      ),
      GoRoute(
        path: Routes.apply,
        builder: (_, s) => ApplyFormPage(
          type: s.uri.queryParameters['type'] ?? 'Project',
          targetName: s.uri.queryParameters['name'],
          projectId: s.uri.queryParameters['projectId'],
          proposalId: s.uri.queryParameters['proposalId'],
          initialBid: s.uri.queryParameters['bid'],
          initialCover: s.uri.queryParameters['cover'],
          initialDeliveryDays: s.uri.queryParameters['deliveryDays'],
        ),
      ),
      GoRoute(
        path: Routes.invitations,
        builder: (_, __) => const InvitationsPage(),
      ),
      GoRoute(path: Routes.calendar, builder: (_, __) => const CalendarPage()),
      GoRoute(
        path: Routes.documentViewer,
        builder: (_, s) => DocumentViewerPage(
          type: s.uri.queryParameters['type'] ?? 'PDF',
          name: s.uri.queryParameters['name'],
          url: s.uri.queryParameters['url'],
        ),
      ),

      // Role sub-pages — Freelancer
      GoRoute(
        path: Routes.freelancerContracts,
        builder: (_, __) => const FreelancerContractsPage(),
      ),
      GoRoute(
        path: Routes.freelancerTasks,
        builder: (_, __) => const FreelancerTasksPage(),
      ),
      GoRoute(
        path: Routes.freelancerReviews,
        builder: (_, __) => const FreelancerReviewsPage(),
      ),
      GoRoute(
        path: Routes.freelancerCertificates,
        builder: (_, __) => const FreelancerCertificatesPage(),
      ),
      GoRoute(
        path: Routes.freelancerSkills,
        builder: (_, __) => const FreelancerSkillsPage(),
      ),
      GoRoute(
        path: Routes.freelancerExperience,
        builder: (_, __) => const FreelancerExperiencePage(),
      ),
      GoRoute(
        path: Routes.freelancerEducation,
        builder: (_, __) => const FreelancerEducationPage(),
      ),
      GoRoute(
        path: Routes.freelancerWithdrawals,
        builder: (_, __) => const FreelancerWithdrawalsPage(),
      ),
      GoRoute(
        path: Routes.freelancerInvoices,
        builder: (_, __) => const FreelancerInvoicesPage(),
      ),
      GoRoute(
        path: Routes.freelancerAnalytics,
        builder: (_, __) => const RoleAnalyticsPage(role: UserRole.freelancer),
      ),

      // Role sub-pages — Client
      GoRoute(
        path: Routes.clientApplications,
        builder: (_, __) => const ClientApplicationsPage(),
      ),
      GoRoute(
        path: Routes.clientShortlisted,
        builder: (_, __) => const ClientShortlistedPage(),
      ),
      GoRoute(
        path: Routes.clientTeams,
        builder: (_, __) => const ClientTeamsPage(),
      ),
      GoRoute(
        path: Routes.clientReports,
        builder: (_, __) => const ClientReportsHubPage(),
      ),
      GoRoute(
        path: Routes.clientAnalytics,
        builder: (_, __) => const RoleAnalyticsPage(role: UserRole.client),
      ),

      // Role sub-pages — Investor
      GoRoute(
        path: Routes.investorPreferences,
        builder: (_, __) => const InvestorPreferencesPage(),
      ),
      GoRoute(
        path: Routes.investorDueDiligence,
        builder: (_, __) => const InvestorDueDiligencePage(),
      ),
      GoRoute(
        path: Routes.investorOffers,
        builder: (_, __) => const InvestorOffersPage(),
      ),
      GoRoute(
        path: Routes.investorDocuments,
        builder: (_, __) => const InvestorDocumentsLivePage(),
      ),
      GoRoute(
        path: Routes.investorTransactions,
        builder: (_, __) => const InvestorTransactionsPage(),
      ),
      GoRoute(
        path: Routes.investorReports,
        builder: (_, __) => const InvestorReportsLivePage(),
      ),
      GoRoute(
        path: Routes.investorAnalytics,
        builder: (_, __) => const RoleAnalyticsPage(role: UserRole.investor),
      ),

      // Role sub-pages — Founder
      GoRoute(
        path: Routes.founderPitchDeck,
        builder: (_, __) => const FounderPitchDeckLivePage(),
      ),
      GoRoute(
        path: Routes.founderBusinessPlan,
        builder: (_, __) => const FounderBusinessPlanLivePage(),
      ),
      GoRoute(
        path: Routes.founderTeam,
        builder: (_, __) => const FounderTeamLivePage(),
      ),
      GoRoute(
        path: Routes.founderHiring,
        builder: (_, __) => const FounderHiringPage(),
      ),
      GoRoute(
        path: Routes.founderMedia,
        builder: (_, __) => const FounderMediaLivePage(),
      ),
      GoRoute(
        path: Routes.founderAnalytics,
        builder: (_, __) => const RoleAnalyticsPage(role: UserRole.founder),
      ),
      GoRoute(
        path: '${Routes.publicFreelancer}/:id',
        builder: (_, s) => PublicProfilePage(
          type: PublicProfileType.freelancer,
          id: s.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '${Routes.publicCompany}/:id',
        builder: (_, s) => PublicProfilePage(
          type: PublicProfileType.company,
          id: s.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '${Routes.publicInvestor}/:id',
        builder: (_, s) => PublicProfilePage(
          type: PublicProfileType.investor,
          id: s.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '${Routes.publicFounder}/:id',
        builder: (_, s) => PublicProfilePage(
          type: PublicProfileType.founder,
          id: s.pathParameters['id']!,
        ),
      ),
    ],
  );
}
