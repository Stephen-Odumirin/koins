import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/savings_plan.dart';
import 'savings_provider.dart';

/// Sum of savedAmount across the loaded plans; 0 while loading.
final totalSavingsProvider = Provider<int>((ref) {
  final plans = ref.watch(savingsPlansProvider).value ?? const <SavingsPlan>[];
  return plans.fold<int>(0, (sum, plan) => sum + plan.savedAmount);
});

/// Plans newest first by createdAt.
final recentPlansProvider = Provider<List<SavingsPlan>>((ref) {
  final plans = ref.watch(savingsPlansProvider).value ?? const <SavingsPlan>[];
  final sorted = [...plans]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return sorted;
});
