import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/core/theme/app_theme.dart';
import 'package:savings_app/repositories/savings_repository.dart';
import 'package:savings_app/screens/products/product_details_screen.dart';
import 'package:savings_app/screens/savings/create_savings_screen.dart';

import '../helpers/pump_app.dart';

Future<void> _pump(WidgetTester tester, int index) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await pumpWithOverrides(
    tester,
    Theme(
      data: AppTheme.light(),
      child: ProductDetailsScreen(product: SavingsRepository.products[index]),
    ),
  );
}

void main() {
  testWidgets('details shows the Target Savings figures', (tester) async {
    await _pump(tester, 0);

    expect(tester.takeException(), isNull);
    expect(find.text('Target Savings'), findsOneWidget);
    expect(find.text('12%'), findsOneWidget);
    expect(find.text('₦5,000'), findsOneWidget);
    expect(find.text('12 Months'), findsOneWidget);
    expect(
      find.text(
        'Save towards a specific goal with fixed monthly contributions.',
      ),
      findsOneWidget,
    );
    expect(find.text('Create savings'), findsOneWidget);
  });

  testWidgets('details shows Flexible for Education Savings', (tester) async {
    await _pump(tester, 2);

    expect(find.text('Education Savings'), findsOneWidget);
    expect(find.text('Flexible'), findsOneWidget);
    expect(find.text('10%'), findsOneWidget);
  });

  testWidgets('Create savings opens the create flow with the product',
      (tester) async {
    await _pump(tester, 1);

    await tester.tap(find.text('Create savings'));
    await tester.pumpAndSettle();

    final screen = tester.widget<CreateSavingsScreen>(
      find.byType(CreateSavingsScreen),
    );
    expect(screen.initialProduct, SavingsRepository.products[1]);
  });
}
