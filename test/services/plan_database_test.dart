import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/models/savings_plan.dart';
import 'package:savings_app/services/plan_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

SavingsPlan _plan(String id, String name, DateTime createdAt) => SavingsPlan(
  id: id,
  name: name,
  productType: 'fixed',
  targetAmount: 100000,
  monthlyContribution: 5000,
  durationMonths: 12,
  createdAt: createdAt,
);

void main() {
  late PlanDatabase planDb;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: PlanDatabase.onCreate,
        onUpgrade: PlanDatabase.onUpgrade,
      ),
    );
    planDb = PlanDatabase(db);
  });

  tearDown(() => planDb.close());

  test(
    'new database has the three seed plans totalling 850000 saved',
    () async {
      final plans = await planDb.loadPlans();
      expect(plans.map((p) => p.id), ['seed-1', 'seed-2', 'seed-3']);
      expect(plans.map((p) => p.name), [
        'Emergency Fund',
        'School Fees 2027',
        'New Laptop',
      ]);
      expect(plans.fold<int>(0, (s, p) => s + p.savedAmount), 850000);
      expect(plans[1].createdAt, DateTime(2026, 3, 15));
    },
  );

  test('version 1 database upgrades, keeps user plan, seeds once', () async {
    final dir = await Directory.systemTemp.createTemp('plans_v1');
    addTearDown(() => dir.delete(recursive: true));
    final path = '${dir.path}/v1.db';
    final old = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) => db.execute('''
CREATE TABLE plans (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  productType TEXT NOT NULL,
  targetAmount INTEGER NOT NULL,
  monthlyContribution INTEGER NOT NULL,
  durationMonths INTEGER NOT NULL,
  createdAt TEXT NOT NULL
)'''),
      ),
    );
    await old.insert('plans', {
      'id': 'user-1',
      'name': 'Mine',
      'productType': 'Target Savings',
      'targetAmount': 1000,
      'monthlyContribution': 100,
      'durationMonths': 10,
      'createdAt': DateTime(2026, 6, 1).toIso8601String(),
    });
    await old.close();

    databaseFactory = databaseFactoryFfi;
    final upgraded = await PlanDatabase.open(path: path);
    var plans = await upgraded.loadPlans();
    expect(plans.map((p) => p.id), ['user-1', 'seed-1', 'seed-2', 'seed-3']);
    expect(plans.first.savedAmount, 0);
    expect(plans.fold<int>(0, (s, p) => s + p.savedAmount), 850000);
    await upgraded.close();

    final again = await PlanDatabase.open(path: path);
    plans = await again.loadPlans();
    expect(plans.length, 4);
    await again.close();
  });

  test('SavingsPlan JSON round trip keeps savedAmount', () {
    final plan = SavingsPlan(
      id: 'x',
      name: 'X',
      productType: 'Target Savings',
      targetAmount: 10,
      monthlyContribution: 1,
      durationMonths: 10,
      createdAt: DateTime(2026, 1, 1),
      savedAmount: 7,
    );
    expect(plan.toJson()['savedAmount'], 7);
    expect(SavingsPlan.fromJson(plan.toJson()).savedAmount, 7);
  });

  test('loads plans in insertion order with all fields', () async {
    final a = _plan('z-id', 'First', DateTime.utc(2026, 1, 2, 3, 4, 5));
    final b = _plan('a-id', 'Second', DateTime.utc(2025, 5, 6));
    await planDb.insertPlan(a);
    await planDb.insertPlan(b);
    final plans = (await planDb.loadPlans()).skip(3).toList();
    expect(plans.map((p) => p.id), ['z-id', 'a-id']);
    for (final (i, e) in [a, b].indexed) {
      expect(plans[i].name, e.name);
      expect(plans[i].productType, e.productType);
      expect(plans[i].targetAmount, e.targetAmount);
      expect(plans[i].monthlyContribution, e.monthlyContribution);
      expect(plans[i].durationMonths, e.durationMonths);
      expect(plans[i].createdAt, e.createdAt);
    }
  });

  test('duplicate id throws', () async {
    final a = _plan('dup', 'A', DateTime.utc(2026));
    await planDb.insertPlan(a);
    expect(() => planDb.insertPlan(a), throwsA(isA<DatabaseException>()));
  });
}
