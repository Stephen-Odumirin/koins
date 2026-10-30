import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/providers/providers.dart';
import 'package:savings_app/screens/auth/biometric_offer_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_biometric_authenticator.dart';
import '../helpers/in_memory_secret_store.dart';

void main() {
  late ProviderContainer container;
  late FakeBiometricAuthenticator fake;

  Future<void> pumpOffer(
    WidgetTester tester, {
    required bool authResult,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    fake = FakeBiometricAuthenticator(result: authResult);
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        secretStoreProvider.overrideWithValue(InMemorySecretStore()),
        biometricGateProvider.overrideWithValue(fake),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          routes: {
            '/dashboard': (_) => const Scaffold(body: Text('DASHBOARD')),
          },
          home: const BiometricOfferScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('enable success sets the flag and opens the dashboard', (
    tester,
  ) async {
    await pumpOffer(tester, authResult: true);
    await tester.tap(find.byKey(const Key('biometric-enable')));
    await tester.pumpAndSettle();
    expect(fake.authenticateCalls, 1);
    expect(await container.read(pinStoreProvider).biometricsEnabled(), isTrue);
    expect(find.text('DASHBOARD'), findsOneWidget);
  });

  testWidgets('enable failure stays, shows the message, flag stays false', (
    tester,
  ) async {
    await pumpOffer(tester, authResult: false);
    await tester.tap(find.byKey(const Key('biometric-enable')));
    await tester.pumpAndSettle();
    expect(fake.authenticateCalls, 1);
    expect(
      find.text(
        "Biometrics weren't set up. You can still unlock with your PIN.",
      ),
      findsOneWidget,
    );
    expect(find.text('DASHBOARD'), findsNothing);
    expect(find.byType(BiometricOfferScreen), findsOneWidget);
    expect(await container.read(pinStoreProvider).biometricsEnabled(), isFalse);
  });

  testWidgets('Not now sets nothing and opens the dashboard', (tester) async {
    await pumpOffer(tester, authResult: true);
    await tester.tap(find.byKey(const Key('biometric-later')));
    await tester.pumpAndSettle();
    expect(fake.authenticateCalls, 0);
    expect(await container.read(pinStoreProvider).biometricsEnabled(), isFalse);
    expect(find.text('DASHBOARD'), findsOneWidget);
  });
}
