import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env/app_env.dart';
import 'auth_interceptor.dart';
import 'cookie_jar_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final env = ref.watch(appEnvProvider);
  final cookieJar = ref.watch(cookieJarProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: env.baseUrl,
      connectTimeout: Duration(milliseconds: env.connectTimeoutMs),
      receiveTimeout: Duration(milliseconds: env.receiveTimeoutMs),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      extra: {
        'withCredentials': true,
      },
    ),
  );

  // CookieManager is not supported on Web. Browser cookies are handled by
  // the platform when withCredentials is enabled.
  if (!kIsWeb) {
    dio.interceptors.add(CookieManager(cookieJar));
  }

  // AuthInterceptor handles 401 errors (clears local state on session expiry).
  dio.interceptors.add(AuthInterceptor(ref));

  // Log all requests/responses in non-production builds.
  if (!env.isProduction) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => debugPrint('[DIO] $obj'),
    ));
  }

  return dio;
});

