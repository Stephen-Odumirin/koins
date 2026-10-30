/// The three linked amounts of a savings plan: target = monthly x months.
enum TallyField { target, monthly, months }

class SavingsTally {
  const SavingsTally({this.target, this.monthly, this.months});

  final int? target;
  final int? monthly;
  final int? months;

  static const maxMonths = 60;
  static const notMultiple = 'Target must be a multiple of the months.';

  /// Computes the amount the user did not just edit. Editing the target
  /// derives the monthly amount; editing the monthly amount or the months
  /// derives the target. Returns null when the inputs are missing or the
  /// target does not divide exactly (see [solveError]).
  (int target, int monthly, int months)? solve(TallyField editedLast) {
    final m = months;
    if (m == null || m < 1) return null;
    if (editedLast == TallyField.target) {
      final t = target;
      if (t == null || t % m != 0) return null;
      return (t, t ~/ m, m);
    }
    final mo = monthly;
    if (mo != null) return (mo * m, mo, m);
    final t = target;
    if (editedLast == TallyField.months && t != null && t % m == 0) {
      return (t, t ~/ m, m);
    }
    return null;
  }

  String? solveError(TallyField editedLast) {
    final m = months;
    final t = target;
    if (editedLast == TallyField.target && t != null && m != null && m >= 1) {
      if (t % m != 0) return notMultiple;
    }
    return null;
  }

  /// Checks a complete tally. [fixedMonths] is the duration of a fixed-term
  /// product; the months must equal it.
  String? validate(int minMonthly, {int? fixedMonths}) {
    final t = target, mo = monthly, m = months;
    if (t == null || mo == null || m == null) return 'Complete the amounts.';
    if (t <= 0) return 'Target must be more than zero.';
    if (m < 1 || m > maxMonths) {
      return 'Months must be a whole number from 1 to $maxMonths.';
    }
    if (fixedMonths != null && m != fixedMonths) {
      return 'This product runs for $fixedMonths months.';
    }
    if (mo < minMonthly) return 'Monthly amount is below the minimum.';
    if (mo * m != t) return notMultiple;
    return null;
  }
}
