/// Central registry of route paths + names for deep linking and navigation.
class Routes {
  Routes._();

  // Auth flow
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const otp = '/otp';
  static const resetPassword = '/reset-password';
  static const emailVerification = '/email-verification';
  static const phoneVerification = '/phone-verification';
  static const roleSelection = '/role-selection';
  static const profileCompletion = '/profile-completion';
  static const subscription = '/subscription';
  static const authSuccess = '/success';

  // Freelancer
  static const freelancerDashboard = '/freelancer/dashboard';
  static const freelancerProjects = '/freelancer/projects';
  static const freelancerProposals = '/freelancer/proposals';
  static const freelancerWallet = '/freelancer/wallet';
  static const freelancerProfile = '/freelancer/profile';

  // Client
  static const clientDashboard = '/client/dashboard';
  static const clientProjects = '/client/projects';
  static const clientCreateProject = '/client/create-project';
  static const clientFreelancers = '/client/freelancers';
  static const clientPayments = '/client/payments';
  static const clientProfile = '/client/profile';

  // Investor
  static const investorDashboard = '/investor/dashboard';
  static const investorStartups = '/investor/startups';
  static const investorDeals = '/investor/deals';
  static const investorPortfolio = '/investor/portfolio';
  static const investorProfile = '/investor/profile';

  // Founder
  static const founderDashboard = '/founder/dashboard';
  static const founderStartup = '/founder/startup';
  static const founderListStartup = '/founder/list-startup';
  static const founderInvestors = '/founder/investors';
  static const founderFunding = '/founder/funding';
  static const founderProfile = '/founder/profile';

  // Common
  static const messages = '/messages';
  static const meetings = '/meetings';
  static const notifications = '/notifications';
  static const settings = '/settings';
  static const support = '/support';
  static const search = '/search';
  static const bookmarks = '/bookmarks';
  static const wallet = '/wallet';
  static const subscriptionsManage = '/subscriptions';
  static const securityCenter = '/security';
  static const changePassword = '/change-password';
  static const privacyPolicy = '/privacy';
  static const termsOfService = '/terms';

  // Detail routes (deep-link ready)
  static const chat = '/chat'; // /chat/:id
  static const projectDetails = '/project'; // /project/:id
  static const startupDetails = '/startup'; // /startup/:id
  static const proposalDetails = '/proposal'; // /proposal/:id
  static const meetingDetails = '/meeting'; // /meeting/:id
  static const contractDetails = '/contract'; // /contract/:id
  static const invoiceDetails = '/invoice'; // /invoice/:id
  static const transactionDetails = '/transaction'; // /transaction/:id
  static const certificateDetails = '/certificate'; // /certificate/:id
  static const reviewDetails = '/review'; // /review/:id
  static const opportunityDetails = '/opportunity'; // /opportunity/:id
  static const businessPlanDetails =
      '/business-plan'; // /business-plan/:id (startup id)
  static const pitchDeckDetails = '/pitch-deck'; // /pitch-deck/:id (startup id)
  static const serviceDetails = '/service'; // /service/:id
  static const technologyDetails = '/technology'; // /technology/:id
  static const categoryDetails = '/category'; // /category/:id
  static const publicFreelancer = '/u/freelancer'; // /u/freelancer/:id
  static const publicCompany = '/u/company'; // /u/company/:id
  static const publicInvestor = '/u/investor'; // /u/investor/:id
  static const publicFounder = '/u/founder'; // /u/founder/:id

  // Enterprise flows
  static const apply = '/apply'; // /apply?type=...
  static const invitations = '/invitations';
  static const documentViewer = '/document';
  static const calendar = '/calendar';

  // Role sub-pages — Freelancer
  static const freelancerContracts = '/freelancer/contracts';
  static const freelancerTasks = '/freelancer/tasks';
  static const freelancerReviews = '/freelancer/reviews';
  static const freelancerCertificates = '/freelancer/certificates';
  static const freelancerSkills = '/freelancer/skills';
  static const freelancerExperience = '/freelancer/experience';
  static const freelancerEducation = '/freelancer/education';
  static const freelancerWithdrawals = '/freelancer/withdrawals';
  static const freelancerInvoices = '/freelancer/invoices';
  static const freelancerAnalytics = '/freelancer/analytics';

  // Role sub-pages — Client
  static const clientApplications = '/client/applications';
  static const clientShortlisted = '/client/shortlisted';
  static const clientTeams = '/client/teams';
  static const clientReports = '/client/reports';
  static const clientAnalytics = '/client/analytics';

  // Role sub-pages — Investor
  static const investorPreferences = '/investor/preferences';
  static const investorDueDiligence = '/investor/due-diligence';
  static const investorOffers = '/investor/offers';
  static const investorDocuments = '/investor/documents';
  static const investorTransactions = '/investor/transactions';
  static const investorReports = '/investor/reports';

  // Role sub-pages — Founder
  static const founderPitchDeck = '/founder/pitch-deck';
  static const founderBusinessPlan = '/founder/business-plan';
  static const founderTeam = '/founder/team';
  static const founderHiring = '/founder/hiring';
  static const founderMedia = '/founder/media';
  static const founderAnalytics = '/founder/analytics';
}
