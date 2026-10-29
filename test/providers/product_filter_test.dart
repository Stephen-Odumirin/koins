import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/providers/product_filter_provider.dart';
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
  await container.read(productsProvider.future);
  return container;
}

void main() {
  test('search matches product name case-insensitively', () async {
    final container = await _container();

    container.read(productFilterProvider.notifier).setQuery('FIXED');

    final results = container.read(filteredProductsProvider);
    expect(results.map((p) => p.name), ['Fixed Deposit']);
  });

  test('flexible-only keeps products with no fixed duration', () async {
    final container = await _container();

    container.read(productFilterProvider.notifier).setFlexibleOnly(true);

    final names = container.read(filteredProductsProvider).map((p) => p.name);
    expect(names, containsAll(['Education Savings', 'Vacation Savings']));
    expect(names, isNot(contains('Fixed Deposit')));
  });

  test('blank query returns everything', () async {
    final container = await _container();

    container.read(productFilterProvider.notifier).setQuery('   ');

    expect(container.read(filteredProductsProvider).length, 4);
  });
}
