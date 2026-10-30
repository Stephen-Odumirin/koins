import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/savings_plan.dart';

class PlanDatabase {
  PlanDatabase(this._db);

  final Database _db;

  static const _table = 'plans';

  static Future<PlanDatabase> open({String? path}) async {
    final dbPath = path ?? p.join(await getDatabasesPath(), 'koins_savings.db');
    final db = await openDatabase(dbPath, version: 1, onCreate: onCreate);
    return PlanDatabase(db);
  }

  static Future<void> onCreate(Database db, int version) {
    return db.execute('''
CREATE TABLE $_table (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  productType TEXT NOT NULL,
  targetAmount INTEGER NOT NULL,
  monthlyContribution INTEGER NOT NULL,
  durationMonths INTEGER NOT NULL,
  createdAt TEXT NOT NULL
)''');
  }

  Future<List<SavingsPlan>> loadPlans() async {
    final rows = await _db.query(_table, orderBy: 'rowid ASC');
    return rows.map(SavingsPlan.fromJson).toList();
  }

  Future<void> insertPlan(SavingsPlan plan) async {
    await _db.insert(_table, plan.toJson());
  }

  Future<void> close() => _db.close();
}
