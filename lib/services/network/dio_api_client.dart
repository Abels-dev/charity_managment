import 'package:dio/dio.dart';

import 'package:charity_managment/core/errors/app_exception.dart';

import 'api_client.dart';
import 'api_response.dart';

class DioApiClient implements ApiClient {
  DioApiClient(this._dio);

  final Dio _dio;

  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? decoder,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      return ApiResponse<T>(
        statusCode: response.statusCode ?? 200,
        data: _decodeData(response.data, decoder),
      );
    } on DioException catch (error) {
      throw AppException(
        error.message ?? 'Network request failed',
        code: error.response?.statusCode?.toString(),
      );
    }
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? decoder,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: body,
        queryParameters: queryParameters,
      );
      return ApiResponse<T>(
        statusCode: response.statusCode ?? 200,
        data: _decodeData(response.data, decoder),
      );
    } on DioException catch (error) {
      throw AppException(
        error.message ?? 'Network request failed',
        code: error.response?.statusCode?.toString(),
      );
    }
  }

  T _decodeData<T>(dynamic source, T Function(dynamic data)? decoder) {
    if (decoder != null) {
      return decoder(source);
    }
    return source as T;
  }
}
