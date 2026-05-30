import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/ui/login_screen.dart';
import '../../features/home/ui/main_layout.dart';
import '../../features/transaksi/ui/transaksi_screen.dart';
import '../../features/item/ui/item_list_screen.dart';
import '../../features/riwayat/ui/riwayat_screen.dart';
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
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/',
            builder: (context, state) => const TransaksiScreen(),
          ),
          GoRoute(
            path: '/items',
            builder: (context, state) => const ItemListScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const RiwayatScreen(),
          ),
          GoRoute(
            path: '/akun',
            builder: (context, state) => const AkunScreen(),
          ),
        ],
      ),
    ],
  );
}
