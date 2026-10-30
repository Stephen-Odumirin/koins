import 'package:savings_app/services/plan_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Opens an empty in-memory [PlanDatabase] for tests.
Future<PlanDatabase> openMemoryPlanDb() async {
  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(version: 1, onCreate: PlanDatabase.onCreate),
  );
  return PlanDatabase(db);
}
