import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class AuthState {
  final String? token;
  final String? role;
  final String? username;
  final int? userId;
  final bool isLoading;
  final String? error;

  AuthState({
    this.token,
    this.role,
    this.username,
    this.userId,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    String? token,
    String? role,
    String? username,
    int? userId,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      token: token ?? this.token,
      role: role ?? this.role,
      username: username ?? this.username,
      userId: userId ?? this.userId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  FlutterSecureStorage get _storage => ref.read(secureStorageProvider);

  AuthNotifier(this.ref) : super(AuthState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    try {
      final token = await _storage.read(key: 'token');
      if (token != null && !JwtDecoder.isExpired(token)) {
        final payload = JwtDecoder.decode(token);
        state = AuthState(
          token: token,
          role: payload['role'],
          username: payload['username'],
          userId: (payload['user_id'] as num?)?.toInt(),
          isLoading: false,
        );
      } else {
        state = AuthState(isLoading: false);
      }
    } catch (e) {
      try {
        await _storage.delete(key: 'token');
      } catch (_) {}
      state = AuthState(isLoading: false);
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/login', data: {
        'username': username,
        'password': password,
      });

      final token = response.data['token'];
      final role = response.data['role'];
      final payload = JwtDecoder.decode(token);

      await _storage.write(key: 'token', value: token);
      
      // Cache credentials for offline login fallback
      await _storage.write(key: 'offline_password_$username', value: password);
      await _storage.write(key: 'offline_role_$username', value: role);
      await _storage.write(key: 'offline_id_$username', value: ((payload['user_id'] as num?)?.toInt())?.toString() ?? '');
      await _storage.write(key: 'offline_token_$username', value: token);
      
      state = AuthState(
        token: token,
        role: role,
        username: username,
        userId: (payload['user_id'] as num?)?.toInt(),
        isLoading: false,
      );
      return true;
    } catch (e) {
      if (e is DioException &&
          (e.type == DioExceptionType.connectionTimeout ||
           e.type == DioExceptionType.sendTimeout ||
           e.type == DioExceptionType.receiveTimeout ||
           e.type == DioExceptionType.connectionError ||
           e.response == null ||
           (e.response?.statusCode != null && e.response!.statusCode! >= 500 && e.response!.statusCode! <= 599))) {
        
        final cachedPassword = await _storage.read(key: 'offline_password_$username');
        if (cachedPassword != null) {
          if (cachedPassword == password) {
            final cachedRole = await _storage.read(key: 'offline_role_$username');
            final cachedIdStr = await _storage.read(key: 'offline_id_$username');
            final cachedToken = await _storage.read(key: 'offline_token_$username');
            final cachedId = cachedIdStr != null ? int.tryParse(cachedIdStr) : null;

            state = AuthState(
              token: cachedToken,
              role: cachedRole,
              username: username,
              userId: cachedId,
              isLoading: false,
            );
            return true;
          } else {
            state = state.copyWith(
              isLoading: false,
              error: 'Password salah (Offline).',
            );
            return false;
          }
        } else {
          state = state.copyWith(
            isLoading: false,
            error: 'Koneksi gagal. Pengguna belum pernah login di perangkat ini.',
          );
          return false;
        }
      }

      String errorMessage = 'Login gagal. Periksa username dan password.';
      if (e is DioException) {
        if (e.response != null && e.response?.data is Map) {
          final serverError = e.response?.data['error'] ?? e.response?.data['message'];
          if (serverError != null) {
            errorMessage = serverError.toString();
          }
        }
      }
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
