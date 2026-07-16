/// Centralized user-facing strings. Kept simple and localization-ready:
/// these can later be swapped for ARB-backed lookups without touching widgets.
class AppStrings {
  AppStrings._();

  static const String appName = 'Go Experts';
  static const String appTagline =
      'Where Freelancers, Businesses, Investors & Founders meet.';

  // Onboarding
  static const List<Map<String, String>> onboarding = [
    {
      'title': 'Hire & Get Hired',
      'subtitle':
          'Connect with top freelancers and businesses to deliver world-class projects.',
    },
    {
      'title': 'Fund & Get Funded',
      'subtitle':
          'Investors discover high-potential startups and founders raise capital with ease.',
    },
    {
      'title': 'Grow Together',
      'subtitle':
          'Manage contracts, meetings, payments and deals — all in one secure workspace.',
    },
  ];

  // Auth
  static const String login = 'Login';
  static const String signup = 'Create Account';
  static const String forgotPassword = 'Forgot Password?';
  static const String rememberMe = 'Remember Me';
  static const String continueLabel = 'Continue';

  // Errors
  static const String genericError = 'Something went wrong. Please try again.';
  static const String noInternet = 'No internet connection.';
  static const String emptyList = 'Nothing here yet.';
}
