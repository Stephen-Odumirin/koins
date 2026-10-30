import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/core/theme/app_theme.dart';
import 'package:savings_app/utils/formatters.dart';

void main() {
  test('formatNaira renders ₦850,000', () {
    expect(formatNaira(850000), '₦850,000');
  });

  test('formatNaira renders ₦5,000', () {
    expect(formatNaira(5000), '₦5,000');
  });

  testWidgets('formatted naira text contains the Naira sign and theme has a fallback', (tester) async {
    // Does not prove the glyph renders; that was checked on the emulator.
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: Text(formatNaira(850000)),
    ));
    expect(find.textContaining('₦'), findsOneWidget);
    expect(AppTheme.light().textTheme.bodyMedium?.fontFamilyFallback, contains('Roboto'));
  });
}
