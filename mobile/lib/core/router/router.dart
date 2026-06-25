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
import '../../features/po_bill/ui/po_bills_screen.dart';
import '../../features/akun/ui/users_screen.dart';
import '../../features/akun/ui/health_screen.dart';
import '../../features/akun/ui/logs_screen.dart';

part 'router.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  final authNotifier = ValueNotifier<AuthState>(ref.read(authProvider));
  
  ref.listen<AuthState>(authProvider, (_, next) {
    authNotifier.value = next;
  });

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = authNotifier.value;
      if (authState.isLoading) return null;

      final isLoggedIn = authState.token != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';

      if (isLoggedIn) {
        final isDev = authState.role == 'dev';
        if (isDev) {
          final devRoutes = ['/health', '/users', '/akun', '/logs'];
          if (!devRoutes.contains(state.matchedLocation)) {
            return '/akun';
          }
        } else {
          // Non-dev users shouldn't access developer-only routes
          if (state.matchedLocation == '/health') {
            return '/';
          }
          if (state.matchedLocation == '/users' && authState.role != 'owner') {
            return '/';
          }
          if (isLoggingIn) {
            return '/';
          }
        }
      }

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
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const TransactionScreen(),
            ),
          ),
          GoRoute(
            path: '/po-bills',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const POBillsScreen(),
            ),
          ),
          GoRoute(
            path: '/items',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ItemListScreen(),
            ),
          ),
          GoRoute(
            path: '/history',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const HistoryScreen(),
            ),
          ),
          GoRoute(
            path: '/akun',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const AkunScreen(),
            ),
          ),
          GoRoute(
            path: '/users',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const UsersScreen(),
            ),
          ),
          GoRoute(
            path: '/health',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const HealthScreen(),
            ),
          ),
          GoRoute(
            path: '/logs',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const LogsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}
