import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:savings_app/services/plan_database.dart';

import 'memory_plan_db.dart';

/// Pumps [child] inside a ProviderScope with SharedPreferences mocked.
Future<void> pumpWithOverrides(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
  PlanDatabase? planDb,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final db = planDb ?? (await tester.runAsync(openMemoryPlanDb))!;
  addTearDown(() => tester.runAsync(db.close));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        planDatabaseProvider.overrideWithValue(db),
        ...overrides,
      ],
      child: MaterialApp(home: child),
    ),
  );
  // Database calls finish on real time, so let them run outside FakeAsync.
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
  }
  await tester.pumpAndSettle();
}
