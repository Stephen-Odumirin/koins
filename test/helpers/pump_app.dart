import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pumps [child] inside a ProviderScope with SharedPreferences mocked.
Future<void> pumpWithOverrides(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        ...overrides,
      ],
      child: MaterialApp(home: child),
    ),
  );
  await tester.pumpAndSettle();
}
