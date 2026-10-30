import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/core/navigation.dart';
import 'package:savings_app/providers/app_lock_provider.dart';
import 'package:savings_app/providers/auth_provider.dart';
import 'package:savings_app/providers/providers.dart';
import 'package:savings_app/screens/auth/lock_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_biometric_authenticator.dart';
import 'package:savings_app/services/secret_store.dart';

import '../helpers/in_memory_secret_store.dart';
import '../helpers/throwing_secret_store.dart';

void main() {
  late InMemorySecretStore store;
  late FakeBiometricAuthenticator bio;
  late ProviderContainer container;

  Future<void> pumpLock(WidgetTester tester, {SecretStore? secrets}) async {
    SharedPreferences.setMockInitialValues({'logged_in_email': 'a@b.com'});
    final prefs = await SharedPreferences.getInstance();
    store = InMemorySecretStore();
    final used = secrets ?? store;
    bio = FakeBiometricAuthenticator(canUse: false);
    final container0 = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      secretStoreProvider.overrideWithValue(used),
      biometricGateProvider.overrideWithValue(bio),
    ]);
    container = container0;
    addTearDown(container.dispose);
    if (secrets == null) {
      await container.read(pinStoreProvider).savePin('1234');
    }
    container.read(authProvider.notifier).state = 'a@b.com';
    container.read(appLockProvider.notifier).lock();

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        navigatorKey: appNavigatorKey,
        routes: {
          '/login': (ctx) => Scaffold(
                body: Text(
                    'LOGIN ${ModalRoute.of(ctx)?.settings.arguments ?? ''}'),
              ),
          '/dashboard': (_) => const Scaffold(body: Text('DASHBOARD')),
        },
        home: const Scaffold(body: Text('DASHBOARD')),
      ),
    ));
    appNavigatorKey.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => const LockScreen()),
    );
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, String pin) async {
    await tester.enterText(find.byKey(const Key('lock-pin')), pin);
    await tester.pumpAndSettle();
  }

  testWidgets('a correct PIN unlocks', (tester) async {
    await pumpLock(tester);
    await enter(tester, '1234');
    expect(container.read(appLockProvider), isFalse);
  });

  testWidgets('a wrong PIN shows the attempts left', (tester) async {
    await pumpLock(tester);
    await enter(tester, '0000');
    expect(find.text('Incorrect PIN. 2 attempts left.'), findsOneWidget);
    expect(container.read(appLockProvider), isTrue);
    expect(await container.read(pinStoreProvider).failedAttempts(), 1);
  });

  testWidgets('one attempt left is singular', (tester) async {
    await pumpLock(tester);
    await enter(tester, '0000');
    await enter(tester, '1111');
    expect(find.text('Incorrect PIN. 1 attempt left.'), findsOneWidget);
  });

  testWidgets('a correct PIN resets the failure count', (tester) async {
    await pumpLock(tester);
    await enter(tester, '0000');
    await enter(tester, '1234');
    expect(await container.read(pinStoreProvider).failedAttempts(), 0);
  });

  testWidgets('three wrong PINs sign the user out and go to login',
      (tester) async {
    await pumpLock(tester);
    await enter(tester, '0000');
    await enter(tester, '1111');
    await enter(tester, '2222');
    expect(find.text('LOGIN Too many attempts. Please log in again.'),
        findsOneWidget);
    expect(container.read(authProvider), isNull);
    expect(await container.read(pinStoreProvider).hasPin(), isFalse);
    expect(container.read(appLockProvider), isFalse);
  });

  testWidgets('a PIN check error shows feedback and keeps the lock',
      (tester) async {
    final throwing = ThrowingSecretStore()..failReads = false;
    await pumpLock(tester, secrets: throwing);
    throwing.failReads = true;
    await enter(tester, '1234');
    expect(find.text('Could not check your PIN. Please try again.'),
        findsOneWidget);
    expect(container.read(appLockProvider), isTrue);
    expect(find.byType(LockScreen), findsOneWidget);
  });

  testWidgets('Back exits the app and does not reveal the screen underneath',
      (tester) async {
    // SystemNavigator.pop is a platform-channel call; record it.
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        calls.add(call.method);
        return null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await pumpLock(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(LockScreen), findsOneWidget);
    expect(find.text('DASHBOARD'), findsNothing);
    expect(calls, contains('SystemNavigator.pop'));
  });

  testWidgets('biometric success unlocks and is tried once on open',
      (tester) async {
    await pumpLock(tester);
    bio
      ..canUse = true
      ..result = true;
    await store.write('biometrics_enabled', 'true');
    appNavigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    appNavigatorKey.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => const LockScreen()),
    );
    await tester.pumpAndSettle();
    expect(bio.authenticateCalls, 1);
    expect(find.byKey(const Key('lock-biometric')), findsOneWidget);
    expect(container.read(appLockProvider), isFalse);
  });
}
