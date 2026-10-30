import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../utils/formatters.dart';
import '../../../utils/naira_input_formatter.dart';
import '../../../utils/rule_error.dart';
import '../../../utils/savings_tally.dart';
import '../../../widgets/app_text_field.dart';
import 'create_draft.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/messages.dart';

int? _parse(String v) => parseNaira(v);
String _naira(int? v) => v == null ? '' : formatNaira(v);
String _plain(int? v) => v == null ? '' : '$v';

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
    _target = TextEditingController(text: _naira(d.inputTarget));
    _monthly = TextEditingController(text: _naira(d.inputMonthly));
    _months = TextEditingController(text: _plain(d.inputMonths));
    _opening = TextEditingController(
      text: d.opening == 0 ? '' : _naira(d.opening),
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

  static final _naraInput = [NairaInputFormatter()];
  static final _digits = [FilteringTextInputFormatter.digitsOnly];

  Widget _field(
    String key,
    String label,
    TextEditingController c,
    ValueChanged<String> onChanged, {
    bool naira = true,
    bool computed = false,
    String? computedText,
  }) {
    if (computed && computedText != null && c.text != computedText) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && c.text != computedText) c.text = computedText;
      });
    }
    return Column(
      key: Key(key),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: c,
          label: label,
          keyboardType: TextInputType.number,
          inputFormatters: naira ? _naraInput : _digits,
          onChanged: onChanged,
          dimmed: computed,
        ),
        const SizedBox(height: AppSpacing.md),
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
    final r = d.resolution;
    final min = d.product?.minDeposit ?? 0;
    final error = d.solved == null ? d.solveError : d.tally.validate(min);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(l10n.amountsTitle, style: theme.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(l10n.amountsSubtitle, style: theme.textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.md),
        _field(
          'tally-target',
          l10n.amountsTargetLabel,
          _target,
          (v) => n.setTarget(_parse(v)),
          computed: d.computed == TallyField.target,
          computedText: _naira(r.target),
        ),
        _field(
          'tally-monthly',
          l10n.amountsMonthlyLabel,
          _monthly,
          (v) => n.setMonthly(_parse(v)),
          computed: d.computed == TallyField.monthly,
          computedText: _naira(r.monthly),
        ),
        _field(
          'tally-months',
          l10n.amountsMonthsLabel,
          _months,
          (v) => n.setMonths(_parse(v)),
          naira: false,
          computed: d.computed == TallyField.months,
          computedText: _plain(r.months),
        ),
        if (solved != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(
              l10n.amountsSummary(formatNaira(solved.$2), solved.$3),
              style: theme.textTheme.titleMedium,
            ),
          ),
        if (error != null && error != RuleError.incomplete)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(
              l10n.ruleErrorText(error),
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
            l10n.ruleErrorText(d.openingError!),
            style: TextStyle(color: theme.colorScheme.error),
          ),
      ],
    );
  }
}
