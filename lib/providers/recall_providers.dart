import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recall_item.dart';
import '../services/local_storage_service.dart';
import '../services/recall_api_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences deve essere inizializzato nel main().');
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService(ref.watch(sharedPreferencesProvider));
});

final recallApiServiceProvider = Provider<RecallApiService>((ref) {
  return RecallApiService(
    feedUrl: const String.fromEnvironment(
      'RECALLS_FEED_URL',
      defaultValue: '',
    ),
    useMockData: const String.fromEnvironment('RECALLS_FEED_URL').isEmpty,
  );
});

class RecallsFeedState {
  const RecallsFeedState({
    required this.items,
    this.isFromCache = false,
    this.errorMessage,
    this.lastUpdated,
  });

  final List<RecallItem> items;
  final bool isFromCache;
  final String? errorMessage;
  final DateTime? lastUpdated;
}

class RecallsFeedNotifier extends AsyncNotifier<RecallsFeedState> {
  @override
  Future<RecallsFeedState> build() async {
    return _loadRecalls();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadRecalls);
  }

  Future<RecallsFeedState> _loadRecalls() async {
    final api = ref.read(recallApiServiceProvider);
    final storage = ref.read(localStorageServiceProvider);

    try {
      final items = await api.fetchRecalls();
      await storage.saveCachedRecalls(items);
      return RecallsFeedState(
        items: items,
        isFromCache: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      final cached = storage.loadCachedRecalls();
      if (cached.isNotEmpty) {
        return RecallsFeedState(
          items: cached,
          isFromCache: true,
          errorMessage: e.toString(),
          lastUpdated: storage.loadCacheTimestamp(),
        );
      }
      rethrow;
    }
  }
}

final recallsFeedProvider =
    AsyncNotifierProvider<RecallsFeedNotifier, RecallsFeedState>(
  RecallsFeedNotifier.new,
);

enum TimeRangeFilter {
  all,
  last7Days,
  last30Days;

  String get label {
    switch (this) {
      case TimeRangeFilter.all:
        return 'Tutti';
      case TimeRangeFilter.last7Days:
        return '7 giorni';
      case TimeRangeFilter.last30Days:
        return '30 giorni';
    }
  }
}

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<RiskCategory?>((ref) => null);
final timeRangeProvider =
    StateProvider<TimeRangeFilter>((ref) => TimeRangeFilter.all);
final prioritizeKeywordsProvider = StateProvider<bool>((ref) => false);
final onlyKeywordMatchesProvider = StateProvider<bool>((ref) => false);

final searchAndTimeMatchedRecallsProvider = Provider<List<RecallItem>>((ref) {
  final feedAsync = ref.watch(recallsFeedProvider);
  final query = ref.watch(searchQueryProvider);
  final timeRange = ref.watch(timeRangeProvider);

  final items = feedAsync.valueOrNull?.items ?? const <RecallItem>[];
  final now = DateTime.now();

  return items.where((item) {
    if (timeRange == TimeRangeFilter.last7Days &&
        now.difference(item.publicationDate).inDays > 7) {
      return false;
    }
    if (timeRange == TimeRangeFilter.last30Days &&
        now.difference(item.publicationDate).inDays > 30) {
      return false;
    }
    return item.matchesQuery(query);
  }).toList(growable: false);
});

final filteredRecallsProvider = Provider<List<RecallItem>>((ref) {
  final baseItems = ref.watch(searchAndTimeMatchedRecallsProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final keywords = ref.watch(keywordsProvider);
  final onlyMatched = ref.watch(onlyKeywordMatchesProvider);
  final prioritize = ref.watch(prioritizeKeywordsProvider);

  var list = baseItems.where((item) {
    final matchesCategory =
        selectedCategory == null || item.riskCategory == selectedCategory;
    if (!matchesCategory) return false;
    if (onlyMatched && keywords.isNotEmpty) {
      return item.matchingKeywords(keywords).isNotEmpty;
    }
    return true;
  }).toList();

  if (prioritize && keywords.isNotEmpty) {
    final matched = <RecallItem>[];
    final others = <RecallItem>[];
    for (final item in list) {
      if (item.matchingKeywords(keywords).isNotEmpty) {
        matched.add(item);
      } else {
        others.add(item);
      }
    }
    list = [...matched, ...others];
  }

  return List<RecallItem>.unmodifiable(list);
});

class SeenRecallIdsNotifier extends Notifier<List<String>?> {
  @override
  List<String>? build() {
    return ref.read(localStorageServiceProvider).loadSeenRecallIds();
  }

  Future<void> markAllSeen(List<RecallItem> items) async {
    final ids = items.map((e) => e.id).toList(growable: false);
    state = ids;
    await ref.read(localStorageServiceProvider).saveSeenRecallIds(ids);
  }
}

final seenRecallIdsProvider =
    NotifierProvider<SeenRecallIdsNotifier, List<String>?>(
  SeenRecallIdsNotifier.new,
);

final unseenCountProvider = Provider<int>((ref) {
  final items = ref.watch(recallsFeedProvider).valueOrNull?.items ?? const [];
  final seenIds = ref.watch(seenRecallIdsProvider);
  if (seenIds == null) {
    return items.where((item) => item.isNew).length;
  }
  final seenSet = seenIds.toSet();
  return items.where((item) => !seenSet.contains(item.id)).length;
});

class FavoritesNotifier extends Notifier<List<RecallItem>> {
  @override
  List<RecallItem> build() {
    return ref.read(localStorageServiceProvider).loadFavorites();
  }

  bool isFavorite(String id) => state.any((item) => item.id == id);

  Future<void> toggle(RecallItem item) async {
    final exists = isFavorite(item.id);
    final updated = exists
        ? state.where((element) => element.id != item.id).toList()
        : [item, ...state];
    state = updated;
    await ref.read(localStorageServiceProvider).saveFavorites(updated);
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, List<RecallItem>>(
  FavoritesNotifier.new,
);

class KeywordsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    return ref.read(localStorageServiceProvider).loadKeywords();
  }

  Future<void> addKeyword(String raw) async {
    final normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty || state.contains(normalized)) return;
    final updated = [...state, normalized];
    state = updated;
    await ref.read(localStorageServiceProvider).saveKeywords(updated);
  }

  Future<void> removeKeyword(String keyword) async {
    final updated = state.where((k) => k != keyword).toList();
    state = updated;
    await ref.read(localStorageServiceProvider).saveKeywords(updated);
  }
}

final keywordsProvider = NotifierProvider<KeywordsNotifier, List<String>>(
  KeywordsNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ref.read(localStorageServiceProvider).loadThemeMode();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await ref.read(localStorageServiceProvider).saveThemeMode(mode);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final code = ref.read(localStorageServiceProvider).loadLocaleCode();
    return Locale(code);
  }

  Future<void> setLanguageCode(String code) async {
    state = Locale(code);
    await ref.read(localStorageServiceProvider).saveLocaleCode(code);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
