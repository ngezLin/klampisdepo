import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

class UsersState {
  final List<dynamic> users;
  final bool isLoading;
  final String? error;

  UsersState({
    this.users = const [],
    this.isLoading = false,
    this.error,
  });

  UsersState copyWith({
    List<dynamic>? users,
    bool? isLoading,
    String? error,
  }) {
    return UsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UsersNotifier extends StateNotifier<UsersState> {
  final Ref ref;

  UsersNotifier(this.ref) : super(UsersState()) {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/users/');
      state = state.copyWith(
        users: response.data as List<dynamic>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal mengambil data pengguna: $e',
      );
    }
  }

  Future<bool> createUser(String username, String password, String role) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/users/', data: {
        'username': username,
        'password': password,
        'role': role,
      });
      await fetchUsers();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateUser(int id, String? username, String? password, String? role) async {
    try {
      final dio = ref.read(dioProvider);
      final data = <String, dynamic>{};
      if (username != null && username.isNotEmpty) data['username'] = username;
      if (password != null && password.isNotEmpty) data['password'] = password;
      if (role != null && role.isNotEmpty) data['role'] = role;

      await dio.put('/users/$id', data: data);
      await fetchUsers();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/users/$id');
      await fetchUsers();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final usersProvider = StateNotifierProvider.autoDispose<UsersNotifier, UsersState>((ref) {
  return UsersNotifier(ref);
});
