import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/savings_plan.dart';

class PlanDatabase {
  PlanDatabase(this._db);

  final Database _db;

  static const _table = 'plans';

  static Future<PlanDatabase> open({String? path}) async {
    final dbPath = path ?? p.join(await getDatabasesPath(), 'koins_savings.db');
    final db = await openDatabase(
      dbPath,
      version: 2,
      onCreate: onCreate,
      onUpgrade: onUpgrade,
    );
    return PlanDatabase(db);
  }

  static Future<void> onCreate(Database db, int version) async {
    await db.execute('''
CREATE TABLE $_table (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  productType TEXT NOT NULL,
  targetAmount INTEGER NOT NULL,
  monthlyContribution INTEGER NOT NULL,
  durationMonths INTEGER NOT NULL,
  createdAt TEXT NOT NULL,
  savedAmount INTEGER NOT NULL
)''');
    await _insertSeeds(db);
  }

  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $_table ADD COLUMN savedAmount INTEGER NOT NULL DEFAULT 0',
      );
      await _insertSeeds(db);
    }
  }

  static Future<void> _insertSeeds(Database db) async {
    for (final plan in _seedPlans) {
      await db.insert(
        _table,
        plan.toJson(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  // Sample plans shown on a fresh install. Saved total is 850000.
  static final _seedPlans = [
    SavingsPlan(
      id: 'seed-1',
      name: 'Emergency Fund',
      productType: 'Fixed Deposit',
      targetAmount: 120000,
      monthlyContribution: 10000,
      durationMonths: 12,
      createdAt: DateTime(2026, 1, 1),
      savedAmount: 120000,
    ),
    SavingsPlan(
      id: 'seed-2',
      name: 'School Fees 2027',
      productType: 'Education Savings',
      targetAmount: 350000,
      monthlyContribution: 25000,
      durationMonths: 14,
      createdAt: DateTime(2026, 3, 15),
      savedAmount: 280000,
    ),
    SavingsPlan(
      id: 'seed-3',
      name: 'New Laptop',
      productType: 'Target Savings',
      targetAmount: 480000,
      monthlyContribution: 40000,
      durationMonths: 12,
      createdAt: DateTime(2026, 5, 10),
      savedAmount: 450000,
    ),
  ];

  Future<List<SavingsPlan>> loadPlans() async {
    final rows = await _db.query(_table, orderBy: 'rowid ASC');
    return rows.map(SavingsPlan.fromJson).toList();
  }

  Future<void> insertPlan(SavingsPlan plan) async {
    await _db.insert(_table, plan.toJson());
  }

  Future<void> close() => _db.close();
}
