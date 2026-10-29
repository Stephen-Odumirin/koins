import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/models/savings_plan.dart';
import 'package:savings_app/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _plan = SavingsPlan(
  id: 'p1',
  name: 'Emergency Fund',
  productType: 'Fixed Deposit',
  targetAmount: 120000,
  monthlyContribution: 10000,
  durationMonths: 12,
  createdAt: DateTime(2026, 1, 1),
);

void main() {
  test('plans round-trip through storage', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService(await SharedPreferences.getInstance());

    await storage.savePlans([_plan]);

    expect(storage.loadPlans().single.name, _plan.name);
  });

  test('corrupt stored plans return empty list', () async {
    SharedPreferences.setMockInitialValues({'savings_plans': 'not json'});
    final storage = LocalStorageService(await SharedPreferences.getInstance());

    expect(storage.loadPlans(), isEmpty); // Review Focus 4
  });

  test('logged-in email persists and clears', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService(await SharedPreferences.getInstance());

    await storage.saveLoggedInEmail('test@bank.com');
    expect(storage.loggedInEmail, 'test@bank.com');

    await storage.clearLoggedInUser();
    expect(storage.loggedInEmail, isNull);
  });
}
