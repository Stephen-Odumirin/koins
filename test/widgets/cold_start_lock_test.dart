import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/core/navigation.dart';
import 'package:savings_app/providers/app_lock_provider.dart';
import 'package:savings_app/providers/auth_provider.dart';
import 'package:savings_app/providers/providers.dart';
import 'package:savings_app/screens/auth/lock_screen.dart';
import 'package:savings_app/screens/splash/splash_screen.dart';
import 'package:savings_app/widgets/lock_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_biometric_authenticator.dart';
import '../helpers/in_memory_secret_store.dart';

void main() {
  Future<ProviderContainer> pumpApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'logged_in_email': 'a@b.com'});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      secretStoreProvider.overrideWithValue(InMemorySecretStore()),
      biometricGateProvider
          .overrideWithValue(FakeBiometricAuthenticator(canUse: true)),
    ]);
    addTearDown(container.dispose);
    await container.read(pinStoreProvider).savePin('1234');
    container.read(authProvider);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        navigatorKey: appNavigatorKey,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: LockGate(child: child!),
        ),
        home: const SplashScreen(),
        routes: {
          '/dashboard': (_) => const Scaffold(body: Text('DASHBOARD')),
          '/lock': (_) => const LockScreen(),
          '/login': (_) => const Scaffold(body: Text('LOGIN')),
          '/onboarding': (_) => const Scaffold(body: Text('ONBOARDING')),
        },
      ),
    ));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('splash with a PIN shows the lock, not the dashboard',
      (tester) async {
    final c = await pumpApp(tester);
    expect(find.byType(LockScreen), findsOneWidget);
    expect(find.text('DASHBOARD', skipOffstage: false), findsNothing);
    expect(c.read(appLockProvider), isTrue);
  });

  testWidgets('unlock after a cold-start lock reaches the dashboard',
      (tester) async {
    final c = await pumpApp(tester);
    await tester.enterText(find.byKey(const Key('lock-pin')), '1234');
    await tester.pumpAndSettle();
    expect(find.text('DASHBOARD'), findsOneWidget);
    expect(find.byType(LockScreen, skipOffstage: false), findsNothing);
    expect(c.read(appLockProvider), isFalse);
    // Nothing underneath for Back to expose.
    expect(appNavigatorKey.currentState!.canPop(), isFalse);
  });

  testWidgets('unlock removes the lock route even with a route on top',
      (tester) async {
    final c = await pumpApp(tester);
    await tester.enterText(find.byKey(const Key('lock-pin')), '1234');
    await tester.pumpAndSettle();
    // Lock again from the background, then cover the lock with another route.
    c.read(appLockProvider.notifier).lock();
    await tester.pumpAndSettle();
    expect(find.byType(LockScreen), findsOneWidget);
    appNavigatorKey.currentState!.push(MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('ON TOP'))));
    await tester.pumpAndSettle();
    c.read(appLockProvider.notifier).unlock();
    await tester.pumpAndSettle();
    expect(find.byType(LockScreen, skipOffstage: false), findsNothing);
    expect(find.text('ON TOP'), findsOneWidget);
    // Flag cleared: locking again pushes a fresh lock route.
    c.read(appLockProvider.notifier).lock();
    await tester.pumpAndSettle();
    expect(find.byType(LockScreen), findsOneWidget);
  });
}
