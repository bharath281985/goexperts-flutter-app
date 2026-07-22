import 'package:flutter/material.dart';
import '../../app/constants/app_sizes.dart';
import '../../l10n/app_localizations.dart';

/// Ergonomic access to theme, media query and responsive helpers.
extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get text => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;

  Size get screenSize => MediaQuery.sizeOf(this);
  double get width => MediaQuery.sizeOf(this).width;
  double get height => MediaQuery.sizeOf(this).height;
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  /// System navigation / home-indicator inset (3-button or gesture bar).
  double get bottomSafeInset => MediaQuery.viewPaddingOf(this).bottom;

  /// Page padding that clears the system navigation bar.
  EdgeInsets paddingWithBottomSafe([
    EdgeInsets padding = const EdgeInsets.all(AppSizes.xl),
  ]) {
    return padding.copyWith(bottom: padding.bottom + bottomSafeInset);
  }

  bool get isMobile => width < AppSizes.mobileBreakpoint;
  bool get isTablet =>
      width >= AppSizes.mobileBreakpoint && width < AppSizes.tabletBreakpoint;
  bool get isDesktop => width >= AppSizes.tabletBreakpoint;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  String tr(String text) {
    final l10n = AppLocalizations.of(this);
    switch (text) {
      case 'Login':
      case 'Log in':
        return l10n.login;
      case 'Settings':
        return l10n.settings;
      case 'Language':
        return l10n.language;
      case 'Select Language':
        return l10n.selectLanguage;
      case 'English':
        return l10n.english;
      case 'Hindi':
        return l10n.hindi;
      case 'Telugu':
        return l10n.telugu;
      case 'Tamil':
        return l10n.tamil;
      case 'Kannada':
        return l10n.kannada;
      case 'Malayalam':
        return l10n.malayalam;
      case 'Marathi':
        return l10n.marathi;
      case 'Gujarati':
        return l10n.gujarati;
      case 'Bengali':
        return l10n.bengali;
      case 'Arabic':
        return l10n.arabic;
      case 'French':
        return l10n.french;
      case 'Save':
        return l10n.save;
      case 'Saved':
        return _inlineTr(l10n.localeName, text);
      case 'Cancel':
        return l10n.cancel;
      case 'Update':
        return l10n.update;
      case 'Log Out':
        return l10n.logOut;
      case 'Log out?':
        return l10n.logOutQuestion;
      case 'You will need to sign in again.':
        return l10n.signInAgain;
      case 'You will need to sign in again to access your account.':
        return l10n.signInAgainAccess;
      case 'Home':
        return l10n.home;
      case 'Projects':
        return l10n.projects;
      case 'Chats':
        return l10n.chats;
      case 'Wallet':
        return l10n.wallet;
      case 'Profile':
        return l10n.profile;
      case 'Messages':
        return l10n.messages;
      case 'Meetings':
        return l10n.meetings;
      case 'Bookmarks':
        return l10n.bookmarks;
      case 'Subscriptions':
        return l10n.subscriptions;
      case 'My Profile':
        return l10n.myProfile;
      case 'Edit Profile':
        return l10n.editProfile;
      case 'Account':
        return l10n.account;
      case 'Security Center':
        return l10n.securityCenter;
      case 'Subscription & Billing':
        return l10n.subscriptionBilling;
      case 'Preferences':
        return l10n.preferences;
      case 'Dark Mode':
        return l10n.darkMode;
      case 'Currency':
        return l10n.currency;
      case 'Notifications':
        return l10n.notifications;
      case 'Push Notifications':
        return l10n.pushNotifications;
      case 'Email Updates':
        return l10n.emailUpdates;
      case 'Marketing':
        return l10n.marketing;
      case 'Privacy':
        return l10n.privacy;
      case 'Public Profile':
        return l10n.publicProfile;
      case 'View Public Profile':
        return l10n.viewPublicProfile;
      case 'Blocked Users':
        return l10n.blockedUsers;
      case 'Privacy Policy':
        return l10n.privacyPolicy;
      case 'Terms of Service':
        return l10n.termsOfService;
      case 'Support':
        return l10n.support;
      case 'Help Center':
        return l10n.helpCenter;
      case 'About Go Experts':
        return l10n.aboutGoExperts;
      case 'App Version':
        return l10n.appVersion;
      case 'Portfolio':
        return l10n.portfolio;
      case 'Reviews':
        return l10n.reviews;
      case 'Analytics':
        return l10n.analytics;
      case 'Subscription':
        return l10n.subscription;
      case 'Dashboard':
        return l10n.dashboard;
      case 'Discover Projects':
        return l10n.discoverProjects;
      case 'My Projects':
        return l10n.myProjects;
      case 'Create Project':
        return l10n.createProject;
      case 'Hire Freelancers':
        return l10n.hireFreelancers;
      case 'Applications':
        return l10n.applications;
      case 'Payments':
        return l10n.payments;
      case 'Workspace':
        return l10n.workspace;
      case 'Freelancer':
        return l10n.freelancer;
      case 'Client':
        return l10n.client;
      case 'Business':
        return l10n.business;
      case 'Investor':
        return l10n.investor;
      case 'Founder':
        return l10n.founder;
      case 'Startup Founder':
        return l10n.startupFounder;
      case 'Discover Startups':
        return l10n.discoverStartups;
      case 'Company Profile':
        return l10n.companyProfile;
      case 'Investor Profile':
        return l10n.investorProfile;
      case 'Founder Profile':
        return l10n.founderProfile;
      case 'Deal Rooms':
        return l10n.dealRooms;
      case 'My Startup':
        return l10n.myStartup;
      case 'Investors':
        return l10n.investors;
      case 'Funding':
        return l10n.funding;
      case 'Talent':
        return l10n.talent;
      case 'Startup':
        return l10n.startup;
      case 'Deals':
        return l10n.deals;
      case 'Available Balance':
        return l10n.availableBalance;
      case 'Pending':
        return l10n.pending;
      case 'In Escrow':
        return l10n.inEscrow;
      case 'Lifetime':
        return l10n.lifetime;
      case 'Recent Transactions':
        return l10n.recentTransactions;
      case 'Active Projects':
        return l10n.activeProjects;
      case 'Pending Proposals':
        return l10n.pendingProposals;
      case 'This Month':
        return l10n.thisMonth;
      case 'Monthly Earnings':
        return l10n.monthlyEarnings;
      case 'Monthly Spend':
        return l10n.monthlySpend;
      case 'Last 6 months':
        return l10n.last6Months;
      case 'Upcoming Meetings':
        return l10n.upcomingMeetings;
      case 'See all':
      case 'See All':
        return l10n.seeAll;
      case 'Recommended Projects':
        return l10n.recommendedProjects;
      case 'Recommended Freelancers':
        return l10n.recommendedFreelancers;
      case 'Profile views':
        return l10n.profileViews;
      case 'Starter plan':
      case 'Starter Plan':
        return l10n.starterPlan;
      case 'Freelancer Annual plan':
      case 'Freelancer Annual Plan':
        return l10n.freelancerAnnualPlan;
    }
    return _inlineTr(l10n.localeName, text);
  }

  /// Grid column count that adapts across form factors.
  int get responsiveColumns {
    if (width >= AppSizes.desktopBreakpoint) return 4;
    if (width >= AppSizes.tabletBreakpoint) return 3;
    if (width >= AppSizes.mobileBreakpoint) return 2;
    return 1;
  }

  void showSnack(String message, {bool isError = false}) {
    if (message.trim().isEmpty) return;
    final messenger = ScaffoldMessenger.of(this);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(tr(message)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        backgroundColor: isError ? colors.error : null,
      ),
    );
  }

  void showTopSnack(String message, {bool isError = false}) {
    if (message.trim().isEmpty) return;
    _activeTopSnack?.remove();
    _activeTopSnack = null;

    final overlayState = Overlay.of(this);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _TopSnackWidget(
        message: message,
        isError: isError,
        onDismiss: () {
          if (overlayEntry.mounted) {
            overlayEntry.remove();
            if (_activeTopSnack == overlayEntry) {
              _activeTopSnack = null;
            }
          }
        },
      ),
    );

    _activeTopSnack = overlayEntry;
    overlayState.insert(overlayEntry);
  }
}

String _inlineTr(String localeName, String text) {
  final code = localeName.split('_').first;
  return _inlineTranslations[code]?[text] ?? text;
}

const _inlineTranslations = {
  'te': {
    'My Startup Ideas': 'నా స్టార్టప్ ఆలోచనలు',
    'Startups': 'స్టార్టప్‌లు',
    'Search startup ideas…': 'స్టార్టప్ ఆలోచనలు వెతకండి…',
    'Search startups, industries…': 'స్టార్టప్‌లు, పరిశ్రమలు వెతకండి…',
    'Search investors, industries…': 'ఇన్వెస్టర్లు, పరిశ్రమలు వెతకండి…',
    'Search chats…': 'చాట్‌లు వెతకండి…',
    'No conversations yet': 'ఇంకా సంభాషణలు లేవు',
    'No startups found': 'స్టార్టప్‌లు కనబడలేదు',
    'No startup ideas found': 'స్టార్టప్ ఆలోచనలు కనబడలేదు',
    'No investors found': 'ఇన్వెస్టర్లు కనబడలేదు',
    "You're all caught up": 'మీరు అన్నీ చూసేశారు',
    'Mark all read': 'అన్నీ చదివినట్లుగా గుర్తించండి',
    'All notifications marked as read':
        'అన్ని నోటిఫికేషన్‌లు చదివినట్లుగా గుర్తించబడ్డాయి',
    'Notification deleted': 'నోటిఫికేషన్ తొలగించబడింది',
    'Delete Chat': 'చాట్ తొలగించండి',
    'Message': 'సందేశం',
    'Mark as Read': 'చదివినట్లుగా గుర్తించండి',
    'Mark as Unread': 'చదవనట్లుగా గుర్తించండి',
    'Marked as read': 'చదివినట్లుగా గుర్తించబడింది',
    'Marked as unread': 'చదవనట్లుగా గుర్తించబడింది',
    'Create Startup Idea': 'స్టార్టప్ ఆలోచన సృష్టించండి',
    'Edit Startup Idea': 'స్టార్టప్ ఆలోచన సవరించండి',
    'Pick': 'ఎంచుకోండి',
    'Upload': 'అప్‌లోడ్ చేయండి',
    'Logo': 'లోగో',
    'Cover Image': 'కవర్ చిత్రం',
    'Pitch Deck (pitch Disk)': 'పిచ్ డెక్ (పిచ్ డిస్క్)',
    'Business Plan (Businessplan)': 'బిజినెస్ ప్లాన్ (బిజినెస్‌ప్లాన్)',
    'Image Picked': 'చిత్రం ఎంచుకోబడింది',
    'View': 'చూడండి',
    'Change': 'మార్చండి',
    'Remove': 'తీసివేయండి',
    'Startup Name': 'స్టార్టప్ పేరు',
    'Industry': 'పరిశ్రమ',
    'Category': 'వర్గం',
    'Stage': 'దశ',
    'Idea Stage': 'ఆలోచన దశ',
    'Prototype': 'ప్రోటోటైప్',
    'Early Revenue': 'ప్రారంభ ఆదాయం',
    'Early Traction': 'ప్రారంభ ట్రాక్షన్',
    'Growth': 'వృద్ధి',
    'Expansion': 'విస్తరణ',
    'Funding Ask': 'ఫండింగ్ అభ్యర్థన',
    'Funding Ask (USD)': 'ఫండింగ్ అభ్యర్థన (USD)',
    'Equity (%)': 'ఈక్విటీ (%)',
    'Required': 'అవసరం',
    'Invalid': 'చెల్లదు',
    'Enter valid funding ask': 'సరైన ఫండింగ్ అభ్యర్థన నమోదు చేయండి',
    'Stage is required': 'దశ అవసరం',
    'Create': 'సృష్టించండి',
    'Ask': 'అభ్యర్థన',
    'Equity': 'ఈక్విటీ',
    'Interest': 'ఆసక్తి',
    'raised of': 'మొత్తంలో సేకరించబడింది',
    'Delete': 'తొలగించు',
    'Edit': 'సవరించు',
    'Saved': 'సేవ్ చేయబడింది',
    'Invest': 'ఇన్వెస్ట్ చేయండి',
    'Ticket': 'టికెట్',
    'Follow': 'ఫాలో అవ్వండి',
    'Following': 'ఫాలో అవుతున్నారు',
    'Connect': 'కనెక్ట్',
    'Free plan': 'ఉచిత ప్లాన్',
    'free plan': 'ఉచిత ప్లాన్',
    'Funding Progress': 'ఫండింగ్ పురోగతి',
    'Seed round': 'సీడ్ రౌండ్',
    'Raised': 'సేకరించబడింది',
    'Goal': 'లక్ష్యం',
    'Investor Interests': 'ఇన్వెస్టర్ ఆసక్తులు',
    'Pitch Deck Views': 'పిచ్ డెక్ వీక్షణలు',
    'Startup Views': 'స్టార్టప్ వీక్షణలు',
    'Recommended Investors': 'సిఫార్సు చేసిన ఇన్వెస్టర్లు',
    'Deals': 'డీల్స్',
    'Portfolio': 'పోర్ట్‌ఫోలియో',
    'Rating': 'రేటింగ్',
    'Followers': 'ఫాలోవర్లు',
    'Share': 'షేర్ చేయండి',
    'Scan': 'స్కాన్ చేయండి',
    'More': 'మరిన్ని',
    'Founder Profile': 'ఫౌండర్ ప్రొఫైల్',
    'Client Profile': 'క్లయింట్ ప్రొఫైల్',
    'Founder': 'ఫౌండర్',
    'Change profile photo': 'ప్రొఫైల్ ఫోటో మార్చండి',
    'Profile photo uploaded successfully':
        'ప్రొఫైల్ ఫోటో విజయవంతంగా అప్‌లోడ్ చేయబడింది',
    'Name': 'పేరు',
    'Name is required': 'పేరు అవసరం',
    'Email is required': 'ఈమెయిల్ అవసరం',
    'Email Address': 'ఈమెయిల్ చిరునామా',
    'Enter your name': 'మీ పేరు నమోదు చేయండి',
    'Code': 'కోడ్',
    'Mobile': 'మొబైల్',
    'Enter your mobile number': 'మీ మొబైల్ నంబర్ నమోదు చేయండి',
    'Search country': 'దేశం వెతకండి',
    'Mobile number is required': 'మొబైల్ నంబర్ అవసరం',
    'Enter digits only': 'అంకెలు మాత్రమే నమోదు చేయండి',
    'India mobile number must be 10 digits':
        'భారత మొబైల్ నంబర్ 10 అంకెలు ఉండాలి',
    'India mobile number must start with 6, 7, 8 or 9':
        'భారత మొబైల్ నంబర్ 6, 7, 8 లేదా 9తో ప్రారంభం కావాలి',
    'Enter a valid mobile number': 'సరైన మొబైల్ నంబర్ నమోదు చేయండి',
    'Country': 'దేశం',
    'Enter your country': 'మీ దేశం నమోదు చేయండి',
    'Country is required': 'దేశం అవసరం',
    'City': 'నగరం',
    'Search and select your city': 'మీ నగరాన్ని వెతికి ఎంచుకోండి',
    'Address': 'చిరునామా',
    'Search and select your address': 'మీ చిరునామాను వెతికి ఎంచుకోండి',
    'Address is required': 'చిరునామా అవసరం',
    'Search location': 'స్థానం వెతకండి',
    'Bio': 'బయో',
    'Enter your bio': 'మీ బయో నమోదు చేయండి',
    'Bio is required': 'బయో అవసరం',
    'Company Name': 'కంపెనీ పేరు',
    'Company': 'కంపెనీ',
    'Enter company name': 'కంపెనీ పేరు నమోదు చేయండి',
    'Company name is required': 'కంపెనీ పేరు అవసరం',
    'Choose your industry': 'మీ పరిశ్రమను ఎంచుకోండి',
    'Skills': 'నైపుణ్యాలు',
    'Select skills that apply to you': 'మీకు వర్తించే నైపుణ్యాలను ఎంచుకోండి',
    'Category is required': 'వర్గం అవసరం',
    'Skills are required': 'నైపుణ్యాలు అవసరం',
    'Experience': 'అనుభవం',
    'Enter your experience in years': 'మీ అనుభవాన్ని సంవత్సరాల్లో నమోదు చేయండి',
    'Experience is required': 'అనుభవం అవసరం',
    'Hourly Rate': 'గంటల రేటు',
    'Enter your hourly rate': 'మీ గంటల రేటును నమోదు చేయండి',
    'Hourly rate is required': 'గంటల రేటు అవసరం',
    'Enter valid hourly rate': 'సరైన గంటల రేటు నమోదు చేయండి',
    'Profile updated successfully': 'ప్రొఫైల్ విజయవంతంగా నవీకరించబడింది',
    'Freelancer Profile': 'ఫ్రీలాన్సర్ ప్రొఫైల్',
    'Investor profile updated': 'ఇన్వెస్టర్ ప్రొఫైల్ నవీకరించబడింది',
    'Verified investor': 'ధృవీకరించబడిన ఇన్వెస్టర్',
    'Verification pending': 'ధృవీకరణ పెండింగ్‌లో ఉంది',
    'Completion': 'పూర్తి',
    'Upload Document': 'పత్రం అప్‌లోడ్ చేయండి',
    'Document uploaded': 'పత్రం అప్‌లోడ్ చేయబడింది',
    'Document uploaded via files API':
        'ఫైల్స్ API ద్వారా పత్రం అప్‌లోడ్ చేయబడింది',
    'Help & Support': 'సహాయం & సపోర్ట్',
    'Live Chat': 'లైవ్ చాట్',
    'Email Us': 'మాకు ఈమెయిల్ చేయండి',
    'Call': 'కాల్',
    'Frequently Asked Questions': 'తరచుగా అడిగే ప్రశ్నలు',
    'My Tickets': 'నా టికెట్లు',
    'Create Ticket': 'టికెట్ సృష్టించండి',
    'Create Support Ticket': 'సపోర్ట్ టికెట్ సృష్టించండి',
    'Support Ticket': 'సపోర్ట్ టికెట్',
    'No support tickets yet': 'ఇంకా సపోర్ట్ టికెట్లు లేవు',
    'Subject': 'విషయం',
    'Describe your issue': 'మీ సమస్యను వివరించండి',
    'Subject is required': 'విషయం అవసరం',
    'Priority': 'ప్రాధాన్యత',
    'Select category': 'వర్గాన్ని ఎంచుకోండి',
    'Select priority': 'ప్రాధాన్యతను ఎంచుకోండి',
    'Priority is required': 'ప్రాధాన్యత అవసరం',
    'Close': 'మూసివేయండి',
    'High': 'అధిక',
    'Medium': 'మధ్యస్థ',
    'Low': 'తక్కువ',
    'Open': 'తెరిచి ఉంది',
    'Closed': 'మూసివేయబడింది',
    'Resolved': 'పరిష్కరించబడింది',
    'Created': 'సృష్టించబడింది',
    'Updated': 'నవీకరించబడింది',
    'Ticket created': 'టికెట్ సృష్టించబడింది',
    'Account Verification': 'ఖాతా ధృవీకరణ',
    'Payment / Invoicing': 'చెల్లింపు / ఇన్వాయ్సింగ్',
    'Technical Issue / Bug': 'సాంకేతిక సమస్య / బగ్',
    'General Inquiry': 'సాధారణ విచారణ',
    'Feedback / Suggestions': 'అభిప్రాయం / సూచనలు',
    'Reset password': 'పాస్‌వర్డ్ రీసెట్ చేయండి',
    'Enter your email and we will send you a verification code':
        'మీ ఈమెయిల్ నమోదు చేయండి, మేము ధృవీకరణ కోడ్ పంపుతాము',
    'Send Code': 'కోడ్ పంపండి',
    'Password reset OTP sent': 'పాస్‌వర్డ్ రీసెట్ OTP పంపబడింది',
    'Create a new password for your account.':
        'మీ ఖాతాకు కొత్త పాస్‌వర్డ్ సృష్టించండి.',
    'Email address': 'ఈమెయిల్ చిరునామా',
    'OTP': 'OTP',
    'Enter verification code': 'ధృవీకరణ కోడ్ నమోదు చేయండి',
    'OTP is required': 'OTP అవసరం',
    'Enter the 6-digit code': '6 అంకెల కోడ్ నమోదు చేయండి',
    'New password': 'కొత్త పాస్‌వర్డ్',
    'At least 8 characters': 'కనీసం 8 అక్షరాలు',
    'Confirm password': 'పాస్‌వర్డ్ నిర్ధారించండి',
    'Re-enter new password': 'కొత్త పాస్‌వర్డ్ మళ్లీ నమోదు చేయండి',
    'Update Password': 'పాస్‌వర్డ్ నవీకరించండి',
    'Password reset successfully': 'పాస్‌వర్డ్ విజయవంతంగా రీసెట్ చేయబడింది',
    'Exit app?': 'యాప్ మూసివేయాలా?',
    'Do you want to close the app?': 'మీరు యాప్‌ను మూసివేయాలనుకుంటున్నారా?',
    'Exit': 'మూసివేయండి',
  },
};

OverlayEntry? _activeTopSnack;

class _TopSnackWidget extends StatefulWidget {
  const _TopSnackWidget({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  @override
  State<_TopSnackWidget> createState() => _TopSnackWidgetState();
}

class _TopSnackWidgetState extends State<_TopSnackWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), _dismiss);
  }

  void _dismiss() {
    if (mounted) {
      _controller.reverse().then((_) {
        widget.onDismiss();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.viewPaddingOf(context).top;
    return Align(
      alignment: Alignment.topCenter,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Padding(
            padding: EdgeInsets.only(top: topPadding + 10, left: 16, right: 16),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: widget.isError
                      ? const Color(0xFFD32F2F)
                      : const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isError
                          ? Icons.error_outline_rounded
                          : Icons.check_circle_outline_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _dismiss,
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
