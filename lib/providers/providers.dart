import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/auth_repository.dart';
import '../repositories/profile_repository.dart';
import '../repositories/savings_repository.dart';
import '../services/auth_service.dart';
import '../services/biometric_gate.dart';
import '../services/local_storage_service.dart';
import '../services/mock_push_service.dart';
import '../services/pin_store.dart';
import '../services/plan_database.dart';
import '../services/secret_store.dart';
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

final secretStoreProvider = Provider<SecretStore>((ref) => FlutterSecretStore());

final biometricGateProvider = Provider<BiometricAuthenticator>(
  (ref) => LocalAuthBiometricGate(),
);

final pinStoreProvider = Provider<PinStore>(
  (ref) => PinStore(ref.watch(secretStoreProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    AuthService(),
    ref.watch(localStorageProvider),
    ref.watch(pinStoreProvider),
  ),
);

final savingsRepositoryProvider = Provider<SavingsRepository>(
  (ref) => SavingsRepository(ref.watch(planDatabaseProvider)),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(UserApiService()),
);

final mockPushServiceProvider = Provider<MockPushService>(
  (ref) => MockPushService(),
);
