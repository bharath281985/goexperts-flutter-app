/// Runtime configuration & feature flags.
///
/// Everything that would differ between environments (base URL, timeouts,
/// realtime provider, feature toggles) is centralized here so the rest of the
/// codebase stays environment-agnostic and API-ready.
enum AppFlavor { dev, staging, prod }

/// Realtime transport the chat/notification layer is prepared for.
/// The UI is wired to be transport-agnostic (Socket.IO / Supabase / Firebase /
/// Pusher / Ably) — only this value + the datasource impl change later.
enum RealtimeProvider { socketIo, supabase, firebase, pusher, ably }

class AppConfig {
  AppConfig._();

  static AppFlavor flavor = AppFlavor.dev;

  /// Set to `true` to use in-memory mock data instead of live APIs.
  static const bool useMockData = false;

  static const String baseUrlDev =
      'https://mobileapi.goexperts.in/api/v1/mobile';
  static const String baseUrlStaging =
      'https://mobileapi.goexperts.in/api/v1/mobile';
  static const String baseUrlProd =
      'https://mobileapi.goexperts.in/api/v1/mobile';

  /// Public catalog APIs (categories, skills) use the same mobile API host.
  @Deprecated('Use AppConfig.baseUrl — catalog lives on mobileapi')
  static const String publicCatalogBaseUrl =
      'https://mobileapi.goexperts.in/api/v1/mobile';

  static String get baseUrl {
    switch (flavor) {
      case AppFlavor.dev:
        return baseUrlDev;
      case AppFlavor.staging:
        return baseUrlStaging;
      case AppFlavor.prod:
        return baseUrlProd;
    }
  }

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);

  static const RealtimeProvider realtimeProvider = RealtimeProvider.socketIo;
  static const String socketUrl = 'https://mobileapi.goexperts.in:443';

  static const int defaultPageSize = 15;

  // Simulated latency for mock repositories.
  static const Duration mockLatency = Duration(milliseconds: 650);

  // Analytics providers we expose placeholders for.
  static const bool enableFirebaseAnalytics = false;
  static const bool enableCrashlytics = false;
  static const bool enableMixpanel = false;
  static const bool enableAmplitude = false;
}
