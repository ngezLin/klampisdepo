import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';

class AuthNotifier extends ChangeNotifier {
  final Dio _dio;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String _role = '';

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String get role => _role;

  AuthNotifier(this._dio) {
    _checkInitialAuth();
  }

  Future<void> _checkInitialAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final role = prefs.getString('user_role');
    if (token != null && token.isNotEmpty) {
      _isAuthenticated = true;
      _role = role ?? '';
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.post('/login', data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200 && response.data['token'] != null) {
        final token = response.data['token'];
        final role = response.data['role'] ?? '';
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_role', role);
        
        _isAuthenticated = true;
        _role = role;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
    _isAuthenticated = false;
    _role = '';
    notifyListeners();
  }
}

final authProvider = ChangeNotifierProvider<AuthNotifier>((ref) {
  return AuthNotifier(ref.watch(dioProvider));
});
