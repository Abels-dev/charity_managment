import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cookie_jar_provider.dart';
import 'token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this.ref);

  final Ref ref;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = ref.read(tokenStorageProvider).getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      ref.read(cookieJarProvider).deleteAll();
      ref.read(tokenStorageProvider).clearToken();
      developer.log(
        '401 received for ${err.requestOptions.path} — cookies and token cleared.',
        name: 'AuthInterceptor',
      );
    }
    super.onError(err, handler);
  }
}
