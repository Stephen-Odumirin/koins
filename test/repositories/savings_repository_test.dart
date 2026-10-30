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

  test('dashboard seeds start with Emergency Fund and there are three', () async {
    final planDb = await openMemoryPlanDb();
    addTearDown(planDb.close);
    final repo = SavingsRepository(planDb);
    expect(repo.seedPlansForDashboard.length, 3);
    expect(repo.seedPlansForDashboard.first.name, 'Emergency Fund');
    expect(repo.seedPlansForDashboard.first.targetAmount, 120000);
  });

  test('created plan is persisted and returned', () async {
    final planDb = await openMemoryPlanDb();
    addTearDown(planDb.close);
    final repo = SavingsRepository(planDb);

    await repo.createPlan(_plan);

    expect((await repo.getUserPlans()).single.name, _plan.name);
  });
}
