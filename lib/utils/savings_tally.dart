import 'rule_error.dart';

/// The three linked amounts of a savings plan: target = monthly x months.
enum TallyField { target, monthly, months }

class SavingsTally {
  const SavingsTally({this.target, this.monthly, this.months});

  final int? target;
  final int? monthly;
  final int? months;

  static const maxMonths = 60;

  /// Works out the third amount from the two most recently edited ones.
  /// [edits] lists the edited fields, most recent last; with fewer than two
  /// distinct edits the target and months are the inputs.
  static TallyResolution resolve({
    int? target,
    int? monthly,
    int? months,
    List<TallyField> edits = const [],
  }) {
    final eff = <TallyField>[];
    for (final f in [TallyField.target, TallyField.months, ...edits]) {
      eff.remove(f);
      eff.add(f);
    }
    final inputs = eff.sublist(eff.length - 2);
    final computed = TallyField.values.firstWhere((f) => !inputs.contains(f));
    RuleError? error;
    switch (computed) {
      case TallyField.target:
        if (monthly != null && months != null) target = monthly * months;
        if (months != null && (months < 1 || months > maxMonths)) {
          error = RuleError.monthsRange;
        }
      case TallyField.monthly:
        if (months != null && months < 1) {
          error = RuleError.monthsRange;
        } else if (target != null && months != null) {
          if (target % months != 0) {
            error = RuleError.notMultipleOfMonths;
          } else {
            monthly = target ~/ months;
          }
        }
      case TallyField.months:
        if (target != null && monthly != null && monthly > 0) {
          if (target % monthly != 0) {
            error = RuleError.notMultipleOfMonthly;
          } else {
            months = target ~/ monthly;
            if (months < 1 || months > maxMonths) error = RuleError.monthsRange;
          }
        }
    }
    if (error != null) {
      switch (computed) {
        case TallyField.target:
          break;
        case TallyField.monthly:
          monthly = null;
        case TallyField.months:
          months = null;
      }
    }
    return TallyResolution(
      computed: computed,
      target: target,
      monthly: monthly,
      months: months,
      error: error,
    );
  }

  /// Checks a complete tally.
  RuleError? validate(int minMonthly) {
    final t = target, mo = monthly, m = months;
    if (t == null || mo == null || m == null) return RuleError.incomplete;
    if (t <= 0) return RuleError.targetNotPositive;
    if (m < 1 || m > maxMonths) return RuleError.monthsRange;
    if (mo < minMonthly) return RuleError.belowMinimum;
    if (mo * m != t) return RuleError.notMultipleOfMonths;
    return null;
  }
}

/// The outcome of [SavingsTally.resolve]: all three amounts where they can
/// be known, which one was computed, and any problem with the arithmetic.
class TallyResolution {
  const TallyResolution({
    required this.computed,
    this.target,
    this.monthly,
    this.months,
    this.error,
  });

  final TallyField computed;
  final int? target;
  final int? monthly;
  final int? months;
  final RuleError? error;

  bool get complete =>
      error == null && target != null && monthly != null && months != null;
}
