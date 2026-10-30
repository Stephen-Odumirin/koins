import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/utils/savings_tally.dart';
import 'package:savings_app/utils/rule_error.dart';
import 'package:savings_app/screens/savings/create_savings/create_draft.dart';

void main() {
  const t = TallyField.target, mo = TallyField.monthly, m = TallyField.months;

  test('target then monthly computes the months', () {
    final r = SavingsTally.resolve(
      target: 120000,
      monthly: 10000,
      edits: [t, mo],
    );
    expect(r.computed, m);
    expect(r.months, 12);
    expect(r.error, isNull);
    expect(r.complete, isTrue);
    expect(
      SavingsTally.resolve(target: 12000, monthly: 1000, edits: [t, mo]).months,
      12,
    );
  });

  test('monthly then months computes the target', () {
    final r = SavingsTally.resolve(monthly: 10000, months: 12, edits: [mo, m]);
    expect(r.computed, t);
    expect(r.target, 120000);
  });

  test('target then months computes the monthly', () {
    final r = SavingsTally.resolve(target: 120000, months: 12, edits: [t, m]);
    expect(r.computed, mo);
    expect(r.monthly, 10000);
  });

  test('nothing edited defaults to target and months as inputs', () {
    expect(SavingsTally.resolve().computed, mo);
    expect(SavingsTally.resolve(edits: [mo]).computed, t);
  });

  test('the two latest edits win over an older one', () {
    // target, months, then monthly: the target is oldest, so it is computed.
    final r = SavingsTally.resolve(
      target: 999,
      monthly: 10000,
      months: 3,
      edits: [t, m, mo],
    );
    expect(r.computed, t);
    expect(r.target, 30000);
  });

  test('a target that does not divide by the months is an error', () {
    final r = SavingsTally.resolve(target: 100000, months: 12, edits: [t, m]);
    expect(r.monthly, isNull);
    expect(r.error, RuleError.notMultipleOfMonths);
    expect(r.complete, isFalse);
  });

  test('computed months must be whole and from 1 to 60', () {
    expect(
      SavingsTally.resolve(
        target: 100000,
        monthly: 30000,
        edits: [t, mo],
      ).error,
      RuleError.notMultipleOfMonthly,
    );
    expect(
      SavingsTally.resolve(
        target: 1000000,
        monthly: 1000,
        edits: [t, mo],
      ).error,
      RuleError.monthsRange,
    );
  });

  test('monthly below the product minimum is an error', () {
    const t = SavingsTally(target: 12000, monthly: 1000, months: 12);
    expect(t.validate(5000), RuleError.belowMinimum);
    expect(t.validate(1000), isNull);
  });

  test('months must be whole 1 to 60', () {
    expect(
      const SavingsTally(target: 10, monthly: 10, months: 0).validate(1),
      RuleError.monthsRange,
    );
    expect(
      const SavingsTally(target: 610, monthly: 10, months: 61).validate(1),
      RuleError.monthsRange,
    );
    expect(
      const SavingsTally(target: 600, monthly: 10, months: 60).validate(1),
      isNull,
    );
  });

  test('target must be positive and must tally', () {
    expect(
      const SavingsTally(target: 0, monthly: 0, months: 3).validate(0),
      RuleError.targetNotPositive,
    );
    expect(
      const SavingsTally(target: 100, monthly: 30, months: 3).validate(1),
      RuleError.notMultipleOfMonths,
    );
  });

  test('an opening deposit above the target is flagged', () {
    const d = SavingsDraft(
      inputTarget: 120000,
      inputMonthly: 10000,
      opening: 130000,
      edits: [TallyField.target, TallyField.monthly],
    );
    expect(d.openingError, RuleError.openingExceedsTarget);
    expect(d.copyWith(opening: 1000).openingError, isNull);
  });
}
