import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' show DatabaseException;

import '../models/savings_plan.dart';
import 'plan_database.dart';

const _plansKey = 'savings_plans';

/// One-time move of plans from SharedPreferences into SQLite.
///
/// The preferences key is removed only after every valid plan has been
/// inserted or skipped, so a failure part-way leaves the data in place and the
/// next run can retry. Malformed entries and plans whose id already exists in
/// the database are skipped.
Future<void> migratePlansFromPreferences(
  SharedPreferences prefs,
  PlanDatabase db,
) async {
  final String? raw;
  try {
    raw = prefs.getString(_plansKey);
  } on TypeError {
    // A non-string value is stored under the key; leave it untouched.
    return;
  }
  if (raw == null) return;

  final List<dynamic> entries;
  try {
    entries = jsonDecode(raw) as List<dynamic>;
  } on FormatException {
    return; // Not valid JSON: nothing we can migrate, leave it in place.
  } on TypeError {
    return; // Valid JSON but not a list.
  }

  for (final entry in entries) {
    final SavingsPlan plan;
    try {
      plan = SavingsPlan.fromJson(entry as Map<String, dynamic>);
    } on TypeError {
      continue;
    } on FormatException {
      continue;
    }
    try {
      await db.insertPlan(plan);
    } on DatabaseException catch (e) {
      // Only a duplicate id (from an earlier run) is skipped; anything else
      // (locked, full, read-only, closed) must propagate and keep the key.
      if (!e.isUniqueConstraintError()) rethrow;
      continue;
    }
  }

  await prefs.remove(_plansKey);
}
