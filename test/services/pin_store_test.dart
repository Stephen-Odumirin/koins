import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/services/pin_store.dart';

import '../helpers/in_memory_secret_store.dart';

void main() {
  late InMemorySecretStore backing;
  late PinStore store;

  setUp(() {
    backing = InMemorySecretStore();
    store = PinStore(backing);
  });

  test('hasPin is false before save, true after', () async {
    expect(await store.hasPin(), isFalse);
    await store.savePin('1234');
    expect(await store.hasPin(), isTrue);
  });

  test('verifyPin accepts the saved PIN and rejects others', () async {
    await store.savePin('1234');
    expect(await store.verifyPin('1234'), isTrue);
    expect(await store.verifyPin('0000'), isFalse);
  });

  test('verifyPin is false when no PIN is set', () async {
    expect(await store.verifyPin('1234'), isFalse);
  });

  test('savePin rejects invalid PINs', () async {
    expect(() => store.savePin('12'), throwsArgumentError);
    expect(() => store.savePin('12a4'), throwsArgumentError);
  });

  test('stored hash is not the PIN', () async {
    await store.savePin('1234');
    expect(backing.values['pin_hash'], isNotNull);
    expect(backing.values['pin_hash'], isNot('1234'));
  });

  test('savePin resets the failure count', () async {
    await store.recordFailedAttempt();
    await store.savePin('1234');
    expect(await store.failedAttempts(), 0);
  });

  test('failed attempts count and survive a restart', () async {
    expect(await store.failedAttempts(), 0);
    await store.recordFailedAttempt();
    await store.recordFailedAttempt();
    expect(await store.failedAttempts(), 2);
    expect(await PinStore(backing).failedAttempts(), 2);
  });

  test('resetFailedAttempts sets it back to 0', () async {
    await store.recordFailedAttempt();
    await store.resetFailedAttempts();
    expect(await store.failedAttempts(), 0);
  });

  test('biometrics default off and can be enabled', () async {
    expect(await store.biometricsEnabled(), isFalse);
    await store.setBiometricsEnabled(true);
    expect(await store.biometricsEnabled(), isTrue);
  });

  test('clear removes PIN, failures and biometrics', () async {
    await store.savePin('1234');
    await store.recordFailedAttempt();
    await store.setBiometricsEnabled(true);
    await store.clear();
    expect(await store.hasPin(), isFalse);
    expect(await store.failedAttempts(), 0);
    expect(await store.biometricsEnabled(), isFalse);
  });
}
