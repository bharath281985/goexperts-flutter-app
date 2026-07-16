import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../app/dependency_injection/service_locator.dart';
import '../storage/local_storage.dart';

/// Central manager for the bookmarking and collections system.
///
/// Persists bookmarked items of all enterprise types, collections, custom
/// folders, saved filters and saved searches to LocalStorage.
class BookmarkManager extends ChangeNotifier {
  BookmarkManager._();

  static final BookmarkManager instance = BookmarkManager._();

  LocalStorage get _storage => sl<LocalStorage>();

  static const String categoryProjects = 'projects';
  static const String categoryServices = 'services';
  static const String categoryFreelancers = 'freelancers';
  static const String categoryCompanies = 'companies';
  static const String categoryInvestors = 'investors';
  static const String categoryFounders = 'founders';
  static const String categoryStartups = 'startups';
  static const String categoryTechnologies = 'technologies';
  static const String categoryCategories = 'categories';
  static const String categoryPortfolio = 'portfolio';
  static const String categoryLearningResources = 'learning_resources';
  static const String categoryBlogs = 'blogs';

  /// Toggle a bookmark by category and item ID.
  Future<bool> toggle(String category, String id) async {
    final list = getIds(category);
    final isSaved = list.contains(id);
    if (isSaved) {
      list.remove(id);
    } else {
      list.add(id);
    }
    await _storage.setStringList('bookmarks_$category', list);
    notifyListeners();
    return !isSaved;
  }

  /// Check if an item is bookmarked.
  bool isBookmarked(String category, String id) {
    return getIds(category).contains(id);
  }

  /// Get all bookmarked item IDs for a category.
  List<String> getIds(String category) {
    final list = _storage.getStringList('bookmarks_$category');
    if (list.isEmpty) {
      if (category == categoryProjects) return ['p1', 'p3'];
      if (category == categoryFreelancers) return ['f1'];
      if (category == categoryStartups) return ['s1'];
      if (category == categoryCompanies) return ['co1'];
      if (category == categoryInvestors) return ['i1'];
      if (category == categoryServices) return ['sv1'];
      if (category == categoryTechnologies) return ['tech_flutter'];
      if (category == categoryCategories) return ['cat_mobile'];
    }
    return list;
  }

  // --- Collections & Bookmark Folders ---
  static const String _keyCollections = 'bookmark_collections';
  static const String _keyFolders = 'bookmark_folders';

  List<String> getCollections() {
    final list = _storage.getStringList(_keyCollections);
    if (list.isEmpty) {
      return ['My Favorites', 'Tech Stack', 'High Budget Projects', 'Starred Startups'];
    }
    return list;
  }

  Future<void> addCollection(String name) async {
    final list = getCollections();
    if (!list.contains(name)) {
      list.add(name);
      await _storage.setStringList(_keyCollections, list);
      notifyListeners();
    }
  }

  List<String> getFolders() {
    final list = _storage.getStringList(_keyFolders);
    if (list.isEmpty) {
      return ['Personal', 'Work', 'Investment ideas', 'Watchlist'];
    }
    return list;
  }

  Future<void> addFolder(String name) async {
    final list = getFolders();
    if (!list.contains(name)) {
      list.add(name);
      await _storage.setStringList(_keyFolders, list);
      notifyListeners();
    }
  }

  // --- Saved Searches & Filters ---
  static const String _keySavedSearches = 'saved_searches';
  static const String _keySavedFilters = 'saved_filters';

  List<String> getSavedSearches() {
    final list = _storage.getStringList(_keySavedSearches);
    if (list.isEmpty) {
      return ['Flutter Remote Developer', 'AI/ML Startups', 'FinTech Pitch Decks'];
    }
    return list;
  }

  Future<void> addSavedSearch(String query) async {
    final list = getSavedSearches();
    if (!list.contains(query)) {
      list.add(query);
      await _storage.setStringList(_keySavedSearches, list);
      notifyListeners();
    }
  }

  Future<void> removeSavedSearch(String query) async {
    final list = getSavedSearches();
    if (list.contains(query)) {
      list.remove(query);
      await _storage.setStringList(_keySavedSearches, list);
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> getSavedFilters() {
    final raw = _storage.getStringList(_keySavedFilters);
    if (raw.isEmpty) {
      return [
        {
          'name': 'High Budget Flutter',
          'category': 'Mobile Development',
          'minBudget': 200000,
          'verifiedOnly': true,
        },
        {
          'name': 'Early Stage AgriTech',
          'industry': 'AgriTech',
          'stage': 'Early Revenue',
        }
      ];
    }
    return raw.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  Future<void> addSavedFilter(String name, Map<String, dynamic> filterData) async {
    final list = getSavedFilters();
    final item = {'name': name, ...filterData};
    list.add(item);
    final rawList = list.map((e) => jsonEncode(e)).toList();
    await _storage.setStringList(_keySavedFilters, rawList);
    notifyListeners();
  }
}
