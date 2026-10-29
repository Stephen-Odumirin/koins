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

/// Products matching the search text and the flexible-only switch.
final filteredProductsProvider = Provider<List<SavingsProduct>>((ref) {
  final all = ref.watch(productsProvider).value ?? const <SavingsProduct>[];
  final filter = ref.watch(productFilterProvider);
  final q = filter.query.trim().toLowerCase();

  return all.where((p) {
    final matchesQuery = q.isEmpty || p.name.toLowerCase().contains(q);
    final matchesFlexible = !filter.flexibleOnly || p.durationMonths == null;
    return matchesQuery && matchesFlexible;
  }).toList();
});
