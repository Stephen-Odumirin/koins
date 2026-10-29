import '../services/auth_service.dart';
import '../services/local_storage_service.dart';

class AuthRepository {
  AuthRepository(this._auth, this._storage);

  final AuthService _auth;
  final LocalStorageService _storage;

  String? get currentUserEmail => _storage.loggedInEmail;

  Future<void> login(String email, String password) async {
    await _auth.login(email, password);
    await _storage.saveLoggedInEmail(email.trim().toLowerCase());
  }

  Future<void> logout() => _storage.clearLoggedInUser();
}
