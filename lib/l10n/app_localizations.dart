import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('en'),
    Locale('fr'),
    Locale('gu'),
    Locale('hi'),
    Locale('kn'),
    Locale('ml'),
    Locale('mr'),
    Locale('ta'),
    Locale('te'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Go Experts'**
  String get appTitle;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Go Experts'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @logInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue to Go Experts'**
  String get logInToContinue;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Settings updated'**
  String get settingsUpdated;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @securityCenter.
  ///
  /// In en, this message translates to:
  /// **'Security Center'**
  String get securityCenter;

  /// No description provided for @subscriptionBilling.
  ///
  /// In en, this message translates to:
  /// **'Subscription & Billing'**
  String get subscriptionBilling;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @emailUpdates.
  ///
  /// In en, this message translates to:
  /// **'Email Updates'**
  String get emailUpdates;

  /// No description provided for @marketing.
  ///
  /// In en, this message translates to:
  /// **'Marketing'**
  String get marketing;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @publicProfile.
  ///
  /// In en, this message translates to:
  /// **'Public Profile'**
  String get publicProfile;

  /// No description provided for @viewPublicProfile.
  ///
  /// In en, this message translates to:
  /// **'View Public Profile'**
  String get viewPublicProfile;

  /// No description provided for @blockedUsers.
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get blockedUsers;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @aboutGoExperts.
  ///
  /// In en, this message translates to:
  /// **'About Go Experts'**
  String get aboutGoExperts;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @retrySync.
  ///
  /// In en, this message translates to:
  /// **'Retry Sync'**
  String get retrySync;

  /// No description provided for @youreOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get youreOffline;

  /// No description provided for @youreOfflineQueued.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline · {count} change(s) queued'**
  String youreOfflineQueued(Object count);

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @projects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects;

  /// No description provided for @chats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chats;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @meetings.
  ///
  /// In en, this message translates to:
  /// **'Meetings'**
  String get meetings;

  /// No description provided for @bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarks;

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptions;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @logOutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logOutQuestion;

  /// No description provided for @signInAgain.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again.'**
  String get signInAgain;

  /// No description provided for @signInAgainAccess.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to access your account.'**
  String get signInAgainAccess;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newest;

  /// No description provided for @budgetHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Budget: High to Low'**
  String get budgetHighToLow;

  /// No description provided for @budgetLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Budget: Low to High'**
  String get budgetLowToHigh;

  /// No description provided for @mostProposals.
  ///
  /// In en, this message translates to:
  /// **'Most proposals'**
  String get mostProposals;

  /// No description provided for @searchEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Search…'**
  String get searchEllipsis;

  /// No description provided for @noMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get noMatches;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;

  /// No description provided for @chooseCategoryFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose a category first'**
  String get chooseCategoryFirst;

  /// No description provided for @countSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String countSelected(Object count);

  /// No description provided for @noSkillsFound.
  ///
  /// In en, this message translates to:
  /// **'No skills found for {category}'**
  String noSkillsFound(Object category);

  /// No description provided for @removedFromSaved.
  ///
  /// In en, this message translates to:
  /// **'Removed from saved'**
  String get removedFromSaved;

  /// No description provided for @savedProject.
  ///
  /// In en, this message translates to:
  /// **'Saved project'**
  String get savedProject;

  /// No description provided for @noProjectsFound.
  ///
  /// In en, this message translates to:
  /// **'No projects found'**
  String get noProjectsFound;

  /// No description provided for @searchProjectsSkills.
  ///
  /// In en, this message translates to:
  /// **'Search projects, skills…'**
  String get searchProjectsSkills;

  /// No description provided for @adjustSearchFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters.'**
  String get adjustSearchFilters;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @choosePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan'**
  String get choosePlan;

  /// No description provided for @chooseYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose your plan'**
  String get chooseYourPlan;

  /// No description provided for @renewPlan.
  ///
  /// In en, this message translates to:
  /// **'Renew your plan'**
  String get renewPlan;

  /// No description provided for @viewPlans.
  ///
  /// In en, this message translates to:
  /// **'View Plans'**
  String get viewPlans;

  /// No description provided for @noCurrentPlan.
  ///
  /// In en, this message translates to:
  /// **'No current plan'**
  String get noCurrentPlan;

  /// No description provided for @planFeatures.
  ///
  /// In en, this message translates to:
  /// **'Plan Features'**
  String get planFeatures;

  /// No description provided for @planLimits.
  ///
  /// In en, this message translates to:
  /// **'Plan Limits'**
  String get planLimits;

  /// No description provided for @starterPlan.
  ///
  /// In en, this message translates to:
  /// **'Starter plan'**
  String get starterPlan;

  /// No description provided for @freelancerAnnualPlan.
  ///
  /// In en, this message translates to:
  /// **'Freelancer Annual plan'**
  String get freelancerAnnualPlan;

  /// No description provided for @portfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get portfolio;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @discoverProjects.
  ///
  /// In en, this message translates to:
  /// **'Discover Projects'**
  String get discoverProjects;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @workspace.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get workspace;

  /// No description provided for @freelancer.
  ///
  /// In en, this message translates to:
  /// **'Freelancer'**
  String get freelancer;

  /// No description provided for @client.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get client;

  /// No description provided for @clientBusinessOwner.
  ///
  /// In en, this message translates to:
  /// **'Client / Business Owner'**
  String get clientBusinessOwner;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @investor.
  ///
  /// In en, this message translates to:
  /// **'Investor'**
  String get investor;

  /// No description provided for @founder.
  ///
  /// In en, this message translates to:
  /// **'Founder'**
  String get founder;

  /// No description provided for @startupFounder.
  ///
  /// In en, this message translates to:
  /// **'Startup Founder'**
  String get startupFounder;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @freelanceWorkUpdate.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what\'s happening with your freelance work today.'**
  String get freelanceWorkUpdate;

  /// No description provided for @manageProjectsTeams.
  ///
  /// In en, this message translates to:
  /// **'Manage your projects, teams and hiring in one place.'**
  String get manageProjectsTeams;

  /// No description provided for @discoverStartups.
  ///
  /// In en, this message translates to:
  /// **'Discover Startups'**
  String get discoverStartups;

  /// No description provided for @proposals.
  ///
  /// In en, this message translates to:
  /// **'Proposals'**
  String get proposals;

  /// No description provided for @contracts.
  ///
  /// In en, this message translates to:
  /// **'Contracts'**
  String get contracts;

  /// No description provided for @myProjects.
  ///
  /// In en, this message translates to:
  /// **'My Projects'**
  String get myProjects;

  /// No description provided for @createProject.
  ///
  /// In en, this message translates to:
  /// **'Create Project'**
  String get createProject;

  /// No description provided for @postNewProject.
  ///
  /// In en, this message translates to:
  /// **'Post a New Project'**
  String get postNewProject;

  /// No description provided for @hireFreelancers.
  ///
  /// In en, this message translates to:
  /// **'Hire Freelancers'**
  String get hireFreelancers;

  /// No description provided for @applications.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get applications;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @companyProfile.
  ///
  /// In en, this message translates to:
  /// **'Company Profile'**
  String get companyProfile;

  /// No description provided for @investorProfile.
  ///
  /// In en, this message translates to:
  /// **'Investor Profile'**
  String get investorProfile;

  /// No description provided for @founderProfile.
  ///
  /// In en, this message translates to:
  /// **'Founder Profile'**
  String get founderProfile;

  /// No description provided for @dealRooms.
  ///
  /// In en, this message translates to:
  /// **'Deal Rooms'**
  String get dealRooms;

  /// No description provided for @myStartup.
  ///
  /// In en, this message translates to:
  /// **'My Startup'**
  String get myStartup;

  /// No description provided for @investors.
  ///
  /// In en, this message translates to:
  /// **'Investors'**
  String get investors;

  /// No description provided for @funding.
  ///
  /// In en, this message translates to:
  /// **'Funding'**
  String get funding;

  /// No description provided for @talent.
  ///
  /// In en, this message translates to:
  /// **'Talent'**
  String get talent;

  /// No description provided for @startup.
  ///
  /// In en, this message translates to:
  /// **'Startup'**
  String get startup;

  /// No description provided for @deals.
  ///
  /// In en, this message translates to:
  /// **'Deals'**
  String get deals;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get availableBalance;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @inEscrow.
  ///
  /// In en, this message translates to:
  /// **'In Escrow'**
  String get inEscrow;

  /// No description provided for @lifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get lifetime;

  /// No description provided for @bank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bank;

  /// No description provided for @upi.
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get upi;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmount;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @invoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoices;

  /// No description provided for @addMoney.
  ///
  /// In en, this message translates to:
  /// **'Add Money'**
  String get addMoney;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @activeProjects.
  ///
  /// In en, this message translates to:
  /// **'Active Projects'**
  String get activeProjects;

  /// No description provided for @pendingProposals.
  ///
  /// In en, this message translates to:
  /// **'Pending Proposals'**
  String get pendingProposals;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @monthlyEarnings.
  ///
  /// In en, this message translates to:
  /// **'Monthly Earnings'**
  String get monthlyEarnings;

  /// No description provided for @monthlySpend.
  ///
  /// In en, this message translates to:
  /// **'Monthly Spend'**
  String get monthlySpend;

  /// No description provided for @last6Months.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get last6Months;

  /// No description provided for @upcomingMeetings.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Meetings'**
  String get upcomingMeetings;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @recommendedProjects.
  ///
  /// In en, this message translates to:
  /// **'Recommended Projects'**
  String get recommendedProjects;

  /// No description provided for @recommendedFreelancers.
  ///
  /// In en, this message translates to:
  /// **'Recommended Freelancers'**
  String get recommendedFreelancers;

  /// No description provided for @projectSpending.
  ///
  /// In en, this message translates to:
  /// **'Project Spending'**
  String get projectSpending;

  /// No description provided for @freelancersHired.
  ///
  /// In en, this message translates to:
  /// **'Freelancers Hired'**
  String get freelancersHired;

  /// No description provided for @profileViews.
  ///
  /// In en, this message translates to:
  /// **'Profile views'**
  String get profileViews;

  /// No description provided for @proposalWinRate.
  ///
  /// In en, this message translates to:
  /// **'Proposal win rate'**
  String get proposalWinRate;

  /// No description provided for @monthlyEarningsStats.
  ///
  /// In en, this message translates to:
  /// **'Monthly earnings'**
  String get monthlyEarningsStats;

  /// No description provided for @avgRating.
  ///
  /// In en, this message translates to:
  /// **'Avg rating'**
  String get avgRating;

  /// No description provided for @projectsPosted.
  ///
  /// In en, this message translates to:
  /// **'Projects posted'**
  String get projectsPosted;

  /// No description provided for @hireRate.
  ///
  /// In en, this message translates to:
  /// **'Hire rate'**
  String get hireRate;

  /// No description provided for @monthlySpendStats.
  ///
  /// In en, this message translates to:
  /// **'Monthly spend'**
  String get monthlySpendStats;

  /// No description provided for @avgTimeToHire.
  ///
  /// In en, this message translates to:
  /// **'Avg time to hire'**
  String get avgTimeToHire;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @telugu.
  ///
  /// In en, this message translates to:
  /// **'Telugu'**
  String get telugu;

  /// No description provided for @tamil.
  ///
  /// In en, this message translates to:
  /// **'Tamil'**
  String get tamil;

  /// No description provided for @kannada.
  ///
  /// In en, this message translates to:
  /// **'Kannada'**
  String get kannada;

  /// No description provided for @malayalam.
  ///
  /// In en, this message translates to:
  /// **'Malayalam'**
  String get malayalam;

  /// No description provided for @marathi.
  ///
  /// In en, this message translates to:
  /// **'Marathi'**
  String get marathi;

  /// No description provided for @gujarati.
  ///
  /// In en, this message translates to:
  /// **'Gujarati'**
  String get gujarati;

  /// No description provided for @bengali.
  ///
  /// In en, this message translates to:
  /// **'Bengali'**
  String get bengali;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'en',
    'fr',
    'gu',
    'hi',
    'kn',
    'ml',
    'mr',
    'ta',
    'te',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'ml':
      return AppLocalizationsMl();
    case 'mr':
      return AppLocalizationsMr();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
