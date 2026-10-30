import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/widgets/error_view.dart';
import 'package:savings_app/l10n/app_localizations.dart';

void main() {
  testWidgets('ErrorView shows message and retry calls back', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ErrorView(
            message: 'No internet connection',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.text('No internet connection'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(retried, isTrue);
  });
}
