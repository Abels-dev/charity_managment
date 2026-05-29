import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kAuthTokenKey = 'auth_token_key';

class TokenStorage {
  TokenStorage(this._prefs);

  final SharedPreferences _prefs;

  Future<void> saveToken(String token) async {
    await _prefs.setString(_kAuthTokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_kAuthTokenKey);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_kAuthTokenKey);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in ProviderScope');
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(ref.watch(sharedPreferencesProvider));
});
