import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/core/errors/app_exception.dart';
import 'package:savings_app/repositories/auth_repository.dart';
import 'package:savings_app/services/auth_service.dart';
import 'package:savings_app/services/local_storage_service.dart';
import 'package:savings_app/services/pin_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/in_memory_secret_store.dart';

Future<(AuthRepository, LocalStorageService, PinStore)> _build() async {
  SharedPreferences.setMockInitialValues({});
  final storage = LocalStorageService(await SharedPreferences.getInstance());
  final pins = PinStore(InMemorySecretStore());
  return (AuthRepository(AuthService(), storage, pins), storage, pins);
}

void main() {
  test('login with the demo account succeeds and saves the email', () async {
    final (repo, storage, _) = await _build();
    await repo.login('test@bank.com', 'Password123');
    expect(storage.loggedInEmail, 'test@bank.com');
  });

  test('any other login throws AppException', () async {
    final (repo, storage, _) = await _build();
    await expectLater(
        repo.login('other@bank.com', 'Password123'), throwsA(isA<AppException>()));
    await expectLater(
        repo.login('test@bank.com', 'wrong'), throwsA(isA<AppException>()));
    expect(storage.loggedInEmail, isNull);
  });

  test('logout clears the email and the PIN', () async {
    final (repo, storage, pins) = await _build();
    await repo.login('test@bank.com', 'Password123');
    await pins.savePin('1234');
    await pins.setBiometricsEnabled(true);

    await repo.logout();

    expect(storage.loggedInEmail, isNull);
    expect(await pins.hasPin(), isFalse);
    expect(await pins.biometricsEnabled(), isFalse);
  });
}
