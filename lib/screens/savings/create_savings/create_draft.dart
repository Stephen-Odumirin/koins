import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/savings_product.dart';
import '../../../utils/savings_tally.dart';

enum CreateStep { name, product, amounts, review, success }

/// What the user has entered so far. The user edits months and one of target
/// or monthly; [computed] names which of those two is derived.
class SavingsDraft {
  const SavingsDraft({
    this.step = CreateStep.name,
    this.name = '',
    this.product,
    this.inputTarget,
    this.inputMonthly,
    this.inputMonths,
    this.opening = 0,
    this.computed = TallyField.monthly,
  });

  final CreateStep step;
  final String name;
  final SavingsProduct? product;
  final int? inputTarget;
  final int? inputMonthly;
  final int? inputMonths;
  final int opening;
  final TallyField computed;

  int? get months => product?.durationMonths ?? inputMonths;
  bool get monthsLocked => product?.durationMonths != null;

  TallyField get _edited =>
      computed == TallyField.monthly ? TallyField.target : TallyField.monthly;

  SavingsTally get _input => SavingsTally(
    target: computed == TallyField.target ? null : inputTarget,
    monthly: computed == TallyField.monthly ? null : inputMonthly,
    months: months,
  );

  /// The resolved target, monthly and months, or null while unresolved.
  (int, int, int)? get solved => _input.solve(_edited);

  String? get solveError => _input.solveError(_edited);

  SavingsTally get tally {
    final s = solved;
    return s == null
        ? const SavingsTally()
        : SavingsTally(target: s.$1, monthly: s.$2, months: s.$3);
  }

  String? get openingError {
    final s = solved;
    if (s != null && opening > s.$1) {
      return 'Opening deposit cannot exceed the target.';
    }
    return null;
  }

  /// Why the amounts cannot be accepted, or null when they can. Missing
  /// input returns a non-null placeholder with no message shown.
  String? get amountsError {
    if (solved == null) return solveError ?? 'incomplete';
    return tally.validate(
          product?.minDeposit ?? 0,
          fixedMonths: product?.durationMonths,
        ) ??
        openingError;
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
    TallyField? computed,
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
    computed: computed ?? this.computed,
  );

  static const _keep = Object();
}

class CreateDraftNotifier extends Notifier<SavingsDraft> {
  CreateDraftNotifier([this._initialProduct]);
  final SavingsProduct? _initialProduct;

  @override
  SavingsDraft build() => SavingsDraft(product: _initialProduct);

  void setName(String v) => state = state.copyWith(name: v);
  void setProduct(SavingsProduct p) => state = state.copyWith(product: p);
  void setTarget(int? v) => state = state.copyWith(inputTarget: v);
  void setMonthly(int? v) => state = state.copyWith(inputMonthly: v);
  void setMonths(int? v) => state = state.copyWith(inputMonths: v);
  void setOpening(int v) => state = state.copyWith(opening: v);

  /// Unlocks the computed field and computes the other one instead.
  void adjust() {
    final s = state;
    final solved = s.solved;
    final next = s.computed == TallyField.monthly
        ? TallyField.target
        : TallyField.monthly;
    state = s.copyWith(
      computed: next,
      inputTarget: solved?.$1 ?? s.inputTarget,
      inputMonthly: solved?.$2 ?? s.inputMonthly,
    );
  }

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
