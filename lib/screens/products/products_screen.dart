import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/savings_product.dart';
import '../../providers/savings_provider.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/savings_product_card.dart';
import '../../widgets/staggered_reveal.dart';
import 'product_details_screen.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Savings products')),
      body: products.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(
          message: 'Could not load products.',
          onRetry: () => ref.invalidate(productsProvider),
        ),
        data: (list) => list.isEmpty
            ? const EmptyView(
                icon: Icons.inventory_2_outlined,
                message: 'No savings products are available right now.',
              )
            : RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(productsProvider);
                  await ref.read(productsProvider.future);
                },
                child: _ProductList(products: list),
              ),
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
          padding: const EdgeInsets.all(16),
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
