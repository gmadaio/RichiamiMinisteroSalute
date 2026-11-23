import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../models/recall_item.dart';
import '../providers/recall_providers.dart';
import '../widgets/risk_badge.dart';

class RecallDetailScreen extends ConsumerWidget {
  const RecallDetailScreen({super.key, required this.item});

  final RecallItem item;

  Future<void> _openOfficialNotice(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final uri = Uri.parse(item.officialSourceUrl);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.openPortalError),
        ),
      );
    }
  }

  Future<void> _shareRecall(AppLocalizations l10n) async {
    final date =
        DateFormat('dd/MM/yyyy', l10n.dateLocale).format(item.publicationDate);
    final text = [
      '${l10n.detailTitle} (${l10n.categoryLabel(item.riskCategory)})',
      '${item.productName} — ${item.brand}',
      l10n.lotsLine(item.lotNumbers.join(', ')),
      '${l10n.expirationUpper}: ${item.expirationDate}',
      '${l10n.reasonUpper}: ${item.reason}',
      l10n.publishedOn(date),
      item.officialSourceUrl,
    ].join('\n');

    await Share.share(text, subject: item.productName);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final favorites = ref.watch(favoritesProvider);
    final isFav = favorites.any((element) => element.id == item.id);
    final dateFormatted =
        DateFormat('dd/MM/yyyy', l10n.dateLocale).format(item.publicationDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.detailTitle),
        actions: [
          IconButton(
            onPressed: () => ref.read(favoritesProvider.notifier).toggle(item),
            icon: Icon(
              isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isFav ? scheme.primary : null,
            ),
          ),
          IconButton(
            onPressed: () => _shareRecall(l10n),
            tooltip: l10n.shareTooltip,
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Row(
            children: [
              RiskBadge(category: item.riskCategory),
              if (item.isNew) ...[
                const SizedBox(width: 8),
                const NewRecallBadge(),
              ],
              const Spacer(),
              Text(
                l10n.publishedOn(dateFormatted),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                item.imageUrl!,
                height: 190,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _PlaceholderImage(scheme: scheme),
              ),
            )
          else
            _PlaceholderImage(scheme: scheme),
          const SizedBox(height: 16),
          Text(
            item.productName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.brand,
            style: theme.textTheme.titleMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.errorContainer.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.error.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HighlightField(
                  label: l10n.lotsUpper,
                  value: item.lotNumbers.join(', '),
                  monospace: true,
                ),
                const Divider(height: 24),
                _HighlightField(
                  label: l10n.expirationUpper,
                  value: item.expirationDate,
                  monospace: true,
                ),
                const Divider(height: 24),
                _HighlightField(
                  label: l10n.reasonUpper,
                  value: item.reason,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.commercialId,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(label: l10n.producerLabel, value: item.manufacturer),
                  const SizedBox(height: 10),
                  _InfoRow(label: l10n.packagingLabel, value: item.packagingUnit),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.health_and_safety_outlined, color: scheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        l10n.whatToDo,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.instructions,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _openOfficialNotice(context, l10n),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(l10n.openOfficial),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 44,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _HighlightField extends StatelessWidget {
  const _HighlightField({
    required this.label,
    required this.value,
    this.monospace = false,
  });

  final String label;
  final String value;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: theme.colorScheme.error,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontFamily: monospace ? 'monospace' : null,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
