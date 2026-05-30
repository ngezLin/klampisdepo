import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
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
  final _storage = const FlutterSecureStorage();

  AuthNotifier(this.ref) : super(AuthState()) {
    _init();
  }

  Future<void> _init() async {
    final token = await _storage.read(key: 'token');
    if (token != null && !JwtDecoder.isExpired(token)) {
      final payload = JwtDecoder.decode(token);
      state = AuthState(
        token: token,
        role: payload['role'],
        username: payload['username'],
        userId: payload['user_id'] as int?,
      );
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
      
      state = AuthState(
        token: token,
        role: role,
        username: username,
        userId: payload['user_id'] as int?,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Login gagal. Periksa username dan password.',
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
