import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/models/savings_plan.dart';
import 'package:savings_app/utils/plan_progress.dart';

SavingsPlan _plan(int target, int saved) => SavingsPlan(
      id: 'x',
      name: 'x',
      productType: 'x',
      targetAmount: target,
      monthlyContribution: 1,
      durationMonths: 12,
      createdAt: DateTime(2026, 1, 1),
      savedAmount: saved,
    );

void main() {
  test('progress is saved over target', () {
    expect(planProgress(_plan(350000, 280000)), closeTo(0.8, 1e-9));
  });

  test('zero target gives 0', () {
    expect(planProgress(_plan(0, 100)), 0);
  });

  test('over-saved clamps to 1', () {
    expect(planProgress(_plan(100, 250)), 1);
  });
}
