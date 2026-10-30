import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/core/navigation.dart';
import 'package:savings_app/providers/app_lock_provider.dart';
import 'package:savings_app/providers/auth_provider.dart';
import 'package:savings_app/providers/providers.dart';
import 'package:savings_app/screens/auth/lock_screen.dart';
import 'package:savings_app/widgets/lock_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_biometric_authenticator.dart';
import 'package:savings_app/services/secret_store.dart';

import '../helpers/in_memory_secret_store.dart';
import '../helpers/throwing_secret_store.dart';
import 'package:savings_app/l10n/app_localizations.dart';

void main() {
  Future<ProviderContainer> pumpGate(
    WidgetTester tester, {
    required bool signedIn,
    required bool hasPin,
    bool biometrics = false,
    SecretStore? secrets,
  }) async {
    SharedPreferences.setMockInitialValues(
      signedIn ? {'logged_in_email': 'a@b.com'} : {},
    );
    final prefs = await SharedPreferences.getInstance();
    final store = secrets ?? InMemorySecretStore();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        secretStoreProvider.overrideWithValue(store),
        biometricGateProvider.overrideWithValue(
          FakeBiometricAuthenticator(canUse: true),
        ),
      ],
    );
    addTearDown(container.dispose);
    final pins = container.read(pinStoreProvider);
    if (secrets == null) {
      if (hasPin) await pins.savePin('1234');
      await pins.setBiometricsEnabled(biometrics);
    }
    container.read(authProvider); // build with the stored email

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
          navigatorKey: appNavigatorKey,
          builder: (context, child) => LockGate(child: child!),
          routes: {
            '/dashboard': (_) => const Scaffold(body: Text('DASHBOARD')),
          },
          home: const Scaffold(body: Text('APP')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  /// Backgrounds and resumes the app, which locks a signed-in user with a PIN.
  Future<void> background(WidgetTester tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
  }

  // Cold start moved to the splash (see cold_start_lock_test.dart).
  testWidgets('LockGate does not lock on init', (tester) async {
    final c = await pumpGate(tester, signedIn: true, hasPin: true);
    expect(c.read(appLockProvider), isFalse);
    expect(find.byType(LockScreen), findsNothing);
  });

  testWidgets('signed-out user is not locked', (tester) async {
    final c = await pumpGate(tester, signedIn: false, hasPin: true);
    expect(c.read(appLockProvider), isFalse);
    expect(find.byType(LockScreen), findsNothing);
  });

  testWidgets('signed-in user without a PIN is not locked', (tester) async {
    final c = await pumpGate(tester, signedIn: true, hasPin: false);
    expect(c.read(appLockProvider), isFalse);
  });

  testWidgets('pausing the app locks a signed-in user with a PIN', (
    tester,
  ) async {
    final c = await pumpGate(tester, signedIn: true, hasPin: true);
    c.read(appLockProvider.notifier).unlock();
    await tester.pumpAndSettle();
    expect(find.byType(LockScreen), findsNothing);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await tester.pumpAndSettle();
    expect(c.read(appLockProvider), isTrue);
    // Frames are off while the app is hidden; resume to render the overlay.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.byType(LockScreen), findsOneWidget);
  });

  testWidgets('a failing PIN check on resume still locks', (tester) async {
    final store = ThrowingSecretStore()..failReads = false;
    final c = await pumpGate(
      tester,
      signedIn: true,
      hasPin: true,
      secrets: store,
    );
    store.failReads = true;
    await background(tester);
    expect(c.read(appLockProvider), isTrue);
    expect(find.byType(LockScreen), findsOneWidget);
  });

  testWidgets('biometric button is absent when biometrics are disabled', (
    tester,
  ) async {
    await pumpGate(tester, signedIn: true, hasPin: true, biometrics: false);
    expect(find.byKey(const Key('lock-biometric')), findsNothing);
  });

  testWidgets('biometric button shows when enabled and available', (
    tester,
  ) async {
    await pumpGate(tester, signedIn: true, hasPin: true, biometrics: true);
    await background(tester);
    expect(find.byKey(const Key('lock-biometric')), findsOneWidget);
  });

  testWidgets('Back on the lock does not reach the screen underneath', (
    tester,
  ) async {
    final c = await pumpGate(tester, signedIn: true, hasPin: true);
    c.read(appLockProvider.notifier).unlock();
    await tester.pumpAndSettle();
    appNavigatorKey.currentState!.pushNamed('/dashboard');
    await tester.pumpAndSettle();
    // Lock again over the dashboard (app resumed from the background).
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.byType(LockScreen), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(LockScreen), findsOneWidget);
    expect(find.text('DASHBOARD'), findsNothing);
    // The dashboard route is still there, just under the lock.
    expect(find.text('DASHBOARD', skipOffstage: false), findsOneWidget);
  });

  testWidgets('unlocking removes the lock route and shows the app', (
    tester,
  ) async {
    final c = await pumpGate(tester, signedIn: true, hasPin: true);
    await background(tester);
    for (final d in '1234'.split('')) {
      await tester.tap(find.byKey(Key('pin-key-$d')));
      await tester.pump(const Duration(milliseconds: 120));
    }
    await tester.pumpAndSettle();
    expect(c.read(appLockProvider), isFalse);
    expect(find.byType(LockScreen), findsNothing);
    expect(find.text('APP'), findsOneWidget);
  });

  testWidgets('the lock route is not pushed twice', (tester) async {
    final c = await pumpGate(tester, signedIn: true, hasPin: true);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.byType(LockScreen, skipOffstage: false), findsOneWidget);
    for (final d in '1234'.split('')) {
      await tester.tap(find.byKey(Key('pin-key-$d')));
      await tester.pump(const Duration(milliseconds: 120));
    }
    await tester.pumpAndSettle();
    expect(c.read(appLockProvider), isFalse);
    expect(find.byType(LockScreen, skipOffstage: false), findsNothing);
  });
}
