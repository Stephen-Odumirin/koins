import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/providers/providers.dart';
import 'package:savings_app/screens/auth/pin_setup_screen.dart';
import 'package:savings_app/widgets/pin/pin_dots.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_biometric_authenticator.dart';
import '../helpers/in_memory_secret_store.dart';
import 'package:savings_app/l10n/app_localizations.dart';

// Pump in short steps; the screens finish async work off the test clock.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }
}

void main() {
  late ProviderContainer container;

  Future<void> pumpSetup(
    WidgetTester tester, {
    required bool canUse,
    bool pushed = false,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        secretStoreProvider.overrideWithValue(InMemorySecretStore()),
        biometricGateProvider.overrideWithValue(
          FakeBiometricAuthenticator(canUse: canUse),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
          routes: {
            '/biometric-offer': (_) => const Scaffold(body: Text('OFFER')),
            '/dashboard': (_) => const Scaffold(body: Text('DASHBOARD')),
            if (pushed) '/': (_) => const Scaffold(body: Text('ROOT')),
            if (pushed) '/pin-setup': (_) => const PinSetupScreen(),
          },
          home: pushed ? null : const PinSetupScreen(),
        ),
      ),
    );
    await settle(tester);
  }

  Future<void> enter(WidgetTester tester, String pin) async {
    for (final d in pin.split('')) {
      await tester.tap(find.byKey(Key('pin-key-$d')));
      await tester.pump(const Duration(milliseconds: 120));
    }
    await settle(tester);
  }

  testWidgets('starts on the create step', (tester) async {
    await pumpSetup(tester, canUse: true);
    expect(find.text('Create a 4-digit PIN'), findsOneWidget);
    expect(find.text('Confirm your PIN'), findsNothing);
  });

  testWidgets('a mismatch shows the error and returns to step one', (
    tester,
  ) async {
    await pumpSetup(tester, canUse: true);
    await enter(tester, '1234');
    expect(find.text('Confirm your PIN'), findsOneWidget);
    await enter(tester, '4321');
    expect(find.text("PINs don't match. Try again."), findsOneWidget);
    expect(find.text('Create a 4-digit PIN'), findsOneWidget);
    expect(await container.read(pinStoreProvider).hasPin(), isFalse);
    expect(tester.widget<PinDots>(find.byType(PinDots)).filled, 0);
  });

  testWidgets('a matching PIN is saved and offers biometrics', (tester) async {
    await pumpSetup(tester, canUse: true);
    await enter(tester, '1234');
    await enter(tester, '1234');
    expect(await container.read(pinStoreProvider).hasPin(), isTrue);
    expect(find.text('OFFER'), findsOneWidget);
  });

  testWidgets('a matching PIN goes to the dashboard without biometrics', (
    tester,
  ) async {
    await pumpSetup(tester, canUse: false);
    await enter(tester, '1234');
    await enter(tester, '1234');
    expect(await container.read(pinStoreProvider).hasPin(), isTrue);
    expect(find.text('DASHBOARD'), findsOneWidget);
  });

  Future<void> pumpPushed(WidgetTester tester) async {
    // A real route stack: '/' sits beneath the pushed PIN screen.
    await pumpSetup(tester, canUse: true, pushed: true);
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.pushNamed('/pin-setup');
    await settle(tester);
    expect(find.text('Create a 4-digit PIN'), findsOneWidget);
  }

  testWidgets('Back is blocked on the first step', (tester) async {
    await pumpPushed(tester);
    await tester.binding.handlePopRoute();
    await settle(tester);
    expect(find.text('Create a 4-digit PIN'), findsOneWidget);
    expect(find.text('ROOT'), findsNothing);
    expect(find.byType(BackButton), findsNothing);
  });

  testWidgets('Back is blocked on the confirm step', (tester) async {
    await pumpPushed(tester);
    await enter(tester, '1234');
    expect(find.text('Confirm your PIN'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await settle(tester);
    expect(find.text('Confirm your PIN'), findsOneWidget);
    expect(find.text('ROOT'), findsNothing);
  });
}
