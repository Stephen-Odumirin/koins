import '../models/savings_plan.dart';

/// Share of the target already saved, between 0 and 1.
///
/// The one rule behind every progress ring, so a plan shows the same
/// percentage on its tile and on its details screen.
double planProgress(SavingsPlan plan) {
  if (plan.targetAmount <= 0) return 0.0;
  return (plan.savedAmount / plan.targetAmount).clamp(0.0, 1.0).toDouble();
}
