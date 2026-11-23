import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recall_item.dart';

class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _cacheKey = 'cached_recalls_v1';
  static const _cacheTimeKey = 'cached_recalls_timestamp_v1';
  static const _favoritesIdsKey = 'favorite_recall_ids_v1';
  static const _favoritesDataKey = 'favorite_recalls_snapshot_v1';
  static const _keywordsKey = 'monitored_keywords_v1';
  static const _themeModeKey = 'theme_mode_v1';
  static const _localeCodeKey = 'app_locale_code_v1';
  static const _seenIdsKey = 'seen_recall_ids_v1';

  Future<void> saveCachedRecalls(List<RecallItem> items) async {
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await _prefs.setString(_cacheKey, encoded);
    await _prefs.setString(_cacheTimeKey, DateTime.now().toIso8601String());
  }

  List<RecallItem> loadCachedRecalls() {
    final raw = _prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(RecallItem.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  DateTime? loadCacheTimestamp() {
    final raw = _prefs.getString(_cacheTimeKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> saveFavorites(List<RecallItem> favorites) async {
    final ids = favorites.map((e) => e.id).toList();
    final snapshots = jsonEncode(favorites.map((e) => e.toJson()).toList());
    await _prefs.setStringList(_favoritesIdsKey, ids);
    await _prefs.setString(_favoritesDataKey, snapshots);
  }

  List<RecallItem> loadFavorites() {
    final raw = _prefs.getString(_favoritesDataKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(RecallItem.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveKeywords(List<String> keywords) async {
    await _prefs.setStringList(_keywordsKey, keywords);
  }

  List<String> loadKeywords() {
    return _prefs.getStringList(_keywordsKey) ?? const ['latte', 'arachidi'];
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeModeKey, mode.name);
  }

  ThemeMode loadThemeMode() {
    final raw = _prefs.getString(_themeModeKey);
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> saveLocaleCode(String code) async {
    await _prefs.setString(_localeCodeKey, code);
  }

  String loadLocaleCode() {
    final raw = _prefs.getString(_localeCodeKey);
    if (raw == 'en' || raw == 'es' || raw == 'de') return raw!;
    return 'it';
  }

  Future<void> saveSeenRecallIds(List<String> ids) async {
    await _prefs.setStringList(_seenIdsKey, ids);
  }

  List<String>? loadSeenRecallIds() {
    return _prefs.getStringList(_seenIdsKey);
  }
}
