import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:charity_managment/features/profile/domain/models/profile_data.dart';
import 'package:charity_managment/features/profile/domain/models/profile_role.dart';

class ProfileLocalStorage {
  static const _donorProfileKey = 'profile.donor';
  static const _charityProfileKey = 'profile.charity';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _instance() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<ProfileData?> readProfile(ProfileRole role) async {
    final prefs = await _instance();
    final key = _keyForRole(role);
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return ProfileData.fromJson(json);
  }

  Future<void> saveProfile(ProfileRole role, ProfileData profile) async {
    final prefs = await _instance();
    final key = _keyForRole(role);
    final raw = jsonEncode(profile.toJson());
    await prefs.setString(key, raw);
  }

  String _keyForRole(ProfileRole role) {
    return role == ProfileRole.charity ? _charityProfileKey : _donorProfileKey;
  }
}
