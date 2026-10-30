import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _userKey = 'logged_in_email';
  static const _onboardingKey = 'onboarding_complete';

  bool get onboardingComplete {
    try {
      return _prefs.getBool(_onboardingKey) ?? false;
    } on TypeError catch (_) {
      // getBool throws when a non-bool value is stored under the key.
      return false;
    }
  }

  Future<void> saveOnboardingComplete() => _prefs.setBool(_onboardingKey, true);

  String? get loggedInEmail => _prefs.getString(_userKey);

  Future<void> saveLoggedInEmail(String email) =>
      _prefs.setString(_userKey, email);

  Future<void> clearLoggedInUser() => _prefs.remove(_userKey);
}
