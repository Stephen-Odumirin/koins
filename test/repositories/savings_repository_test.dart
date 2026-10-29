import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/models/savings_plan.dart';
import 'package:savings_app/repositories/savings_repository.dart';
import 'package:savings_app/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  test('dashboard seeds start with Emergency Fund and there are three', () {
    SharedPreferences.setMockInitialValues({});
    return SharedPreferences.getInstance().then((prefs) {
      final repo = SavingsRepository(LocalStorageService(prefs));
      expect(repo.seedPlansForDashboard.length, 3);
      expect(repo.seedPlansForDashboard.first.name, 'Emergency Fund');
      expect(repo.seedPlansForDashboard.first.targetAmount, 120000);
    });
  });

  test('created plan is persisted and returned', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = SavingsRepository(LocalStorageService(prefs));

    await repo.createPlan(_plan);

    expect((await repo.getUserPlans()).single.name, _plan.name);
  });
}
