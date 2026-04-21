import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/session_manager.dart';
import '../config/config.dart';

/// Custom interceptor that logs responses in chunks to avoid logcat truncation
class ChunkedLogInterceptor extends Interceptor {
  static const int _maxChunkSize =
      2000; // Logcat line limit is ~4KB, use 2KB chunks to be safe

  void _logChunked(String prefix, String message) {
    if (message.isEmpty) return;

    // Split into chunks if needed
    for (int i = 0; i < message.length; i += _maxChunkSize) {
      final end = (i + _maxChunkSize < message.length)
          ? i + _maxChunkSize
          : message.length;
      final chunk = message.substring(i, end);
      debugPrint('$prefix (${i ~/ _maxChunkSize + 1}): $chunk');
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[HTTP] >>> REQUEST: ${options.method} ${options.path}');
    if (options.queryParameters.isNotEmpty) {
      debugPrint('[HTTP] Query: ${options.queryParameters}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      '[HTTP] <<< RESPONSE: ${response.statusCode} ${response.requestOptions.path}',
    );
    if (response.data is Map || response.data is List) {
      // Pretty print JSON in chunks
      try {
        final jsonStr = response.data.toString();
        _logChunked('[HTTP] Body', jsonStr);
      } catch (_) {
        debugPrint('[HTTP] Body: ${response.data}');
      }
    } else {
      _logChunked('[HTTP] Body', response.data?.toString() ?? '(empty)');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '[HTTP ERROR] ${err.requestOptions.method} ${err.requestOptions.path}',
    );
    debugPrint(
      '[HTTP ERROR] Status: ${err.response?.statusCode} - ${err.message}',
    );
    if (err.response?.data != null) {
      _logChunked(
        '[HTTP ERROR] Response',
        err.response?.data?.toString() ?? '',
      );
    }
    super.onError(err, handler);
  }
}

final dioProvider = Provider<Dio>((ref) {
  final sessionManager = ref.watch(sessionManagerProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      headers: {'Accept': 'application/json'},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) =>
          status != null && status >= 200 && status < 300,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await sessionManager.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Immediately clear session on 401 to match Web App behavior.
          await sessionManager.clearSession();
        }
        return handler.next(e);
      },
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(ChunkedLogInterceptor());
  }

  return dio;
});
