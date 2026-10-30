import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/models/savings_plan.dart';
import 'package:savings_app/providers/providers.dart';
import 'package:savings_app/providers/savings_provider.dart';
import 'package:savings_app/providers/savings_totals_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/memory_plan_db.dart';

Future<ProviderContainer> _container() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final planDb = await openMemoryPlanDb();
  addTearDown(planDb.close);
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      planDatabaseProvider.overrideWithValue(planDb),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

final _plan = SavingsPlan(
  id: 'p4',
  name: 'Holiday',
  productType: 'Vacation Savings',
  targetAmount: 300000,
  monthlyContribution: 25000,
  durationMonths: 12,
  createdAt: DateTime(2026, 8, 1),
  savedAmount: 20000,
);

void main() {
  test('total is 0 while plans are loading', () async {
    final container = await _container();

    expect(container.read(totalSavingsProvider), 0);
    expect(container.read(recentPlansProvider), isEmpty);
  });

  test('total of the three seeds is 850000', () async {
    final container = await _container();
    await container.read(savingsPlansProvider.future);

    expect(container.read(totalSavingsProvider), 850000);
  });

  test('total includes the opening deposit of a created plan', () async {
    final container = await _container();
    await container.read(savingsPlansProvider.future);

    await container.read(savingsPlansProvider.notifier).createPlan(_plan);

    expect(container.read(totalSavingsProvider), 870000);
  });

  test('recent plans list the newest plan first', () async {
    final container = await _container();
    await container.read(savingsPlansProvider.future);

    await container.read(savingsPlansProvider.notifier).createPlan(_plan);

    final recent = container.read(recentPlansProvider);
    expect(recent.length, 4);
    expect(recent.first.name, 'Holiday');
    expect(recent.last.name, 'Emergency Fund');
    for (var i = 0; i < recent.length - 1; i++) {
      expect(recent[i].createdAt.isAfter(recent[i + 1].createdAt), isTrue);
    }
  });
}
