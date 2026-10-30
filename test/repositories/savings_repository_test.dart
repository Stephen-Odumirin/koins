import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/models/savings_plan.dart';
import 'package:savings_app/repositories/savings_repository.dart';

import '../helpers/memory_plan_db.dart';

final _plan = SavingsPlan(
  id: 'p1',
  name: 'Holiday',
  productType: 'Vacation Savings',
  targetAmount: 300000,
  monthlyContribution: 25000,
  durationMonths: 12,
  createdAt: DateTime(2026, 2, 1),
);

void main() {
  test('products match the brief', () {
    final names = SavingsRepository.products.map((p) => p.name);
    expect(names, [
      'Target Savings',
      'Fixed Deposit',
      'Education Savings',
      'Vacation Savings',
    ]);
  });

  test('getUserPlans returns the three seeds first', () async {
    final planDb = await openMemoryPlanDb();
    addTearDown(planDb.close);
    final plans = await SavingsRepository(planDb).getUserPlans();
    expect(plans.length, 3);
    expect(plans.first.name, 'Emergency Fund');
    expect(plans.first.targetAmount, 120000);
  });

  test('created plan is persisted and returned', () async {
    final planDb = await openMemoryPlanDb();
    addTearDown(planDb.close);
    final repo = SavingsRepository(planDb);

    await repo.createPlan(_plan);

    expect((await repo.getUserPlans()).last.name, _plan.name);
  });
}
