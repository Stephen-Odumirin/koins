import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../models/savings_product.dart';
import '../../../providers/savings_provider.dart';
import '../../../utils/formatters.dart';
import 'create_draft.dart';
import '../../../l10n/app_localizations.dart';

class ProductStep extends ConsumerWidget {
  const ProductStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products =
        ref.watch(productsProvider).value ?? const <SavingsProduct>[];
    final selected = ref.watch(createDraftProvider.select((d) => d.product));
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(l10n.productStepTitle, style: theme.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.md),
        for (final p in products)
          Card(
            key: Key('product-${p.id}'),
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              side: BorderSide(
                color: p == selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
                width: p == selected ? 2 : 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              onTap: () => ref.read(createDraftProvider.notifier).setProduct(p),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.productStepSummary(
                        p.interestRate.toStringAsFixed(0),
                        p.durationLabel,
                        formatNaira(p.minDeposit),
                      ),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
