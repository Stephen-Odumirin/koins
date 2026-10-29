import '../models/savings_plan.dart';

/// Share of a plan's duration that has elapsed, between 0 and 1.
///
/// Used for the progress ring on plan tiles. There are no deposit records
/// yet, so progress is measured by time, not by money saved.
double planTimeProgress(SavingsPlan plan, DateTime now) {
  final months = now.difference(plan.createdAt).inDays / 30.44;
  return (months / plan.durationMonths).clamp(0.0, 1.0).toDouble();
}
