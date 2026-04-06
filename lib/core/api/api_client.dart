import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dio_provider.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiClient {
  final Dio _dio;
  Dio get dio => _dio;

  ApiClient(this._dio);

  Future<Response> _requestWithRetry(
    Future<Response> Function() request, {
    int maxRetries = 3,
  }) async {
    int attempts = 0;
    while (true) {
      try {
        return await request();
      } on DioException catch (e) {
        final isRetryable = e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout;

        if (isRetryable && attempts < maxRetries) {
          attempts++;
          // Exponential backoff: 1s, 2s, 4s
          final delayMs = (1000 * (1 << (attempts - 1)));
          await Future.delayed(Duration(milliseconds: delayMs));
          continue;
        }
        throw _handleError(e);
      }
    }
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) async {
    return _requestWithRetry(
      () => _dio.get(path, queryParameters: queryParameters, options: options),
    );
  }

  Future<Response> post(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    return _requestWithRetry(
      () => _dio.post(path,
          data: data, queryParameters: queryParameters, options: options),
    );
  }

  Future<Response> patch(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    return _requestWithRetry(
      () => _dio.patch(path,
          data: data, queryParameters: queryParameters, options: options),
    );
  }

  Future<Response> put(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    return _requestWithRetry(
      () => _dio.put(path,
          data: data, queryParameters: queryParameters, options: options),
    );
  }

  Future<Response> delete(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    return _requestWithRetry(
      () => _dio.delete(path,
          data: data, queryParameters: queryParameters, options: options),
    );
  }

  Exception _handleError(DioException error) {
    String message = 'Something went wrong';
    
    if (error.type == DioExceptionType.connectionTimeout || 
        error.type == DioExceptionType.sendTimeout || 
        error.type == DioExceptionType.receiveTimeout) {
      message = 'Connection timed out. Please check your internet.';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'No internet connection.';
    } else if (error.response?.data != null) {
      final data = error.response!.data;
      if (data is Map) {
        // Try to get message from the standard Laravel/Laravel-like response
        message = data['message'] ?? (data['error'] ?? message);
        
        if (data.containsKey('errors')) {
          final errors = data['errors'];
          if (errors is Map && errors.isNotEmpty) {
            final firstErrorKey = errors.keys.first;
            final firstErrorValue = errors[firstErrorKey];
            if (firstErrorValue is List && firstErrorValue.isNotEmpty) {
              message = firstErrorValue.first.toString();
            } else if (firstErrorValue != null) {
              message = firstErrorValue.toString();
            }
          } else if (errors is String && errors.isNotEmpty) {
            message = errors;
          }
        }
      } else if (data is String && data.isNotEmpty) {
        if (data.contains('<html') || data.contains('<!DOCTYPE html>')) {
           message = "Server error (${error.response?.statusCode})";
        } else {
           message = data;
        }
      }
    } else {
      message = error.message ?? message;
    }
    return ApiException(message, error.response?.statusCode);
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});
