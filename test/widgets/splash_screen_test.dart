import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:savings_app/providers/providers.dart';
import 'package:savings_app/screens/splash/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpSplash(
  WidgetTester tester,
  Map<String, Object> stored, {
  bool disableAnimations = false,
}) async {
  SharedPreferences.setMockInitialValues(stored);
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
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

  testWidgets('reduced motion shows no Lottie and still moves on in 3s', (
    tester,
  ) async {
    await _pumpSplash(tester, {
      'onboarding_complete': true,
    }, disableAnimations: true);
    expect(find.byKey(const Key('splash-logo')), findsOneWidget);
    expect(find.byType(LottieBuilder), findsNothing);
    expect(find.byType(Lottie), findsNothing);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('login-page'), findsOneWidget);
  });

  testWidgets('navigates when the animation ends, before the 3s cap', (
    tester,
  ) async {
    await _pumpSplash(tester, {'onboarding_complete': true});
    // Poll until the Lottie composition has loaded (the splash starts the
    // controller forward on load); fail after 2 seconds.
    var loaded = false;
    await tester.runAsync(() async {
      for (var i = 0; i < 200; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        await tester.pump();
        final lottie = tester.widget<LottieBuilder>(find.byType(LottieBuilder));
        if (lottie.controller?.status == AnimationStatus.forward) {
          loaded = true;
          break;
        }
      }
    });
    expect(loaded, isTrue, reason: 'Lottie composition never loaded');
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('login-page'), findsOneWidget);
  });
}
