import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../models/savings_plan.dart';
import '../../../providers/savings_provider.dart';
import '../../../utils/formatters.dart';
import 'create_draft.dart';
import '../../../l10n/app_localizations.dart';

class ReviewStep extends ConsumerStatefulWidget {
  const ReviewStep({super.key});

  @override
  ConsumerState<ReviewStep> createState() => _ReviewStepState();
}

class _ReviewStepState extends ConsumerState<ReviewStep> {
  bool _saving = false;

  Future<void> _create() async {
    final d = ref.read(createDraftProvider);
    final solved = d.solved;
    if (_saving ||
        solved == null ||
        d.amountsError != null ||
        d.product == null) {
      return;
    }
    setState(() => _saving = true);
    try {
      final plan = SavingsPlan(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: d.name.trim(),
        productType: d.product!.name,
        targetAmount: solved.$1,
        monthlyContribution: solved.$2,
        durationMonths: solved.$3,
        createdAt: DateTime.now(),
        savedAmount: d.opening,
      );
      await ref.read(savingsPlansProvider.notifier).createPlan(plan);
      if (!mounted) return;
      ref.read(createDraftProvider.notifier).goTo(CreateStep.success);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.createSaveError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final d = ref.watch(createDraftProvider);
    final s = d.solved;
    final theme = Theme.of(context);
    Widget row(String k, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k),
          Flexible(child: Text(v, textAlign: TextAlign.end)),
        ],
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(l10n.createReviewTitle, style: theme.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                row(l10n.reviewName, d.name.trim()),
                row(l10n.reviewProduct, d.product?.name ?? ''),
                if (s != null) ...[
                  row(l10n.reviewTarget, formatNaira(s.$1)),
                  row(l10n.reviewMonthly, formatNaira(s.$2)),
                  row(l10n.reviewMonths, '${s.$3}'),
                ],
                row(l10n.reviewOpeningDeposit, formatNaira(d.opening)),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          key: const Key('create-submit'),
          onPressed: _saving || d.amountsError != null ? null : _create,
          child: _saving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.createSubmit),
        ),
      ],
    );
  }
}
