import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:charity_managment/models/user_profile.dart';
import 'package:charity_managment/models/user_role.dart';

class AuthLocalStorage {
  AuthLocalStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _sessionKey = 'auth.session';
  static const _onboardingSeenKey = 'auth.onboarding_seen';
  static const _selectedRoleKey = 'auth.selected_role';

  Future<bool> readOnboardingSeen() async {
    return _prefs.getBool(_onboardingSeenKey) ?? false;
  }

  Future<void> saveOnboardingSeen() async {
    await _prefs.setBool(_onboardingSeenKey, true);
  }

  Future<UserRole?> readSelectedRole() async {
    final raw = _prefs.getString(_selectedRoleKey);
    if (raw == null) return null;
    return UserRole.fromJson(raw);
  }

  Future<void> saveSelectedRole(UserRole role) async {
    await _prefs.setString(_selectedRoleKey, role.value);
  }

  Future<UserProfile?> readSession() async {
    final raw = _prefs.getString(_sessionKey);
    if (raw == null) return null;

    final json = jsonDecode(raw) as Map<String, dynamic>;
    return UserProfile.fromJson(json);
  }

  Future<void> saveSession(UserProfile user) async {
    await _prefs.setString(_sessionKey, jsonEncode(user.toJson()));
  }

  Future<void> clearSession() async {
    await _prefs.remove(_sessionKey);
  }
}
