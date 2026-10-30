import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/savings_product.dart';
import '../../../utils/rule_error.dart';
import '../../../utils/savings_tally.dart';

enum CreateStep { name, product, amounts, review, success }

/// What the user has entered so far. The two most recently edited amounts
/// ([edits], most recent last) are the inputs; the third is computed.
class SavingsDraft {
  const SavingsDraft({
    this.step = CreateStep.name,
    this.name = '',
    this.product,
    this.inputTarget,
    this.inputMonthly,
    this.inputMonths,
    this.opening = 0,
    this.edits = const [],
  });

  final CreateStep step;
  final String name;
  final SavingsProduct? product;
  final int? inputTarget;
  final int? inputMonthly;
  final int? inputMonths;
  final int opening;
  final List<TallyField> edits;

  int? get months => inputMonths;

  TallyResolution get resolution => SavingsTally.resolve(
    target: inputTarget,
    monthly: inputMonthly,
    months: inputMonths,
    edits: edits,
  );

  TallyField get computed => resolution.computed;

  /// The resolved target, monthly and months, or null while unresolved.
  (int, int, int)? get solved {
    final r = resolution;
    return r.complete ? (r.target!, r.monthly!, r.months!) : null;
  }

  RuleError? get solveError => resolution.error;

  SavingsTally get tally {
    final s = solved;
    return s == null
        ? const SavingsTally()
        : SavingsTally(target: s.$1, monthly: s.$2, months: s.$3);
  }

  RuleError? get openingError {
    final s = solved;
    if (s != null && opening > s.$1) return RuleError.openingExceedsTarget;
    return null;
  }

  /// Why the amounts cannot be accepted, or null when they can. Missing
  /// input returns a non-null placeholder with no message shown.
  RuleError? get amountsError {
    if (solved == null) return solveError ?? RuleError.incomplete;
    return tally.validate(product?.minDeposit ?? 0) ?? openingError;
  }

  bool get nameValid => name.trim().isNotEmpty && name.trim().length <= 40;

  bool get canContinue => switch (step) {
    CreateStep.name => nameValid,
    CreateStep.product => product != null,
    CreateStep.amounts => amountsError == null,
    _ => false,
  };

  SavingsDraft copyWith({
    CreateStep? step,
    String? name,
    SavingsProduct? product,
    Object? inputTarget = _keep,
    Object? inputMonthly = _keep,
    Object? inputMonths = _keep,
    int? opening,
    List<TallyField>? edits,
  }) => SavingsDraft(
    step: step ?? this.step,
    name: name ?? this.name,
    product: product ?? this.product,
    inputTarget: identical(inputTarget, _keep)
        ? this.inputTarget
        : inputTarget as int?,
    inputMonthly: identical(inputMonthly, _keep)
        ? this.inputMonthly
        : inputMonthly as int?,
    inputMonths: identical(inputMonths, _keep)
        ? this.inputMonths
        : inputMonths as int?,
    opening: opening ?? this.opening,
    edits: edits ?? this.edits,
  );

  static const _keep = Object();
}

class CreateDraftNotifier extends Notifier<SavingsDraft> {
  CreateDraftNotifier([this._initialProduct]);
  final SavingsProduct? _initialProduct;

  @override
  SavingsDraft build() => SavingsDraft(
    product: _initialProduct,
    // The product's term is only the default; months stays editable.
    inputMonths: _initialProduct?.durationMonths,
  );

  void setName(String v) => state = state.copyWith(name: v);
  void setProduct(SavingsProduct p) => state = state.copyWith(
    product: p,
    inputMonths: state.edits.contains(TallyField.months)
        ? state.inputMonths
        : p.durationMonths,
  );
  List<TallyField> _edited(TallyField f) => [
    ...state.edits.where((e) => e != f),
    f,
  ];

  void setTarget(int? v) =>
      state = state.copyWith(inputTarget: v, edits: _edited(TallyField.target));
  void setMonthly(int? v) => state = state.copyWith(
    inputMonthly: v,
    edits: _edited(TallyField.monthly),
  );
  void setMonths(int? v) =>
      state = state.copyWith(inputMonths: v, edits: _edited(TallyField.months));
  void setOpening(int v) => state = state.copyWith(opening: v);

  void goTo(CreateStep step) => state = state.copyWith(step: step);

  void next() {
    final i = state.step.index;
    if (state.canContinue) goTo(CreateStep.values[i + 1]);
  }

  void back() {
    final i = state.step.index;
    if (i > 0) goTo(CreateStep.values[i - 1]);
  }
}

final createDraftProvider = NotifierProvider<CreateDraftNotifier, SavingsDraft>(
  CreateDraftNotifier.new,
);
