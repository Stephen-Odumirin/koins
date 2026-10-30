import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../models/savings_product.dart';
import '../l10n/app_localizations.dart';
import '../l10n/messages.dart';

class SavingsProductCard extends StatelessWidget {
  const SavingsProductCard({
    super.key,
    required this.product,
    required this.onViewDetails,
  });

  final SavingsProduct product;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg - 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.savings_outlined,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Hero(
                    tag: 'product-name-${product.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        AppLocalizations.of(context)!.productName(product),
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    l10n.productInterestChip('${product.interestRate.round()}'),
                  ),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: AppColors.accent.withValues(alpha: 0.25),
                  labelStyle: TextStyle(color: scheme.onSurface),
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.productDescription(product),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 18, color: scheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  AppLocalizations.of(
                    context,
                  )!.durationText(product.durationMonths),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // The theme's pill button is full width; keep it out of a Row.
            FilledButton.tonal(
              onPressed: onViewDetails,
              child: Text(l10n.productViewDetails),
            ),
          ],
        ),
      ),
    );
  }
}
