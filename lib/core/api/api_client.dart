import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.patch(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.delete(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
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
    return Exception(message);
  }
}
