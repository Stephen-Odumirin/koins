import 'package:flutter/material.dart';

import '../../models/savings_product.dart';
import '../savings/create_savings_screen.dart';
import '../../core/theme/app_spacing.dart';
import '../../utils/formatters.dart';
import '../../widgets/staggered_reveal.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, required this.product});

  final SavingsProduct product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Plan details')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              StaggeredReveal(
                index: 0,
                child: Hero(
                  tag: 'product-name-${product.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      product.name,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              StaggeredReveal(
                index: 1,
                child: Text(
                  product.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              StaggeredReveal(
                index: 2,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Stat(
                        label: 'Interest rate',
                        value: '${product.interestRate.round()}%',
                      ),
                      const SizedBox(width: 12),
                      _Stat(
                        label: 'Minimum deposit',
                        value: formatNaira(product.minDeposit),
                      ),
                      const SizedBox(width: 12),
                      _Stat(label: 'Duration', value: product.durationLabel),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              StaggeredReveal(
                index: 3,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          CreateSavingsScreen(initialProduct: product),
                    ),
                  ),
                  child: const Text('Create savings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard - 4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: theme.textTheme.titleMedium),
            ),
          ],
        ),
      ),
    );
  }
}
