import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:charity_managment/models/user_profile.dart';
import 'package:charity_managment/models/user_role.dart';

class AuthLocalStorage {
  static const _sessionKey = 'auth.session';
  static const _onboardingSeenKey = 'auth.onboarding_seen';
  static const _selectedRoleKey = 'auth.selected_role';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _instance() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<bool> readOnboardingSeen() async {
    final prefs = await _instance();
    return prefs.getBool(_onboardingSeenKey) ?? false;
  }

  Future<void> saveOnboardingSeen() async {
    final prefs = await _instance();
    await prefs.setBool(_onboardingSeenKey, true);
  }

  Future<UserRole?> readSelectedRole() async {
    final prefs = await _instance();
    final raw = prefs.getString(_selectedRoleKey);
    if (raw == null) return null;
    return UserRole.fromJson(raw);
  }

  Future<void> saveSelectedRole(UserRole role) async {
    final prefs = await _instance();
    await prefs.setString(_selectedRoleKey, role.value);
  }

  Future<UserProfile?> readSession() async {
    final prefs = await _instance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null) return null;

    final json = jsonDecode(raw) as Map<String, dynamic>;
    return UserProfile.fromJson(json);
  }

  Future<void> saveSession(UserProfile user) async {
    final prefs = await _instance();
    await prefs.setString(_sessionKey, jsonEncode(user.toJson()));
  }

  Future<void> clearSession() async {
    final prefs = await _instance();
    await prefs.remove(_sessionKey);
  }
}
