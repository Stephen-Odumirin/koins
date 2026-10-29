import 'package:flutter/material.dart';

import '../models/savings_product.dart';

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

    return Card(
      color: scheme.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                        product.name,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ),
                ),
                Chip(
                  label: Text('${product.interestRate.round()}% p.a.'),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: scheme.tertiaryContainer,
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              product.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 18, color: scheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(product.durationLabel, style: theme.textTheme.bodySmall),
                const Spacer(),
                FilledButton.tonal(
                  onPressed: onViewDetails,
                  child: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
