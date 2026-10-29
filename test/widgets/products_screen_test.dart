import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/screens/products/products_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('products screen lists four products with View Details', (tester) async {
    // ListView builds lazily, so make the viewport tall enough for all four cards
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpWithOverrides(tester, const ProductsScreen());

    expect(find.text('View Details'), findsNWidgets(4));
    expect(find.text('Target Savings'), findsOneWidget);
    expect(find.text('Vacation Savings'), findsOneWidget);
  });
}
