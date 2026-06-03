import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/ui/login_screen.dart';
import '../../features/home/ui/main_layout.dart';
import '../../features/transaction/ui/transaction_screen.dart';
import '../../features/item/ui/item_list_screen.dart';
import '../../features/history/ui/history_screen.dart';
import '../../features/akun/ui/akun_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/dashboard/ui/dashboard_screen.dart';

part 'router.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.token != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => _slideRoute(state: state, child: const DashboardScreen()),
          ),
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => _slideRoute(state: state, child: const TransactionScreen()),
          ),
          GoRoute(
            path: '/items',
            pageBuilder: (context, state) => _slideRoute(state: state, child: const ItemListScreen()),
          ),
          GoRoute(
            path: '/history',
            pageBuilder: (context, state) => _slideRoute(state: state, child: const HistoryScreen()),
          ),
          GoRoute(
            path: '/akun',
            pageBuilder: (context, state) => _slideRoute(state: state, child: const AkunScreen()),
          ),
        ],
      ),
    ],
  );
}

CustomTransitionPage<T> _slideRoute<T>({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: animation.drive(
          Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)),
        ),
        child: child,
      );
    },
  );
}
