import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../services/pin_store.dart';

class AuthRepository {
  AuthRepository(this._auth, this._storage, this._pins);

  final AuthService _auth;
  final LocalStorageService _storage;
  final PinStore _pins;

  String? get currentUserEmail => _storage.loggedInEmail;

  Future<void> login(String email, String password) async {
    await _auth.login(email, password);
    await _storage.saveLoggedInEmail(email.trim().toLowerCase());
  }

  /// Ends the session and clears the PIN and biometric setting.
  Future<void> logout() async {
    await _storage.clearLoggedInUser();
    await _pins.clear();
  }
}
