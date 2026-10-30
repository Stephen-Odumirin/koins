import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/utils/savings_tally.dart';

void main() {
  test('target and months give the monthly amount', () {
    final r = const SavingsTally(
      target: 120000,
      months: 12,
    ).solve(TallyField.target);
    expect(r, (120000, 10000, 12));
  });

  test('monthly and months give the target', () {
    final r = const SavingsTally(
      monthly: 10000,
      months: 12,
    ).solve(TallyField.monthly);
    expect(r, (120000, 10000, 12));
  });

  test('a target that does not divide by the months is an error', () {
    const t = SavingsTally(target: 100000, months: 12);
    expect(t.solve(TallyField.target), isNull);
    expect(
      t.solveError(TallyField.target),
      'Target must be a multiple of the months.',
    );
  });

  test('monthly below the product minimum is an error', () {
    const t = SavingsTally(target: 12000, monthly: 1000, months: 12);
    expect(t.validate(5000), isNotNull);
    expect(t.validate(1000), isNull);
  });

  test('months must be whole 1 to 60', () {
    expect(
      const SavingsTally(target: 10, monthly: 10, months: 0).validate(1),
      isNotNull,
    );
    expect(
      const SavingsTally(target: 610, monthly: 10, months: 61).validate(1),
      isNotNull,
    );
    expect(
      const SavingsTally(target: 600, monthly: 10, months: 60).validate(1),
      isNull,
    );
  });

  test('a fixed-term product rejects a different months', () {
    const t = SavingsTally(target: 60000, monthly: 10000, months: 6);
    expect(t.validate(5000, fixedMonths: 12), isNotNull);
    expect(t.validate(5000, fixedMonths: 6), isNull);
  });

  test('target must be positive and must tally', () {
    expect(
      const SavingsTally(target: 0, monthly: 0, months: 3).validate(0),
      isNotNull,
    );
    expect(
      const SavingsTally(target: 100, monthly: 30, months: 3).validate(1),
      isNotNull,
    );
  });
}
