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
      options: OpenDatabaseOptions(version: 1, onCreate: PlanDatabase.onCreate),
    );
    planDb = PlanDatabase(db);
  });

  tearDown(() => planDb.close());

  test('new database returns empty list', () async {
    expect(await planDb.loadPlans(), isEmpty);
  });

  test('loads plans in insertion order with all fields', () async {
    final a = _plan('z-id', 'First', DateTime.utc(2026, 1, 2, 3, 4, 5));
    final b = _plan('a-id', 'Second', DateTime.utc(2025, 5, 6));
    await planDb.insertPlan(a);
    await planDb.insertPlan(b);
    final plans = await planDb.loadPlans();
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
