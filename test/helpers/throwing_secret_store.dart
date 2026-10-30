import 'package:savings_app/services/secret_store.dart';

/// A secret store whose reads fail once [failReads] is set.
class ThrowingSecretStore implements SecretStore {
  bool failReads = true;

  @override
  Future<String?> read(String key) async {
    if (failReads) throw StateError('secure storage unavailable');
    return null;
  }

  @override
  Future<void> write(String key, String value) async {}

  @override
  Future<void> delete(String key) async {}
}
