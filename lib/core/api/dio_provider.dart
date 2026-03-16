import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/session_manager.dart';

final dioProvider = Provider<Dio>((ref) {
  final sessionManager = ref.watch(sessionManagerProvider);
  
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api-dev.converf.com',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) => status != null && status >= 200 && status < 300,
    ),
  );

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await sessionManager.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onError: (DioException e, handler) async {
      if (e.response?.statusCode == 401) {
        await sessionManager.clearSession();
        // Potential logout/redirect logic could be handled by a listener on state
      }
      return handler.next(e);
    },
  ));

  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));

  return dio;
});
