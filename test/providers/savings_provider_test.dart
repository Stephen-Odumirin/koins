import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/models/savings_plan.dart';
import 'package:savings_app/providers/providers.dart';
import 'package:savings_app/providers/savings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _container() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container;
}

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
  test('dashboard starts with the three seed plans', () async {
    final container = await _container();

    final plans = await container.read(savingsPlansProvider.future);

    expect(plans.length, 3);
    expect(plans.first.name, 'Emergency Fund');
  });

  test('created plan appears in the list after createPlan', () async {
    final container = await _container();
    await container.read(savingsPlansProvider.future);

    await container.read(savingsPlansProvider.notifier).createPlan(_plan);

    final plans = await container.read(savingsPlansProvider.future);
    expect(plans.last.name, 'Holiday');
    expect(plans.length, 4);
  });

  test('products provider returns the four brief products', () async {
    final container = await _container();

    final products = await container.read(productsProvider.future);

    expect(products.map((p) => p.name), contains('Fixed Deposit'));
    expect(products.length, 4);
  });
}
