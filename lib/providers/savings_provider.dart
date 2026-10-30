import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/savings_plan.dart';
import '../models/savings_product.dart';
import 'providers.dart';

final productsProvider = FutureProvider<List<SavingsProduct>>((ref) {
  return ref.watch(savingsRepositoryProvider).getProducts();
});

class SavingsPlansNotifier extends AsyncNotifier<List<SavingsPlan>> {
  @override
  Future<List<SavingsPlan>> build() async {
    return ref.watch(savingsRepositoryProvider).getUserPlans();
  }

  Future<void> createPlan(SavingsPlan plan) async {
    await ref.read(savingsRepositoryProvider).createPlan(plan);
    ref.invalidateSelf(); // reload from storage
    await future;
  }
}

final savingsPlansProvider =
    AsyncNotifierProvider<SavingsPlansNotifier, List<SavingsPlan>>(
      SavingsPlansNotifier.new,
    );
