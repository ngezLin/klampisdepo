import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for Dio instance
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      // TODO: Replace with the actual IP address of the machine running the backend
      baseUrl: 'http://10.0.2.2:8080/api/v1', 
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Handle global 401 Unauthorized explicitly
        if (e.response?.statusCode == 401) {
          // Trigger logout or token refresh logic
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
});
