import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/providers/providers.dart';
import 'package:savings_app/screens/onboarding/onboarding_screen.dart';
import 'package:savings_app/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeStorage extends LocalStorageService {
  _FakeStorage(super.prefs, {this.fail = false});

  final bool fail;
  int saveCalls = 0;
  Completer<void>? gate;

  @override
  Future<void> saveOnboardingComplete() async {
    saveCalls++;
    await gate?.future;
    if (fail) throw Exception('disk full');
    return super.saveOnboardingComplete();
  }
}

Future<SharedPreferences> _pump(
  WidgetTester tester, {
  double textScale = 1.0,
  _FakeStorage Function(SharedPreferences)? storage,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        if (storage != null)
          localStorageProvider.overrideWithValue(storage(prefs)),
      ],
      child: MaterialApp(
        initialRoute: '/onboarding',
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        routes: {
          '/onboarding': (_) => const OnboardingScreen(),
          '/login': (_) => const Scaffold(body: Text('login-page')),
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return prefs;
}

Future<void> _next(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('onboarding-next')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('skip saves the flag and replaces the route with login',
      (tester) async {
    final prefs = await _pump(tester);

    await tester.tap(find.byKey(const Key('onboarding-skip')));
    await tester.pumpAndSettle();

    expect(find.text('login-page'), findsOneWidget);
    expect(prefs.getBool('onboarding_complete'), isTrue);
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    expect(nav.canPop(), isFalse);
  });

  testWidgets('Get started on the last slide saves the flag and goes to login',
      (tester) async {
    final prefs = await _pump(tester);

    expect(find.text('Get started'), findsNothing);
    await _next(tester);
    await _next(tester);
    expect(find.text('Get started'), findsOneWidget);
    expect(prefs.getBool('onboarding_complete'), isNull);

    await _next(tester);

    expect(find.text('login-page'), findsOneWidget);
    expect(prefs.getBool('onboarding_complete'), isTrue);
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    expect(nav.canPop(), isFalse);
  });

  testWidgets('double tap on Skip navigates once', (tester) async {
    late _FakeStorage fake;
    await _pump(tester, storage: (p) => fake = _FakeStorage(p));
    // Hold the first save in flight so the second tap arrives mid-save.
    fake.gate = Completer<void>();

    final skip = find.byKey(const Key('onboarding-skip'));
    await tester.tap(skip);
    await tester.tap(skip, warnIfMissed: false);
    fake.gate!.complete();
    await tester.pumpAndSettle();

    expect(find.text('login-page'), findsOneWidget);
    expect(fake.saveCalls, 1);
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    expect(nav.canPop(), isFalse);
  });

  testWidgets('save failure shows a message and stays on onboarding',
      (tester) async {
    late _FakeStorage fake;
    await _pump(tester, storage: (p) => fake = _FakeStorage(p, fail: true));

    await tester.tap(find.byKey(const Key('onboarding-skip')));
    await tester.pumpAndSettle();

    expect(find.text("Couldn't save your progress. Please try again."),
        findsOneWidget);
    expect(find.text('login-page'), findsNothing);
    expect(find.byKey(const Key('onboarding-skip')), findsOneWidget);

    // Not stuck: a second tap tries again.
    await tester.tap(find.byKey(const Key('onboarding-skip')));
    await tester.pumpAndSettle();
    expect(fake.saveCalls, 2);
  });

  testWidgets('there are three slides', (tester) async {
    await _pump(tester);

    for (var i = 0; i < 3; i++) {
      expect(find.byKey(Key('onboarding-dot-$i')), findsOneWidget);
    }
    expect(find.byKey(const Key('onboarding-dot-3')), findsNothing);
    expect(find.byKey(const Key('onboarding-skip')), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('swiping moves between slides and keeps Skip visible',
      (tester) async {
    await _pump(tester);
    final firstTitle = tester.widget<Text>(
        find.byKey(const Key('onboarding-title'))).data;

    await tester.drag(find.byType(PageView), const Offset(-600, 0));
    await tester.pumpAndSettle();

    final secondTitle = tester.widget<Text>(
        find.byKey(const Key('onboarding-title'))).data;
    expect(secondTitle, isNot(firstTitle));
    expect(find.byKey(const Key('onboarding-skip')), findsOneWidget);
  });

  testWidgets('no overflow at text scale 2.0 on any slide', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pump(tester, textScale: 2.0);

    for (var i = 0; i < 3; i++) {
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('onboarding-next')), findsOneWidget);
      if (i < 2) await _next(tester);
    }
    expect(tester.takeException(), isNull);
    expect(find.text('Get started'), findsOneWidget);
  });
}
