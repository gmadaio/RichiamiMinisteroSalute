import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers/recall_providers.dart';
import '../widgets/recall_card.dart';
import 'recall_detail_screen.dart';

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen> {
  late final TextEditingController _keywordController;

  @override
  void initState() {
    super.initState();
    _keywordController = TextEditingController();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  void _submitKeyword() {
    final text = _keywordController.text.trim();
    if (text.isEmpty) return;
    ref.read(keywordsProvider.notifier).addKeyword(text);
    _keywordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final keywords = ref.watch(keywordsProvider);
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.watchlistTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Text(
            l10n.savedKeywordsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.savedKeywordsDesc,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _keywordController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submitKeyword(),
                  decoration: InputDecoration(
                    hintText: l10n.keywordInputHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: _submitKeyword,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(56, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (keywords.isEmpty)
            Text(
              l10n.noKeywords,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: keywords
                  .map(
                    (kw) => InputChip(
                      label: Text(kw),
                      onDeleted: () =>
                          ref.read(keywordsProvider.notifier).removeKeyword(kw),
                    ),
                  )
                  .toList(),
            ),
          const Divider(height: 36),
          Row(
            children: [
              Text(
                l10n.savedRecallsTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${favorites.length})',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.savedRecallsDesc,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          if (favorites.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.bookmark_outline_rounded,
                      size: 40,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.noSavedTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.noSavedDesc,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...favorites.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RecallCard(
                  item: item,
                  isFavorite: true,
                  matchedKeywords: item.matchingKeywords(keywords),
                  onToggleFavorite: () =>
                      ref.read(favoritesProvider.notifier).toggle(item),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => RecallDetailScreen(item: item),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
