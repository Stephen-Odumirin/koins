import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/models/savings_plan.dart';
import 'package:savings_app/services/plan_database.dart';
import 'package:savings_app/services/plan_migration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const _key = 'savings_plans';

Map<String, dynamic> _json(String id) => SavingsPlan(
      id: id,
      name: 'Plan $id',
      productType: 'fixed',
      targetAmount: 100000,
      monthlyContribution: 5000,
      durationMonths: 12,
      createdAt: DateTime.utc(2026, 1, 2),
    ).toJson();

class _ThrowingDb extends PlanDatabase {
  _ThrowingDb(super.db);

  @override
  Future<void> insertPlan(SavingsPlan plan) => throw StateError('boom');
}

class _LockedException extends DatabaseException {
  _LockedException() : super('database is locked');

  @override
  int? getResultCode() => null;

  @override
  Object? get result => null;
}

class _DbErrorDb extends PlanDatabase {
  _DbErrorDb(super.db);

  @override
  Future<void> insertPlan(SavingsPlan plan) =>
      throw _LockedException();
}

void main() {
  late PlanDatabase planDb;
  late Database rawDb;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    rawDb = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(version: 1, onCreate: PlanDatabase.onCreate),
    );
    planDb = PlanDatabase(rawDb);
  });

  tearDown(() => planDb.close());

  Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  test('migrates valid plans and removes the key', () async {
    final prefs = await prefsWith({
      _key: jsonEncode([_json('a'), _json('b')]),
    });
    await migratePlansFromPreferences(prefs, planDb);
    final plans = await planDb.loadPlans();
    expect(plans.map((p) => p.id), ['a', 'b']);
    expect(prefs.containsKey(_key), isFalse);
  });

  test('running twice does not duplicate', () async {
    final raw = jsonEncode([_json('a'), _json('b')]);
    final prefs = await prefsWith({_key: raw});
    await migratePlansFromPreferences(prefs, planDb);
    await prefs.setString(_key, raw);
    await migratePlansFromPreferences(prefs, planDb);
    expect(await planDb.loadPlans(), hasLength(2));
    expect(prefs.containsKey(_key), isFalse);
  });

  test('skips malformed entries and migrates the rest', () async {
    final prefs = await prefsWith({
      _key: jsonEncode([
        _json('a'),
        {'id': 1},
        'not a map',
        {..._json('c'), 'createdAt': 'not-a-date'},
      ]),
    });
    await migratePlansFromPreferences(prefs, planDb);
    expect((await planDb.loadPlans()).map((p) => p.id), ['a']);
    expect(prefs.containsKey(_key), isFalse);
  });

  test('absent key does nothing', () async {
    final prefs = await prefsWith({});
    await migratePlansFromPreferences(prefs, planDb);
    expect(await planDb.loadPlans(), isEmpty);
  });

  test('non-string value is left in place without crashing', () async {
    final prefs = await prefsWith({_key: 42});
    await migratePlansFromPreferences(prefs, planDb);
    expect(await planDb.loadPlans(), isEmpty);
    expect(prefs.containsKey(_key), isTrue);
  });

  test('non-database insert failure propagates and keeps the key', () async {
    final prefs = await prefsWith({
      _key: jsonEncode([_json('a')]),
    });
    await expectLater(
      migratePlansFromPreferences(prefs, _ThrowingDb(rawDb)),
      throwsA(isA<StateError>()),
    );
    expect(prefs.containsKey(_key), isTrue);
  });

  test('non-duplicate database error propagates and keeps the key', () async {
    final prefs = await prefsWith({
      _key: jsonEncode([_json('a')]),
    });
    await expectLater(
      migratePlansFromPreferences(prefs, _DbErrorDb(rawDb)),
      throwsA(isA<DatabaseException>()),
    );
    expect(prefs.containsKey(_key), isTrue);
  });

  test('invalid JSON keeps the key', () async {
    final prefs = await prefsWith({_key: 'not json'});
    await migratePlansFromPreferences(prefs, planDb);
    expect(await planDb.loadPlans(), isEmpty);
    expect(prefs.containsKey(_key), isTrue);
  });

  test('non-list JSON keeps the key', () async {
    final prefs = await prefsWith({_key: '{"a":1}'});
    await migratePlansFromPreferences(prefs, planDb);
    expect(await planDb.loadPlans(), isEmpty);
    expect(prefs.containsKey(_key), isTrue);
  });

  test('empty list removes the key', () async {
    final prefs = await prefsWith({_key: '[]'});
    await migratePlansFromPreferences(prefs, planDb);
    expect(await planDb.loadPlans(), isEmpty);
    expect(prefs.containsKey(_key), isFalse);
  });
}
