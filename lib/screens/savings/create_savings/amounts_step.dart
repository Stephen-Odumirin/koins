import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../utils/formatters.dart';
import '../../../utils/savings_tally.dart';
import '../../../widgets/app_text_field.dart';
import 'create_draft.dart';
import '../../../l10n/app_localizations.dart';

final _commas = NumberFormat('#,###', 'en_US');

int? _parse(String v) => int.tryParse(v.replaceAll(',', '').trim());
String _text(int? v) => v == null ? '' : _commas.format(v);

class AmountsStep extends ConsumerStatefulWidget {
  const AmountsStep({super.key});

  @override
  ConsumerState<AmountsStep> createState() => _AmountsStepState();
}

class _AmountsStepState extends ConsumerState<AmountsStep> {
  late final TextEditingController _target;
  late final TextEditingController _monthly;
  late final TextEditingController _months;
  late final TextEditingController _opening;

  @override
  void initState() {
    super.initState();
    final d = ref.read(createDraftProvider);
    _target = TextEditingController(text: _text(d.inputTarget));
    _monthly = TextEditingController(text: _text(d.inputMonthly));
    _months = TextEditingController(text: _text(d.inputMonths));
    _opening = TextEditingController(
      text: d.opening == 0 ? '' : _text(d.opening),
    );
  }

  @override
  void dispose() {
    _target.dispose();
    _monthly.dispose();
    _months.dispose();
    _opening.dispose();
    super.dispose();
  }

  static final _digits = [FilteringTextInputFormatter.allow(RegExp(r'[0-9,]'))];

  void _adjust() {
    ref.read(createDraftProvider.notifier).adjust();
    final d = ref.read(createDraftProvider);
    _target.text = _text(d.inputTarget);
    _monthly.text = _text(d.inputMonthly);
  }

  Widget _field(
    String key,
    String label,
    TextEditingController c,
    ValueChanged<String> onChanged,
  ) {
    return Column(
      key: Key(key),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: c,
          label: label,
          keyboardType: TextInputType.number,
          inputFormatters: _digits,
          onChanged: onChanged,
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _locked(
    String key,
    String label,
    String text, {
    bool adjustable = false,
  }) {
    return Column(
      key: Key(key),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ReadOnlyAmount(key: ValueKey('$key-$text'), label: label, text: text),
        if (adjustable)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              key: const Key('tally-adjust'),
              onPressed: _adjust,
              child: Text(AppLocalizations.of(context)!.amountsAdjust),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final d = ref.watch(createDraftProvider);
    final n = ref.read(createDraftProvider.notifier);
    final theme = Theme.of(context);
    final solved = d.solved;
    final min = d.product?.minDeposit ?? 0;
    final error = d.solved == null
        ? d.solveError
        : d.tally.validate(min, fixedMonths: d.product?.durationMonths);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          l10n.amountsTitle,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.amountsSubtitle,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        if (d.computed == TallyField.target)
          _locked(
            'tally-target',
            l10n.amountsTargetLabel,
            _text(solved?.$1),
            adjustable: true,
          )
        else
          _field(
            'tally-target',
            l10n.amountsTargetLabel,
            _target,
            (v) => n.setTarget(_parse(v)),
          ),
        if (d.computed == TallyField.monthly)
          _locked(
            'tally-monthly',
            l10n.amountsMonthlyLabel,
            _text(solved?.$2),
            adjustable: true,
          )
        else
          _field(
            'tally-monthly',
            l10n.amountsMonthlyLabel,
            _monthly,
            (v) => n.setMonthly(_parse(v)),
          ),
        if (d.monthsLocked)
          _locked(
            'tally-months',
            l10n.amountsMonthsLockedLabel,
            _text(d.months),
          )
        else
          _field(
            'tally-months',
            l10n.amountsMonthsLabel,
            _months,
            (v) => n.setMonths(_parse(v)),
          ),
        if (solved != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(
              l10n.amountsSummary(formatNaira(solved.$2), solved.$3),
              style: theme.textTheme.titleMedium,
            ),
          ),
        if (error != null && error != 'incomplete')
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(
              error,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        _field(
          'tally-opening',
          l10n.amountsOpeningLabel,
          _opening,
          (v) => n.setOpening(_parse(v) ?? 0),
        ),
        if (d.openingError != null)
          Text(
            d.openingError!,
            style: TextStyle(color: theme.colorScheme.error),
          ),
      ],
    );
  }
}

class _ReadOnlyAmount extends StatefulWidget {
  const _ReadOnlyAmount({super.key, required this.label, required this.text});
  final String label;
  final String text;

  @override
  State<_ReadOnlyAmount> createState() => _ReadOnlyAmountState();
}

class _ReadOnlyAmountState extends State<_ReadOnlyAmount> {
  late final _c = TextEditingController(text: widget.text);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      AppTextField(controller: _c, label: widget.label, readOnly: true);
}
