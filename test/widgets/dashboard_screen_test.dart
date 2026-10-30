import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/models/savings_plan.dart';
import 'package:savings_app/providers/savings_provider.dart';
import 'package:savings_app/screens/savings/all_plans_screen.dart';
import 'package:savings_app/widgets/brand_loader.dart';
import 'package:savings_app/widgets/empty_view.dart';
import 'package:savings_app/widgets/error_view.dart';
import 'package:savings_app/screens/dashboard/dashboard_screen.dart';
import 'package:savings_app/widgets/progress_ring.dart';
import 'package:savings_app/widgets/savings_plan_tile.dart';

import '../helpers/pump_app.dart';

void _tall(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

final _holiday = SavingsPlan(
  id: 'p4',
  name: 'Holiday',
  productType: 'Vacation Savings',
  targetAmount: 300000,
  monthlyContribution: 25000,
  durationMonths: 12,
  createdAt: DateTime(2026, 8, 1),
  savedAmount: 20000,
);

Future<ProviderContainer> _addHoliday(WidgetTester tester) async {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  );
  await tester.runAsync(() => container.read(savingsPlansProvider.future));
  await tester.runAsync(
    () => container.read(savingsPlansProvider.notifier).createPlan(_holiday),
  );
  await tester.pump();
  await tester.pumpAndSettle();
  return container;
}

class _FakePlans extends SavingsPlansNotifier {
  _FakePlans(this._build);
  final Future<List<SavingsPlan>> Function() _build;

  @override
  Future<List<SavingsPlan>> build() => _build();
}

Override _plansOverride(Future<List<SavingsPlan>> Function() build) =>
    savingsPlansProvider.overrideWith(() => _FakePlans(build));

void main() {
  _tileRingTests();

  testWidgets('dashboard shows the loader while plans load', (tester) async {
    _tall(tester);
    final never = Completer<List<SavingsPlan>>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [_plansOverride(() => never.future)],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pump();

    expect(find.byType(BrandLoader), findsOneWidget);
  });

  testWidgets('dashboard shows ErrorView and retry reloads plans', (
    tester,
  ) async {
    _tall(tester);
    var builds = 0;
    await tester.pumpWidget(
      ProviderScope(
        // No automatic retries, so only the button can trigger a reload.
        retry: (_, _) => null,
        overrides: [
          _plansOverride(() async {
            builds++;
            throw Exception('boom');
          }),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ErrorView), findsOneWidget);
    expect(builds, 1);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(builds, 2);
  });

  testWidgets('dashboard shows EmptyView and a zero total with no plans', (
    tester,
  ) async {
    _tall(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [_plansOverride(() async => <SavingsPlan>[])],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(EmptyView), findsOneWidget);
    expect(find.text('₦0'), findsOneWidget);
  });

  testWidgets('all plans screen shows EmptyView with no plans', (tester) async {
    _tall(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [_plansOverride(() async => <SavingsPlan>[])],
        child: const MaterialApp(home: AllPlansScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(EmptyView), findsOneWidget);
  });
  testWidgets('fresh install shows greeting, title, total and three plans', (
    tester,
  ) async {
    _tall(tester);
    await pumpWithOverrides(tester, const DashboardScreen());

    expect(find.text('KoinsMFB'), findsOneWidget);
    expect(find.text('Good Morning, John Doe'), findsOneWidget);
    expect(find.text('₦850,000'), findsOneWidget);
    expect(find.text('Emergency Fund'), findsOneWidget);
    expect(find.text('School Fees 2027'), findsOneWidget);
    expect(find.text('New Laptop'), findsOneWidget);
    expect(find.text('Create savings'), findsOneWidget);
    expect(find.text('View products'), findsOneWidget);
    expect(find.text('See all'), findsNothing);
  });

  testWidgets('a created plan raises the total and shows first', (
    tester,
  ) async {
    _tall(tester);
    await pumpWithOverrides(tester, const DashboardScreen());
    await _addHoliday(tester);

    expect(find.text('₦870,000'), findsOneWidget);
    expect(find.text('Holiday'), findsOneWidget);
    // Newest first: Holiday sits above New Laptop; the oldest drops off.
    expect(
      tester.getTopLeft(find.text('Holiday')).dy,
      lessThan(tester.getTopLeft(find.text('New Laptop')).dy),
    );
    expect(find.text('Emergency Fund'), findsNothing);
  });

  testWidgets('See all appears with four plans and opens all four', (
    tester,
  ) async {
    _tall(tester);
    await pumpWithOverrides(tester, const DashboardScreen());
    await _addHoliday(tester);

    expect(find.text('See all'), findsOneWidget);
    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();

    for (final name in [
      'Holiday',
      'New Laptop',
      'School Fees 2027',
      'Emergency Fund',
    ]) {
      expect(find.text(name), findsOneWidget);
    }
  });

  testWidgets('tapping a recent plan opens its details', (tester) async {
    _tall(tester);
    await pumpWithOverrides(tester, const DashboardScreen());

    await tester.tap(find.text('School Fees 2027'));
    await tester.pumpAndSettle();

    expect(find.text('₦280,000'), findsWidgets);
    expect(find.text('Education Savings'), findsWidgets);
  });
}

void _tileRingTests() {
  testWidgets('tile ring for School Fees 2027 shows saved over target (80%)', (
    tester,
  ) async {
    _tall(tester);
    await pumpWithOverrides(tester, const DashboardScreen());

    final tile = find.ancestor(
      of: find.text('School Fees 2027'),
      matching: find.byType(SavingsPlanTile),
    );
    final ring = tester.widget<ProgressRing>(
      find.descendant(of: tile, matching: find.byType(ProgressRing)),
    );
    expect(ring.progress, closeTo(0.8, 1e-9));
    expect(
      find.descendant(of: tile, matching: find.text('80%')),
      findsOneWidget,
    );
  });
}
