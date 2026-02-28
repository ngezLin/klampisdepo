import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/pos/presentation/pos_screen.dart';
import '../../features/transactions/presentation/history_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authState,
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isAuth && !isLoggingIn) return '/login';
      if (isAuth && isLoggingIn) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/pos',
        builder: (context, state) => const PosScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
    ],
  );
});
