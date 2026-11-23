import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/recall_item.dart';

enum _ChartMode { risk, trend }

class RiskDistributionChart extends StatefulWidget {
  const RiskDistributionChart({
    super.key,
    required this.recalls,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  final List<RecallItem> recalls;
  final RiskCategory? selectedCategory;
  final ValueChanged<RiskCategory?> onSelectCategory;

  @override
  State<RiskDistributionChart> createState() => _RiskDistributionChartState();
}

class _RiskDistributionChartState extends State<RiskDistributionChart> {
  _ChartMode _mode = _ChartMode.risk;
  bool _collapsed = false;
  RiskCategory? _touchedCategory;

  static Color _colorFor(RiskCategory category, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    switch (category) {
      case RiskCategory.microbiologico:
        return isDark ? const Color(0xFFFB7185) : const Color(0xFFE11D48);
      case RiskCategory.allergeni:
        return isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
      case RiskCategory.chimico:
        return isDark ? const Color(0xFFA5B4FC) : const Color(0xFF6366F1);
      case RiskCategory.fisico:
        return isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
      case RiskCategory.altro:
        return isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.recalls.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final brightness = theme.brightness;

    final counts = <RiskCategory, int>{};
    for (final item in widget.recalls) {
      counts[item.riskCategory] = (counts[item.riskCategory] ?? 0) + 1;
    }

    final total = widget.recalls.length;
    final entries = RiskCategory.values
        .map((cat) => MapEntry(cat, counts[cat] ?? 0))
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final focusCat = _touchedCategory ?? widget.selectedCategory;
    final focusedCount = focusCat != null ? (counts[focusCat] ?? 0) : total;
    final focusedPercent = ((focusedCount / total) * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _mode == _ChartMode.risk
                        ? Icons.pie_chart_outline_rounded
                        : Icons.bar_chart_rounded,
                    size: 18,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _mode == _ChartMode.risk
                            ? l10n.chartTitleRisk
                            : l10n.chartTitleTrend,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '$total ${l10n.chartNoticesWord} · ${_mode == _ChartMode.risk ? l10n.chartTapFilter : l10n.chartRecentSeries}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                SegmentedButton<_ChartMode>(
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  segments: [
                    ButtonSegment(
                      value: _ChartMode.risk,
                      label: Text(l10n.chartTabRisk),
                    ),
                    ButtonSegment(
                      value: _ChartMode.trend,
                      label: Text(l10n.chartTabTrend),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (sel) {
                    setState(() => _mode = sel.first);
                  },
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => setState(() => _collapsed = !_collapsed),
                  icon: Icon(
                    _collapsed
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_up_rounded,
                  ),
                ),
              ],
            ),
            if (!_collapsed) ...[
              const SizedBox(height: 14),
              if (_mode == _ChartMode.risk)
                Row(
                  children: [
                    SizedBox(
                      width: 132,
                      height: 132,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: entries.length > 1 ? 3 : 0,
                              centerSpaceRadius: 36,
                              pieTouchData: PieTouchData(
                                touchCallback: (event, response) {
                                  if (event is FlTapUpEvent &&
                                      response?.touchedSection != null) {
                                    final idx = response!
                                        .touchedSection!.touchedSectionIndex;
                                    if (idx >= 0 && idx < entries.length) {
                                      final cat = entries[idx].key;
                                      widget.onSelectCategory(
                                        widget.selectedCategory == cat
                                            ? null
                                            : cat,
                                      );
                                    }
                                  }
                                },
                              ),
                              sections: entries.map((entry) {
                                final isFocus =
                                    focusCat == null || focusCat == entry.key;
                                final baseColor =
                                    _colorFor(entry.key, brightness);
                                return PieChartSectionData(
                                  value: entry.value.toDouble(),
                                  color: baseColor.withValues(
                                    alpha: isFocus ? 1.0 : 0.28,
                                  ),
                                  radius: focusCat == entry.key ? 24 : 21,
                                  showTitle: false,
                                );
                              }).toList(),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                focusCat != null ? '$focusedPercent%' : '$total',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: focusCat != null
                                      ? _colorFor(focusCat, brightness)
                                      : scheme.onSurface,
                                ),
                              ),
                              Text(
                                focusCat != null
                                    ? l10n.categoryLabel(focusCat)
                                    : l10n.chartNoticesWord,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        children: entries.map((entry) {
                          final pct = ((entry.value / total) * 100).round();
                          final color = _colorFor(entry.key, brightness);
                          final active = widget.selectedCategory == entry.key;

                          return InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => widget.onSelectCategory(
                              active ? null : entry.key,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 5,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          l10n.categoryLabel(entry.key),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                            fontWeight: active
                                                ? FontWeight.w800
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${entry.value} ($pct%)',
                                        style:
                                            theme.textTheme.labelSmall?.copyWith(
                                          fontFeatures: const [
                                            FontFeature.tabularFigures(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: entry.value / total,
                                      minHeight: 4,
                                      backgroundColor:
                                          scheme.surfaceContainerHighest,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(color),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                )
              else
                _TrendBarView(recalls: widget.recalls),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrendBarView extends StatelessWidget {
  const _TrendBarView({required this.recalls});

  final List<RecallItem> recalls;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final sorted = [...recalls]
      ..sort((a, b) => a.publicationDate.compareTo(b.publicationDate));

    final buckets = <String, int>{};
    for (final r in sorted) {
      final key = DateFormat('dd/MM', l10n.dateLocale).format(r.publicationDate);
      buckets[key] = (buckets[key] ?? 0) + 1;
    }

    final keys = buckets.keys.toList();
    final recentKeys = keys.length > 6 ? keys.sublist(keys.length - 6) : keys;

    return SizedBox(
      height: 132,
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= recentKeys.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      recentKeys[i],
                      style: TextStyle(
                        fontSize: 10,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(recentKeys.length, (i) {
            final count = buckets[recentKeys[i]] ?? 0;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: count.toDouble(),
                  width: 18,
                  color: scheme.primary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
