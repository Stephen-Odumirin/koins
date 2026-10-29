import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/repositories/savings_repository.dart';
import 'package:savings_app/screens/savings/create_savings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/pump_app.dart';

void _tallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('empty submit shows required errors', (tester) async {
    _tallViewport(tester);
    await pumpWithOverrides(tester, const CreateSavingsScreen());

    await tester.tap(find.text('Create'));
    await tester.pump();

    expect(find.text('Savings name is required'), findsOneWidget);
    expect(find.text('Target amount is required'), findsOneWidget);
  });

  testWidgets('valid form with comma amounts saves and confirms', (tester) async {
    _tallViewport(tester);
    await pumpWithOverrides(
      tester,
      CreateSavingsScreen(initialProduct: SavingsRepository.products.first),
    );

    await tester.enterText(find.widgetWithText(TextFormField, 'Savings name'), 'Holiday');
    await tester.enterText(find.widgetWithText(TextFormField, 'Target amount'), '1,000,000');
    await tester.enterText(find.widgetWithText(TextFormField, 'Monthly contribution'), '50,000');
    await tester.enterText(find.widgetWithText(TextFormField, 'Duration (months)'), '12');
    await tester.tap(find.text('Create'));
    await tester.pump(); // snackbar appears
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Savings Created Successfully'), findsOneWidget); // Review Focus 2

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('savings_plans'), contains('Holiday'));
  });
}
