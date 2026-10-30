import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/auth_repository.dart';
import '../repositories/profile_repository.dart';
import '../repositories/savings_repository.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../services/plan_database.dart';
import '../services/user_api_service.dart';

// Overridden in main() with the real instance
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override sharedPreferencesProvider in main()'),
);

// Overridden in main() with the opened database
final planDatabaseProvider = Provider<PlanDatabase>(
  (ref) => throw UnimplementedError('Override planDatabaseProvider in main()'),
);

final localStorageProvider = Provider<LocalStorageService>(
  (ref) => LocalStorageService(ref.watch(sharedPreferencesProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(AuthService(), ref.watch(localStorageProvider)),
);

final savingsRepositoryProvider = Provider<SavingsRepository>(
  (ref) => SavingsRepository(ref.watch(planDatabaseProvider)),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(UserApiService()),
);
