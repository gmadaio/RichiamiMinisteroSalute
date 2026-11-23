import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/recall_item.dart';
import '../providers/recall_providers.dart';
import '../widgets/empty_error_state.dart';
import '../widgets/recall_card.dart';
import '../widgets/recall_skeleton.dart';
import '../widgets/risk_distribution_chart.dart';
import 'recall_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const int _pageSize = 12;
  late final TextEditingController _searchController;
  int _visibleLimit = _pageSize;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openLotCheckerSheet(List<RecallItem> allRecalls) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _LotCheckerSheet(allRecalls: allRecalls),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final feedAsync = ref.watch(recallsFeedProvider);
    final baseMatched = ref.watch(searchAndTimeMatchedRecallsProvider);
    final filtered = ref.watch(filteredRecallsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final timeRange = ref.watch(timeRangeProvider);
    final query = ref.watch(searchQueryProvider);
    final favorites = ref.watch(favoritesProvider);
    final keywords = ref.watch(keywordsProvider);
    final prioritize = ref.watch(prioritizeKeywordsProvider);
    final onlyKeyword = ref.watch(onlyKeywordMatchesProvider);
    final unseenCount = ref.watch(unseenCountProvider);
    final scheme = Theme.of(context).colorScheme;

    final allItems = feedAsync.valueOrNull?.items ?? const <RecallItem>[];
    final keywordMatchCount = keywords.isEmpty
        ? 0
        : baseMatched.where((i) => i.matchingKeywords(keywords).isNotEmpty).length;
    final visibleItems = filtered.take(_visibleLimit).toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.lotCheckTooltip,
            onPressed: allItems.isEmpty
                ? null
                : () => _openLotCheckerSheet(allItems),
            icon: const Icon(Icons.qr_code_scanner_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: SearchBar(
              controller: _searchController,
              hintText: l10n.searchHint,
              leading: const Icon(Icons.search_rounded),
              trailing: [
                if (query.isNotEmpty)
                  IconButton(
                    tooltip: l10n.clearSearch,
                    onPressed: () {
                      _searchController.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
              ],
              onChanged: (value) {
                setState(() => _visibleLimit = _pageSize);
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(l10n.allLabel),
                    selected: selectedCategory == null,
                    onSelected: (_) {
                      setState(() => _visibleLimit = _pageSize);
                      ref.read(selectedCategoryProvider.notifier).state = null;
                    },
                  ),
                ),
                ...RiskCategory.values.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(l10n.categoryLabel(category)),
                      selected: selectedCategory == category,
                      onSelected: (selected) {
                        setState(() => _visibleLimit = _pageSize);
                        ref.read(selectedCategoryProvider.notifier).state =
                            selected ? category : null;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Row(
              children: [
                Text(
                  l10n.periodLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                const Spacer(),
                SegmentedButton<TimeRangeFilter>(
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  segments: TimeRangeFilter.values
                      .map(
                        (t) => ButtonSegment(
                          value: t,
                          label: Text(l10n.timeRangeLabel(t)),
                        ),
                      )
                      .toList(),
                  selected: {timeRange},
                  onSelectionChanged: (sel) {
                    setState(() => _visibleLimit = _pageSize);
                    ref.read(timeRangeProvider.notifier).state = sel.first;
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: feedAsync.when(
              loading: () => const RecallSkeletonList(),
              error: (error, _) => NetworkErrorState(
                message: error.toString(),
                onRetry: () => ref.read(recallsFeedProvider.notifier).refresh(),
              ),
              data: (feedState) {
                return Column(
                  children: [
                    if (feedState.isFromCache)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.offline_pin_outlined,
                              size: 18,
                              color: scheme.onSecondaryContainer,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                feedState.lastUpdated != null
                                    ? l10n.offlineSavedOn(
                                        DateFormat('dd/MM/yyyy HH:mm', l10n.dateLocale)
                                            .format(feedState.lastUpdated!),
                                      )
                                    : l10n.offlineCacheNotice,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: scheme.onSecondaryContainer),
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  ref.read(recallsFeedProvider.notifier).refresh(),
                              child: Text(l10n.retry),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: baseMatched.isEmpty
                          ? EmptyRecallsState(
                              title: l10n.emptyTitle,
                              subtitle: l10n.emptySubtitle,
                              onResetFilters: () {
                                _searchController.clear();
                                ref.read(searchQueryProvider.notifier).state = '';
                                ref
                                    .read(selectedCategoryProvider.notifier)
                                    .state = null;
                                ref.read(timeRangeProvider.notifier).state =
                                    TimeRangeFilter.all;
                                ref
                                    .read(onlyKeywordMatchesProvider.notifier)
                                    .state = false;
                              },
                            )
                          : RefreshIndicator(
                              onRefresh: () =>
                                  ref.read(recallsFeedProvider.notifier).refresh(),
                              child: ListView(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 24),
                                children: [
                                  if (unseenCount > 0) ...[
                                    Card(
                                      color: scheme.primaryContainer
                                          .withValues(alpha: 0.6),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.auto_awesome_outlined,
                                              size: 18,
                                              color: scheme.onPrimaryContainer,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                l10n.unseenBanner(unseenCount),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelLarge
                                                    ?.copyWith(
                                                      color: scheme
                                                          .onPrimaryContainer,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () => ref
                                                  .read(seenRecallIdsProvider
                                                      .notifier)
                                                  .markAllSeen(allItems),
                                              child: Text(l10n.markSeen),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                  RiskDistributionChart(
                                    recalls: baseMatched,
                                    selectedCategory: selectedCategory,
                                    onSelectCategory: (cat) {
                                      setState(() => _visibleLimit = _pageSize);
                                      ref
                                          .read(
                                              selectedCategoryProvider.notifier)
                                          .state = cat;
                                    },
                                  ),
                                  if (keywordMatchCount > 0) ...[
                                    const SizedBox(height: 10),
                                    Card(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.notifications_active_outlined,
                                              size: 16,
                                              color: scheme.primary,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                l10n.keywordMatches(keywordMatchCount),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium,
                                              ),
                                            ),
                                            FilterChip(
                                              label: Text(l10n.pinTop),
                                              selected: prioritize,
                                              onSelected: (val) => ref
                                                  .read(
                                                      prioritizeKeywordsProvider
                                                          .notifier)
                                                  .state = val,
                                            ),
                                            const SizedBox(width: 6),
                                            FilterChip(
                                              label: Text(l10n.onlyThese),
                                              selected: onlyKeyword,
                                              onSelected: (val) => ref
                                                  .read(
                                                      onlyKeywordMatchesProvider
                                                          .notifier)
                                                  .state = val,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  ...visibleItems.map((item) {
                                    final isFav =
                                        favorites.any((f) => f.id == item.id);
                                    final matches =
                                        item.matchingKeywords(keywords);
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: RecallCard(
                                        item: item,
                                        isFavorite: isFav,
                                        matchedKeywords: matches,
                                        onToggleFavorite: () => ref
                                            .read(favoritesProvider.notifier)
                                            .toggle(item),
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute<void>(
                                              builder: (_) =>
                                                  RecallDetailScreen(item: item),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }),
                                  if (filtered.length > visibleItems.length)
                                    OutlinedButton(
                                      onPressed: () {
                                        setState(
                                            () => _visibleLimit += _pageSize);
                                      },
                                      child: Text(
                                        l10n.loadMore(
                                          filtered.length - visibleItems.length,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LotCheckerSheet extends StatefulWidget {
  const _LotCheckerSheet({required this.allRecalls});

  final List<RecallItem> allRecalls;

  @override
  State<_LotCheckerSheet> createState() => _LotCheckerSheetState();
}

class _LotCheckerSheetState extends State<_LotCheckerSheet> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final clean = _query.trim().toLowerCase();
    final matches = clean.isEmpty
        ? const <RecallItem>[]
        : widget.allRecalls
            .where(
              (item) => item.lotNumbers
                  .any((lot) => lot.toLowerCase().contains(clean)),
            )
            .toList(growable: false);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.lotCheckTooltip,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _controller,
            autofocus: true,
            onChanged: (val) => setState(() => _query = val),
            decoration: InputDecoration(
              hintText: l10n.lotInputHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          if (clean.isNotEmpty)
            if (matches.isEmpty)
              Text(l10n.lotNoMatch)
            else
              ...matches.take(4).map(
                    (m) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(m.productName),
                      subtitle: Text(l10n.lotsLine(m.lotNumbers.join(', '))),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => RecallDetailScreen(item: m),
                          ),
                        );
                      },
                    ),
                  ),
        ],
      ),
    );
  }
}
