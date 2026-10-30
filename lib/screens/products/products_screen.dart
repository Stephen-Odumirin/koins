import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../models/savings_product.dart';
import '../../providers/product_filter_provider.dart';
import '../../providers/savings_provider.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/savings_product_card.dart';
import '../../widgets/staggered_reveal.dart';
import 'product_details_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/messages.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final products = ref.watch(productsProvider);
    final filter = ref.watch(productFilterProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.productsTitle)),
      body: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  12,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      key: const Key('product-search'),
                      controller: _search,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: l10n.productsSearchHint,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _search.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: l10n.productsClearSearch,
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _search.clear();
                                  ref
                                      .read(productFilterProvider.notifier)
                                      .setQuery('');
                                  setState(() {});
                                },
                              ),
                      ),
                      onChanged: (value) {
                        ref
                            .read(productFilterProvider.notifier)
                            .setQuery(value);
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FilterChip(
                      shape: const StadiumBorder(),
                      key: const Key('flexible-filter'),
                      label: Text(l10n.productsFlexibleOnly),
                      selected: filter.flexibleOnly,
                      onSelected: (value) => ref
                          .read(productFilterProvider.notifier)
                          .setFlexibleOnly(value),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: products.when(
              loading: () => const LoadingView(),
              error: (_, _) => ErrorView(
                message: l10n.productsLoadError,
                onRetry: () => ref.invalidate(productsProvider),
              ),
              data: (_) {
                final q = ref
                    .watch(productFilterProvider)
                    .query
                    .trim()
                    .toLowerCase();
                final list = ref
                    .watch(filteredProductsProvider)
                    .where(
                      (p) =>
                          q.isEmpty ||
                          l10n.productName(p).toLowerCase().contains(q),
                    )
                    .toList();
                if (list.isEmpty) {
                  return EmptyView(
                    icon: Icons.search_off,
                    message: l10n.productsNoMatch,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(productsProvider);
                    await ref.read(productsProvider.future);
                  },
                  child: _ProductList(products: list),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  const _ProductList({required this.products});

  final List<SavingsProduct> products;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: products.length,
          itemBuilder: (context, i) {
            final product = products[i];
            return StaggeredReveal(
              index: i,
              child: SavingsProductCard(
                product: product,
                onViewDetails: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ProductDetailsScreen(product: product),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
