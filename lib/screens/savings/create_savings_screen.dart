import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../models/savings_product.dart';
import 'create_savings/amounts_step.dart';
import 'create_savings/create_draft.dart';
import 'create_savings/name_step.dart';
import 'create_savings/product_step.dart';
import 'create_savings/review_step.dart';
import 'create_savings/success_step.dart';
import '../../l10n/app_localizations.dart';

/// Create savings as a stepper. The draft lives in a provider scoped to this
/// screen, so leaving it discards what was entered.
class CreateSavingsScreen extends StatelessWidget {
  const CreateSavingsScreen({super.key, this.initialProduct});

  final SavingsProduct? initialProduct;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        createDraftProvider.overrideWith(
          () => CreateDraftNotifier(initialProduct),
        ),
      ],
      child: const _Flow(),
    );
  }
}

class _Flow extends ConsumerWidget {
  const _Flow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final d = ref.watch(createDraftProvider);
    final n = ref.read(createDraftProvider.notifier);
    final done = d.step == CreateStep.success;
    final showNext = d.step.index < CreateStep.review.index;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createSavings),
        automaticallyImplyLeading: false,
        leading: done
            ? null
            : IconButton(
                key: const Key('create-back'),
                icon: const Icon(Icons.arrow_back),
                onPressed: d.step == CreateStep.name
                    ? () => Navigator.of(context).maybePop()
                    : n.back,
              ),
        bottom: done
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(
                  value: (d.step.index + 1) / (CreateStep.review.index + 1),
                ),
              ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: switch (d.step) {
            CreateStep.name => const NameStep(),
            CreateStep.product => const ProductStep(),
            CreateStep.amounts => const AmountsStep(),
            CreateStep.review => const ReviewStep(),
            CreateStep.success => const SuccessStep(),
          },
        ),
      ),
      bottomNavigationBar: showNext
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: FilledButton(
                  key: const Key('create-next'),
                  onPressed: d.canContinue ? n.next : null,
                  child: Text(l10n.next),
                ),
              ),
            )
          : null,
    );
  }
}
