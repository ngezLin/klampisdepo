import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userRole = authState.role;

    // Define navigation tiles with role requirements
    final navItems = [
      _NavItem(
        icon: Icons.dashboard,
        title: 'Dashboard',
        roles: ['owner'],
        onTap: () {},
      ),
      _NavItem(
        icon: Icons.wallet,
        title: 'Cash Session',
        roles: ['admin', 'owner'],
        onTap: () {},
      ),
      _NavItem(
        icon: Icons.inventory,
        title: 'Items & Inventory',
        roles: ['admin', 'owner'],
        onTap: () {},
      ),
      _NavItem(
        icon: Icons.point_of_sale,
        title: 'Transactions',
        roles: ['cashier', 'admin', 'owner'],
        onTap: () => context.push('/pos'),
      ),
      _NavItem(
        icon: Icons.history,
        title: 'History',
        roles: ['cashier', 'admin', 'owner'],
        onTap: () => context.push('/history'),
      ),
      _NavItem(
        icon: Icons.calendar_today,
        title: 'Attendance',
        roles: ['owner'],
        onTap: () {},
      ),
      _NavItem(
        icon: Icons.list_alt,
        title: 'Audit Logs',
        roles: ['owner'],
        onTap: () {},
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Klampis POS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Klampis POS', style: TextStyle(color: Colors.white, fontSize: 24)),
                  Text(userRole.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            ...navItems
                .where((item) => item.roles.contains(userRole.toLowerCase()))
                .map((item) => ListTile(
                      leading: Icon(item.icon),
                      title: Text(item.title),
                      onTap: item.onTap,
                    )),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Logged in as: ${userRole.toUpperCase()}'),
            const SizedBox(height: 16),
            const Text('Select a feature from the drawer to begin.'),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String title;
  final List<String> roles;
  final VoidCallback onTap;

  _NavItem({
    required this.icon,
    required this.title,
    required this.roles,
    required this.onTap,
  });
}
