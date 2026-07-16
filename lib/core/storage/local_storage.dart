import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Non-sensitive key/value cache backed by SharedPreferences.
class LocalStorage {
  LocalStorage(this._prefs);

  final SharedPreferences _prefs;

  static const kOnboardingSeen = 'onboarding_seen';
  static const kThemeMode = 'theme_mode';
  static const kLocale = 'locale';
  static const kActiveRole = 'active_role';
  static const kRecentSearches = 'recent_searches';
  static const kBookmarks = 'bookmarks';
  static const kBiometricEnabled = 'biometric_enabled';
  static const kCachedUser = 'cached_user';

  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);
  bool getBool(String key, {bool fallback = false}) =>
      _prefs.getBool(key) ?? fallback;

  Future<void> setString(String key, String value) => _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);

  Future<void> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);
  List<String> getStringList(String key) => _prefs.getStringList(key) ?? [];

  Future<void> setJson(String key, Map<String, dynamic> value) =>
      _prefs.setString(key, jsonEncode(value));
  Map<String, dynamic>? getJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> remove(String key) => _prefs.remove(key);
  Future<void> clear() => _prefs.clear();
}
