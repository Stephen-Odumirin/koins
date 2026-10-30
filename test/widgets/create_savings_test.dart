import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/repositories/savings_repository.dart';
import 'package:savings_app/screens/savings/create_savings_screen.dart';

import '../helpers/memory_plan_db.dart';
import '../helpers/pump_app.dart';

void _tallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Finder _field(String key) => find.descendant(
  of: find.byKey(Key(key)),
  matching: find.byType(EditableText),
);

Future<void> _next(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('create-next')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('an empty name cannot go forward', (tester) async {
    _tallViewport(tester);
    await pumpWithOverrides(tester, const CreateSavingsScreen());

    final next = tester.widget<FilledButton>(
      find.byKey(const Key('create-next')),
    );
    expect(next.onPressed, isNull);
    expect(find.text('Savings Created Successfully'), findsNothing);
  });

  testWidgets('valid flow with comma amounts saves and confirms', (
    tester,
  ) async {
    _tallViewport(tester);
    final planDb = (await tester.runAsync(openMemoryPlanDb))!;
    await pumpWithOverrides(
      tester,
      CreateSavingsScreen(initialProduct: SavingsRepository.products.first),
      planDb: planDb,
    );

    await tester.enterText(find.byType(TextField), 'Holiday');
    await tester.pump();
    await _next(tester);
    await _next(tester);
    await tester.enterText(_field('tally-target'), '1,200,000');
    await tester.enterText(_field('tally-months'), '12');
    await tester.pump();
    await _next(tester);
    await tester.tap(find.byKey(const Key('create-submit')));
    // The insert finishes on real time, outside the test's fake clock
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text('Savings Created Successfully'),
      findsOneWidget,
    ); // Review Focus 2

    final saved = (await tester.runAsync(planDb.loadPlans))!;
    expect(saved.length, 4); // three seeds plus the new plan
    expect(saved.last.name, 'Holiday');
  });

  testWidgets('a zero duration is rejected', (tester) async {
    _tallViewport(tester);
    await pumpWithOverrides(
      tester,
      CreateSavingsScreen(initialProduct: SavingsRepository.products[2]),
    );
    await tester.enterText(find.byType(TextField), 'Holiday');
    await tester.pump();
    await _next(tester);
    await _next(tester);
    await tester.enterText(_field('tally-target'), '120000');
    await tester.enterText(_field('tally-months'), '0');
    await tester.pump();
    final next = tester.widget<FilledButton>(
      find.byKey(const Key('create-next')),
    );
    expect(next.onPressed, isNull);
    expect(find.text('Savings Created Successfully'), findsNothing);
  });
}
