import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/formatters.dart';
import 'create_draft.dart';

class SuccessStep extends ConsumerWidget {
  const SuccessStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final d = ref.watch(createDraftProvider);
    final s = d.solved;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Center(
                    child: Container(
                      key: const Key('success-badge'),
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 56,
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.createSuccess,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    d.name.trim(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                  if (s != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Tile(
                          label: l10n.reviewTarget,
                          value: formatNaira(s.$1),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _Tile(
                          label: l10n.reviewMonthly,
                          value: formatNaira(s.$2),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _Tile(
                          label: l10n.successDuration,
                          value: l10n.successMonths(s.$3),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            FilledButton(
              key: const Key('create-done'),
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: Text(l10n.createBackToHome),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: theme.textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}
