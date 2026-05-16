import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_managment/core/config/env/app_env.dart';

import 'api_client.dart';
import 'dio_api_client.dart';

final dioProvider = Provider<Dio>((ref) {
  final env = ref.watch(appEnvProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: env.baseUrl,
      connectTimeout: Duration(milliseconds: env.connectTimeoutMs),
      receiveTimeout: Duration(milliseconds: env.receiveTimeoutMs),
    ),
  );

  if (!env.isProduction || kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );
  }

  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return DioApiClient(dio);
});
