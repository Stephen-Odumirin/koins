import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/models/savings_plan.dart';
import 'package:savings_app/utils/plan_progress.dart';

SavingsPlan _plan(DateTime createdAt, int months) => SavingsPlan(
      id: 'x',
      name: 'x',
      productType: 'x',
      targetAmount: 1,
      monthlyContribution: 1,
      durationMonths: months,
      createdAt: createdAt,
    );

void main() {
  test('about half way through a 12 month plan is about 0.5', () {
    final plan = _plan(DateTime(2026, 1, 1), 12);
    final progress = planTimeProgress(plan, DateTime(2026, 7, 1));
    expect(progress, closeTo(0.5, 0.02));
  });

  test('future start clamps to 0', () {
    final plan = _plan(DateTime(2027, 1, 1), 12);
    expect(planTimeProgress(plan, DateTime(2026, 7, 1)), 0);
  });

  test('past the end clamps to 1', () {
    final plan = _plan(DateTime(2020, 1, 1), 6);
    expect(planTimeProgress(plan, DateTime(2026, 7, 1)), 1);
  });
}
