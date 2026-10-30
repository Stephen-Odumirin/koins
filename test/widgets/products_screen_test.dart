import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/core/theme/app_theme.dart';
import 'package:savings_app/screens/products/products_screen.dart';

import '../helpers/pump_app.dart';

/// The real app theme, as the owner's device runs it. The default Material
/// theme hid the empty-list bug because it gives buttons no infinite width.
Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await pumpWithOverrides(
    tester,
    Theme(data: AppTheme.light(), child: const ProductsScreen()),
  );
}

void main() {
  testWidgets('lists the four products, laid out, with the app theme',
      (tester) async {
    await _pump(tester);

    // A layout failure leaves the cards in the tree but never painted.
    expect(tester.takeException(), isNull);
    expect(find.text('View details'), findsNWidgets(4));
    for (final name in [
      'Target Savings',
      'Fixed Deposit',
      'Education Savings',
      'Vacation Savings',
    ]) {
      expect(find.text(name), findsOneWidget);
      expect(tester.getSize(find.text(name)).height, greaterThan(0));
    }
    expect(find.text('12% p.a.'), findsOneWidget);
    expect(find.text('Flexible'), findsNWidgets(2));
    expect(find.text('6 Months'), findsOneWidget);
  });

  testWidgets('typing "fixed" shows only Fixed Deposit', (tester) async {
    await _pump(tester);

    await tester.enterText(find.byKey(const Key('product-search')), 'fixed');
    await tester.pumpAndSettle();

    expect(find.text('Fixed Deposit'), findsOneWidget);
    expect(find.text('Target Savings'), findsNothing);
    expect(find.text('View details'), findsOneWidget);
  });

  testWidgets('Flexible only shows Education and Vacation', (tester) async {
    await _pump(tester);

    await tester.tap(find.byKey(const Key('flexible-filter')));
    await tester.pumpAndSettle();

    expect(find.text('Education Savings'), findsOneWidget);
    expect(find.text('Vacation Savings'), findsOneWidget);
    expect(find.text('Target Savings'), findsNothing);
    expect(find.text('Fixed Deposit'), findsNothing);
  });

  testWidgets('a search with no match shows the empty message',
      (tester) async {
    await _pump(tester);

    await tester.enterText(find.byKey(const Key('product-search')), 'zzz');
    await tester.pumpAndSettle();

    expect(find.text('No products match your search.'), findsOneWidget);
  });

  testWidgets('View details opens the details page', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('View details').first);
    await tester.pumpAndSettle();

    expect(find.text('Create savings'), findsOneWidget);
    expect(find.text('₦5,000'), findsOneWidget);
  });
}
