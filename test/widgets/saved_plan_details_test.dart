import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/models/savings_plan.dart';
import 'package:savings_app/screens/savings/saved_plan_details_screen.dart';
import 'package:savings_app/widgets/progress_ring.dart';

import '../helpers/pump_app.dart';

final _school = SavingsPlan(
  id: 'seed-2',
  name: 'School Fees 2027',
  productType: 'Education Savings',
  targetAmount: 350000,
  monthlyContribution: 25000,
  durationMonths: 14,
  createdAt: DateTime(2026, 3, 15),
  savedAmount: 280000,
);

void main() {
  testWidgets('shows the plan facts and a saved-over-target ring', (
    tester,
  ) async {
    await pumpWithOverrides(tester, SavedPlanDetailsScreen(plan: _school));

    expect(find.text('School Fees 2027'), findsWidgets);
    expect(find.text('Education Savings'), findsOneWidget);
    expect(find.text('₦350,000'), findsOneWidget);
    expect(find.text('₦280,000'), findsOneWidget);
    expect(find.text('₦25,000'), findsOneWidget);
    expect(find.text('14 months'), findsOneWidget);
    expect(find.text('80%'), findsOneWidget);

    final ring = tester.widget<ProgressRing>(find.byType(ProgressRing));
    expect(ring.progress, closeTo(280000 / 350000, 1e-9));
  });

  testWidgets('a zero target does not divide by zero', (tester) async {
    final empty = SavingsPlan(
      id: 'x',
      name: 'Empty',
      productType: 'Target Savings',
      targetAmount: 0,
      monthlyContribution: 0,
      durationMonths: 1,
      createdAt: DateTime(2026, 1, 1),
    );
    await pumpWithOverrides(tester, SavedPlanDetailsScreen(plan: empty));
    final ring = tester.widget<ProgressRing>(find.byType(ProgressRing));
    expect(ring.progress, 0);
  });
}
