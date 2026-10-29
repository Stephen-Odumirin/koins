import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/savings_plan.dart';

class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _userKey = 'logged_in_email';
  static const _plansKey = 'savings_plans';

  String? get loggedInEmail => _prefs.getString(_userKey);

  Future<void> saveLoggedInEmail(String email) =>
      _prefs.setString(_userKey, email);

  Future<void> clearLoggedInUser() => _prefs.remove(_userKey);

  List<SavingsPlan> loadPlans() {
    final raw = _prefs.getString(_plansKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((e) => SavingsPlan.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Corrupt data: start fresh rather than crash the dashboard
      return [];
    }
  }

  Future<void> savePlans(List<SavingsPlan> plans) {
    final encoded = jsonEncode(plans.map((p) => p.toJson()).toList());
    return _prefs.setString(_plansKey, encoded);
  }
}
