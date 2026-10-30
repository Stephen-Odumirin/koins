import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/providers/notifications_provider.dart';
import 'package:savings_app/providers/providers.dart';
import 'package:savings_app/screens/login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/in_memory_secret_store.dart';

Future<ProviderContainer> _pumpLogin(
  WidgetTester tester, {
  bool hasPin = true,
  Object? routeArgument,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final store = InMemorySecretStore();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      secretStoreProvider.overrideWithValue(store),
    ],
  );
  addTearDown(container.dispose);
  if (hasPin) await container.read(pinStoreProvider).savePin('1234');
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        routes: {
          '/dashboard': (_) => const Scaffold(body: Text('DASHBOARD')),
          '/pin-setup': (_) => const Scaffold(body: Text('PIN SETUP')),
        },
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: RouteSettings(name: '/', arguments: routeArgument),
          builder: (_) => const LoginScreen(),
        ),
        initialRoute: '/login',
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
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

  testWidgets('demo credentials with a PIN open the dashboard', (tester) async {
    await _pumpLogin(tester);

    await tester.enterText(find.byKey(const Key('login-email')), 'test@bank.com');
    await tester.enterText(find.byKey(const Key('login-password')), 'Password123');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('DASHBOARD'), findsOneWidget);
  });

  testWidgets('a successful sign-in delivers the welcome notification', (
    tester,
  ) async {
    final container = await _pumpLogin(tester);
    expect(container.read(notificationsProvider), isEmpty);

    await tester.enterText(find.byKey(const Key('login-email')), 'test@bank.com');
    await tester.enterText(find.byKey(const Key('login-password')), 'Password123');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    final items = container.read(notificationsProvider);
    expect(items, hasLength(1));
    expect(items.single.title, 'Welcome to KoinsMFB');
    expect(items.single.body, 'Your savings are one tap away.');
  });

  testWidgets('a failed sign-in delivers nothing', (tester) async {
    final container = await _pumpLogin(tester);
    await tester.enterText(find.byKey(const Key('login-email')), 'test@bank.com');
    await tester.enterText(find.byKey(const Key('login-password')), 'wrongpass1');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();
    expect(container.read(notificationsProvider), isEmpty);
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

  testWidgets('demo credentials with no PIN open PIN setup', (tester) async {
    await _pumpLogin(tester, hasPin: false);

    await tester.enterText(find.byKey(const Key('login-email')), 'test@bank.com');
    await tester.enterText(find.byKey(const Key('login-password')), 'Password123');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('PIN SETUP'), findsOneWidget);
    expect(find.text('DASHBOARD'), findsNothing);
  });

  testWidgets('a String route argument shows as a snackbar', (tester) async {
    await _pumpLogin(
      tester,
      routeArgument: 'Too many attempts. Please log in again.',
    );

    expect(find.text('Too many attempts. Please log in again.'), findsOneWidget);
  });

  testWidgets('no route argument shows no snackbar', (tester) async {
    await _pumpLogin(tester);

    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('Forgot password and Create account still say Coming soon', (
    tester,
  ) async {
    await _pumpLogin(tester);

    await tester.tap(find.text('Forgot password?'));
    await tester.pump();
    expect(find.text('Coming soon'), findsOneWidget);

    ScaffoldMessenger.of(tester.element(find.byType(Scaffold).first))
        .clearSnackBars();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create account'));
    await tester.pump();
    expect(find.text('Coming soon'), findsOneWidget);
  });
}
