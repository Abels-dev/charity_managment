import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the app-wide [CookieJar] instance.
///
/// Must be overridden at the [ProviderScope] in main.dart with a
/// [PersistCookieJar] so that the backend's httpOnly `cms_auth` cookie
/// is stored and replayed automatically on every Dio request.
final cookieJarProvider = Provider<CookieJar>((ref) {
  throw UnimplementedError('cookieJarProvider must be overridden in ProviderScope');
});
