import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/network/cookie_jar_provider.dart';
import 'core/network/token_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  // Set up a persistent cookie jar so Dio automatically stores and replays
  // the backend's httpOnly `cms_auth` session cookie on every request.
  // Note: getApplicationDocumentsDirectory is not supported on Web.
  final CookieJar cookieJar;
  if (kIsWeb) {
    cookieJar = CookieJar(); // In-memory fallback for web (browser handles actual cookies)
  } else {
    final appDocDir = await getApplicationDocumentsDirectory();
    cookieJar = PersistCookieJar(
      storage: FileStorage('${appDocDir.path}/.cookies/'),
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        cookieJarProvider.overrideWithValue(cookieJar),
      ],
      child: const CharityManagementApp(),
    ),
  );
}

