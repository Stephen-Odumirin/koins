import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/widgets/brand_loader.dart';
import 'package:savings_app/widgets/brand_mark.dart';
import 'package:savings_app/providers/providers.dart';
import 'package:savings_app/screens/splash/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:savings_app/services/secret_store.dart';

import '../helpers/in_memory_secret_store.dart';
import '../helpers/throwing_secret_store.dart';

Future<void> _pumpSplash(
  WidgetTester tester,
  Map<String, Object> stored, {
  bool disableAnimations = false,
  SecretStore? secrets,
}) async {
  SharedPreferences.setMockInitialValues(stored);
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        secretStoreProvider.overrideWithValue(secrets ?? InMemorySecretStore()),
      ],
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: disableAnimations),
          child: child!,
        ),
        home: const SplashScreen(),
        routes: {
          '/dashboard': (_) => const Scaffold(body: Text('dashboard-page')),
          '/login': (_) => const Scaffold(body: Text('login-page')),
          '/onboarding': (_) => const Scaffold(body: Text('onboarding-page')),
        },
      ),
    ),
  );
}

void main() {
  testWidgets('logged in goes to dashboard even if onboarding not complete', (
    tester,
  ) async {
    await _pumpSplash(tester, {'logged_in_email': 'a@b.com'});
    expect(find.byKey(const Key('splash-logo')), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('dashboard-page'), findsOneWidget);
  });

  testWidgets('a failing PIN check sends the user to login, not stuck', (
    tester,
  ) async {
    await _pumpSplash(tester, {
      'logged_in_email': 'a@b.com',
    }, secrets: ThrowingSecretStore());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('login-page'), findsOneWidget);
    expect(find.text('dashboard-page'), findsNothing);
  });

  testWidgets('logged out and onboarded goes to login', (tester) async {
    await _pumpSplash(tester, {'onboarding_complete': true});
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('login-page'), findsOneWidget);
  });

  testWidgets('logged out and not onboarded goes to onboarding', (
    tester,
  ) async {
    await _pumpSplash(tester, {});
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('onboarding-page'), findsOneWidget);
  });

  testWidgets('reduced motion shows a static loader and moves on at once', (
    tester,
  ) async {
    await _pumpSplash(tester, {
      'onboarding_complete': true,
    }, disableAnimations: true);
    expect(find.byKey(const Key('splash-logo')), findsOneWidget);
    expect(find.byType(BrandLoader), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    expect(find.text('login-page'), findsOneWidget);
  });

  testWidgets('the splash shows exactly one mark', (tester) async {
    await _pumpSplash(tester, {'onboarding_complete': true});
    expect(find.byType(BrandLoader), findsOneWidget);
    expect(find.byType(BrandMark), findsNothing);
    expect(
      tester.widget(find.byKey(const Key('splash-logo'))),
      isA<BrandLoader>(),
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('navigates when the animation ends, before the 3s cap', (
    tester,
  ) async {
    await _pumpSplash(tester, {'onboarding_complete': true});
    expect(find.byType(BrandLoader), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('login-page'), findsOneWidget);
  });
}
