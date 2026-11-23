import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/recall_item.dart';
import '../theme/app_theme.dart';

class RiskBadge extends StatelessWidget {
  const RiskBadge({super.key, required this.category});

  final RiskCategory category;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = l10n.categoryLabel(category);
    final style = RiskVisualStyle.of(category, Theme.of(context).brightness);

    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: style.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(style.icon, size: 15, color: style.foreground),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: style.foreground,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewRecallBadge extends StatelessWidget {
  const NewRecallBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        l10n.newBadge,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
      ),
    );
  }
}
