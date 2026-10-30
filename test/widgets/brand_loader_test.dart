import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/widgets/brand_loader.dart';

void main() {
  testWidgets('builds at 96 px and animates', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: BrandLoader())),
      ),
    );
    await tester.pump(const Duration(milliseconds: 800));
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(BrandLoader)).width, 96);
    expect(tester.binding.transientCallbackCount, greaterThan(0));
  });

  testWidgets('reduced motion draws the static mark with no ticker', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: BrandLoader(reduceMotion: true))),
      ),
    );
    await tester.pump(const Duration(milliseconds: 800));
    expect(tester.takeException(), isNull);
    expect(tester.binding.transientCallbackCount, 0);
    expect(find.byType(CustomPaint), findsWidgets);
  });
}
