import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../models/savings_plan.dart';
import '../../utils/formatters.dart';
import '../../utils/plan_progress.dart';
import '../../widgets/progress_ring.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/messages.dart';

/// One saved plan: its facts and how much of the target is saved.
class SavedPlanDetailsScreen extends StatelessWidget {
  const SavedPlanDetailsScreen({super.key, required this.plan});

  final SavingsPlan plan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final progress = planProgress(plan);

    return Scaffold(
      appBar: AppBar(title: Text(plan.name)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Card(
                color: scheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      ProgressRing(
                        progress: progress,
                        color: scheme.primary,
                        trackColor: scheme.surfaceContainerHighest,
                        size: 160,
                        strokeWidth: 12,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.percentValue((progress * 100).round()),
                              style: theme.textTheme.headlineSmall,
                            ),
                            Text(
                              l10n.planSavedLabel,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(plan.name, style: theme.textTheme.titleMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Card(
                color: scheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Column(
                    children: [
                      _Row(
                        l10n.planProductType,
                        l10n.planProductTypeText(plan.productType),
                      ),
                      _Row(l10n.planTarget, formatNaira(plan.targetAmount)),
                      _Row(l10n.planSavedSoFar, formatNaira(plan.savedAmount)),
                      _Row(
                        l10n.planMonthlyContribution,
                        formatNaira(plan.monthlyContribution),
                      ),
                      _Row(
                        l10n.planDuration,
                        l10n.planDurationMonths(plan.durationMonths),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
