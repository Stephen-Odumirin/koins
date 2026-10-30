import 'package:flutter/material.dart';

import '../models/savings_plan.dart';
import '../utils/formatters.dart';
import '../utils/plan_progress.dart';
import 'progress_ring.dart';
import '../l10n/app_localizations.dart';

class SavingsPlanTile extends StatelessWidget {
  const SavingsPlanTile({super.key, required this.plan, this.onTap});

  final SavingsPlan plan;

  /// Called when the tile is tapped; the tile is not tappable when null.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final progress = planProgress(plan);

    return Card(
      color: scheme.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ProgressRing(
                progress: progress,
                color: scheme.primary,
                trackColor: scheme.surfaceContainerHighest,
                size: 52,
                child: Text(
                  l10n.percentValue((progress * 100).round()),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      l10n.planTileSubtitle(plan.productType),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatNaira(plan.targetAmount),
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    l10n.planTilePerMonth(formatNaira(plan.monthlyContribution)),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
