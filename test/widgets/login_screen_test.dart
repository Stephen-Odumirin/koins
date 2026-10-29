import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/providers/providers.dart';
import 'package:savings_app/screens/login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpLogin(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: MaterialApp(
        routes: {'/dashboard': (_) => const Scaffold(body: Text('DASHBOARD'))},
        home: const LoginScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('empty submit shows required errors', (tester) async {
    await _pumpLogin(tester);

    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('invalid email format shows inline error', (tester) async {
    await _pumpLogin(tester);

    await tester.enterText(find.byKey(const Key('login-email')), 'not-an-email');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsOneWidget);
  });

  testWidgets('demo credentials log in and open the dashboard', (tester) async {
    await _pumpLogin(tester);

    await tester.enterText(find.byKey(const Key('login-email')), 'test@bank.com');
    await tester.enterText(find.byKey(const Key('login-password')), 'Password123');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('DASHBOARD'), findsOneWidget);
  });

  testWidgets('submit is disabled while signing in (double tap guard)', (tester) async {
    await _pumpLogin(tester);

    await tester.enterText(find.byKey(const Key('login-email')), 'test@bank.com');
    await tester.enterText(find.byKey(const Key('login-password')), 'Password123');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump(); // loading state starts

    final button = tester.widget<FilledButton>(find.byKey(const Key('login-submit')));
    expect(button.onPressed, isNull); // Review Focus 3

    await tester.pumpAndSettle();
  });

  testWidgets('wrong password shows a snackbar message', (tester) async {
    await _pumpLogin(tester);

    await tester.enterText(find.byKey(const Key('login-email')), 'test@bank.com');
    await tester.enterText(find.byKey(const Key('login-password')), 'wrongpass1');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Invalid email or password'), findsOneWidget);
  });
}
