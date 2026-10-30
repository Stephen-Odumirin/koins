import 'package:flutter/material.dart';

import '../models/savings_plan.dart';
import '../utils/formatters.dart';
import '../utils/plan_progress.dart';
import 'progress_ring.dart';

class SavingsPlanTile extends StatelessWidget {
  const SavingsPlanTile({super.key, required this.plan, this.onTap});

  final SavingsPlan plan;

  /// Called when the tile is tapped; the tile is not tappable when null.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
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
                  '${(progress * 100).round()}%',
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
                      '${plan.productType} · Monthly',
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
                    '${formatNaira(plan.monthlyContribution)} / mo',
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
