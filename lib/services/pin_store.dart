import '../utils/secret_hash.dart';
import 'secret_store.dart';

/// Stores a salted hash of the user's 4-digit PIN, the failed-attempt count
/// and the biometrics preference.
class PinStore {
  PinStore(this._store);

  final SecretStore _store;

  static const _hashKey = 'pin_hash';
  static const _saltKey = 'pin_salt';
  static const _attemptsKey = 'failed_attempts';
  static const _biometricsKey = 'biometrics_enabled';
  static final _pinPattern = RegExp(r'^\d{4}$');

  Future<bool> hasPin() async => await _store.read(_hashKey) != null;

  Future<void> savePin(String pin) async {
    if (!_pinPattern.hasMatch(pin)) {
      throw ArgumentError.value(pin, 'pin', 'PIN must be exactly 4 digits');
    }
    final salt = generateSalt();
    await _store.write(_saltKey, salt);
    await _store.write(_hashKey, hashSecret(pin, salt));
    await resetFailedAttempts();
  }

  Future<bool> verifyPin(String pin) async {
    final hash = await _store.read(_hashKey);
    final salt = await _store.read(_saltKey);
    if (hash == null || salt == null) return false;
    return hashSecret(pin, salt) == hash;
  }

  Future<int> failedAttempts() async =>
      int.tryParse(await _store.read(_attemptsKey) ?? '') ?? 0;

  Future<void> recordFailedAttempt() async {
    final next = await failedAttempts() + 1;
    await _store.write(_attemptsKey, next.toString());
  }

  Future<void> resetFailedAttempts() => _store.write(_attemptsKey, '0');

  Future<bool> biometricsEnabled() async =>
      await _store.read(_biometricsKey) == 'true';

  Future<void> setBiometricsEnabled(bool enabled) =>
      _store.write(_biometricsKey, enabled.toString());

  Future<void> clear() async {
    await _store.delete(_hashKey);
    await _store.delete(_saltKey);
    await _store.delete(_attemptsKey);
    await _store.delete(_biometricsKey);
  }
}
