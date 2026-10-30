import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/providers/savings_provider.dart';
import 'package:savings_app/providers/savings_totals_provider.dart';
import 'package:savings_app/repositories/savings_repository.dart';
import 'package:savings_app/screens/savings/create_savings_screen.dart';

import '../helpers/memory_plan_db.dart';
import '../helpers/pump_app.dart';

void _tall(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Finder _tf(String key) => find.descendant(
  of: find.byKey(Key(key)),
  matching: find.byType(EditableText),
);

bool _nextEnabled(WidgetTester tester) =>
    tester
        .widget<FilledButton>(find.byKey(const Key('create-next')))
        .onPressed !=
    null;

void main() {
  final flexible = SavingsRepository.products[2]; // min 5000, flexible

  Future<void> toAmounts(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField), 'Holiday');
    await tester.pump();
    await tester.tap(find.byKey(const Key('create-next')));
    await tester.pumpAndSettle(); // product step, pre-filled
    await tester.tap(find.byKey(const Key('create-next')));
    await tester.pumpAndSettle(); // amounts
  }

  testWidgets('next is disabled until the name is valid', (tester) async {
    _tall(tester);
    await pumpWithOverrides(
      tester,
      CreateSavingsScreen(initialProduct: flexible),
    );
    expect(_nextEnabled(tester), isFalse);
    await tester.enterText(find.byType(TextField), 'Holiday');
    await tester.pump();
    expect(_nextEnabled(tester), isTrue);
  });

  testWidgets('amounts show the live sentence and gate next', (tester) async {
    _tall(tester);
    await pumpWithOverrides(
      tester,
      CreateSavingsScreen(initialProduct: flexible),
    );
    await toAmounts(tester);
    expect(_nextEnabled(tester), isFalse);

    await tester.enterText(_tf('tally-target'), '120,000');
    await tester.enterText(_tf('tally-months'), '12');
    await tester.pump();

    expect(
      find.text("I'll save ₦10,000 every month for 12 months."),
      findsOneWidget,
    );
    expect(_nextEnabled(tester), isTrue);
  });

  testWidgets('an indivisible target shows the error and blocks next', (
    tester,
  ) async {
    _tall(tester);
    await pumpWithOverrides(
      tester,
      CreateSavingsScreen(initialProduct: flexible),
    );
    await toAmounts(tester);
    await tester.enterText(_tf('tally-target'), '100000');
    await tester.enterText(_tf('tally-months'), '12');
    await tester.pump();
    expect(
      find.text('Target must be a multiple of the months.'),
      findsOneWidget,
    );
    expect(_nextEnabled(tester), isFalse);
  });

  testWidgets('the amounts step has no Adjust control', (tester) async {
    _tall(tester);
    await pumpWithOverrides(
      tester,
      CreateSavingsScreen(initialProduct: flexible),
    );
    await toAmounts(tester);
    expect(find.textContaining('Adjust'), findsNothing);
    expect(find.byKey(const Key('tally-adjust')), findsNothing);
    for (final k in ['tally-target', 'tally-monthly', 'tally-months']) {
      expect(tester.widget<EditableText>(_tf(k)).readOnly, isFalse);
    }
  });

  testWidgets('monthly is typeable after target and months, and recomputes '
      'the target', (tester) async {
    _tall(tester);
    await pumpWithOverrides(
      tester,
      CreateSavingsScreen(initialProduct: flexible),
    );
    await toAmounts(tester);
    await tester.enterText(_tf('tally-target'), '120000');
    await tester.enterText(_tf('tally-months'), '12');
    await tester.pump();
    await tester.pump();
    expect(
      tester.widget<EditableText>(_tf('tally-monthly')).controller.text,
      '₦10,000',
    );

    await tester.enterText(_tf('tally-monthly'), '20000');
    await tester.pump();
    await tester.pump();
    expect(
      tester.widget<EditableText>(_tf('tally-monthly')).controller.text,
      '₦20,000',
    );
    expect(
      tester.widget<EditableText>(_tf('tally-target')).controller.text,
      '₦240,000',
    );
    expect(_nextEnabled(tester), isTrue);
  });

  testWidgets('target then monthly computes the months', (tester) async {
    _tall(tester);
    await pumpWithOverrides(
      tester,
      CreateSavingsScreen(initialProduct: flexible),
    );
    await toAmounts(tester);
    await tester.enterText(_tf('tally-target'), '120000');
    await tester.enterText(_tf('tally-monthly'), '10000');
    await tester.pump();
    await tester.pump();
    expect(
      tester.widget<EditableText>(_tf('tally-months')).controller.text,
      '12',
    );
    expect(_nextEnabled(tester), isTrue);
  });

  testWidgets('amount fields format as naira while typing', (tester) async {
    _tall(tester);
    await pumpWithOverrides(
      tester,
      CreateSavingsScreen(initialProduct: flexible),
    );
    await toAmounts(tester);
    await tester.enterText(_tf('tally-target'), '120000');
    await tester.pump();
    expect(
      tester.widget<EditableText>(_tf('tally-target')).controller.text,
      '₦120,000',
    );
    await tester.enterText(_tf('tally-opening'), '5000');
    await tester.pump();
    expect(
      tester.widget<EditableText>(_tf('tally-opening')).controller.text,
      '₦5,000',
    );
  });

  testWidgets('monthly below the product minimum blocks next', (tester) async {
    _tall(tester);
    await pumpWithOverrides(
      tester,
      CreateSavingsScreen(initialProduct: flexible),
    );
    await toAmounts(tester);
    await tester.enterText(_tf('tally-target'), '12000'); // 1,000 a month
    await tester.enterText(_tf('tally-months'), '12');
    await tester.pump();
    expect(_nextEnabled(tester), isFalse);
  });

  testWidgets('a fixed-term product prefills editable months', (tester) async {
    _tall(tester);
    await pumpWithOverrides(
      tester,
      CreateSavingsScreen(initialProduct: SavingsRepository.products[0]),
    );
    await toAmounts(tester);
    expect(tester.widget<EditableText>(_tf('tally-months')).readOnly, isFalse);
    await tester.enterText(_tf('tally-target'), '120000');
    await tester.pump();
    expect(
      find.text("I'll save ₦10,000 every month for 12 months."),
      findsOneWidget,
    );
    await tester.enterText(_tf('tally-months'), '6');
    await tester.pump();
    expect(
      find.text("I'll save ₦20,000 every month for 6 months."),
      findsOneWidget,
    );
  });

  testWidgets('opening deposit above the target blocks next', (tester) async {
    _tall(tester);
    await pumpWithOverrides(
      tester,
      CreateSavingsScreen(initialProduct: flexible),
    );
    await toAmounts(tester);
    await tester.enterText(_tf('tally-target'), '120000');
    await tester.enterText(_tf('tally-months'), '12');
    await tester.enterText(_tf('tally-opening'), '200000');
    await tester.pump();
    expect(_nextEnabled(tester), isFalse);
  });

  testWidgets('creating a plan adds its opening deposit to the total', (
    tester,
  ) async {
    _tall(tester);
    final planDb = (await tester.runAsync(openMemoryPlanDb))!;
    await pumpWithOverrides(
      tester,
      CreateSavingsScreen(initialProduct: flexible),
      planDb: planDb,
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    await tester.runAsync(() => container.read(savingsPlansProvider.future));
    final before = container.read(totalSavingsProvider);
    expect(before, 850000); // the three seeded plans

    await toAmounts(tester);
    await tester.enterText(_tf('tally-target'), '120000');
    await tester.enterText(_tf('tally-months'), '12');
    await tester.enterText(_tf('tally-opening'), '15000');
    await tester.pump();
    await tester.tap(find.byKey(const Key('create-next')));
    await tester.pumpAndSettle(); // review

    expect(find.text('Holiday'), findsWidgets);
    await tester.tap(find.byKey(const Key('create-submit')));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Savings Created Successfully'), findsOneWidget);
    expect(find.text('Holiday'), findsOneWidget);
    expect(find.text('₦120,000'), findsOneWidget);
    expect(find.text('₦10,000'), findsOneWidget);
    expect(find.text('Back to home'), findsOneWidget);
    expect(find.byKey(const Key('create-done')), findsOneWidget);
    final saved = (await tester.runAsync(planDb.loadPlans))!;
    expect(saved.length, 4);
    expect(saved.last.name, 'Holiday');
    expect(saved.last.savedAmount, 15000);
    expect(saved.last.monthlyContribution, 10000);
    expect(container.read(totalSavingsProvider), before + 15000);
  });
}
