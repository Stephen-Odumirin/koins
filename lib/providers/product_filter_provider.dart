import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/savings_product.dart';
import 'savings_provider.dart';

class ProductFilter {
  const ProductFilter({this.query = '', this.flexibleOnly = false});

  final String query;
  final bool flexibleOnly;

  ProductFilter copyWith({String? query, bool? flexibleOnly}) => ProductFilter(
    query: query ?? this.query,
    flexibleOnly: flexibleOnly ?? this.flexibleOnly,
  );
}

class ProductFilterNotifier extends Notifier<ProductFilter> {
  @override
  ProductFilter build() => const ProductFilter();

  void setQuery(String query) => state = state.copyWith(query: query);

  void setFlexibleOnly(bool value) =>
      state = state.copyWith(flexibleOnly: value);
}

final productFilterProvider =
    NotifierProvider<ProductFilterNotifier, ProductFilter>(
      ProductFilterNotifier.new,
    );

/// Products matching the flexible-only switch. The search text is matched
/// against the localized name in the products screen.
final filteredProductsProvider = Provider<List<SavingsProduct>>((ref) {
  final all = ref.watch(productsProvider).value ?? const <SavingsProduct>[];
  final filter = ref.watch(productFilterProvider);

  return all
      .where((p) => !filter.flexibleOnly || p.durationMonths == null)
      .toList();
});
