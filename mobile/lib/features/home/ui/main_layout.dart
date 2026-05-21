import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final role = authState.role;

    final showItemTab = role == 'admin' || role == 'owner';
    final showHistoryTab = role == 'admin' || role == 'owner' || role == 'cashier';

    final List<NavigationDestination> destinations = [
      const NavigationDestination(
        icon: Icon(Icons.shopping_cart_outlined),
        selectedIcon: Icon(Icons.shopping_cart),
        label: 'Transaksi',
      ),
    ];
    final List<String> paths = ['/'];

    if (showItemTab) {
      destinations.add(const NavigationDestination(
        icon: Icon(Icons.inventory_2_outlined),
        selectedIcon: Icon(Icons.inventory_2),
        label: 'Item',
      ));
      paths.add('/items');
    }

    if (showHistoryTab) {
      destinations.add(const NavigationDestination(
        icon: Icon(Icons.history_outlined),
        selectedIcon: Icon(Icons.history),
        label: 'Riwayat',
      ));
      paths.add('/history');
    }

    // Always show Akun tab
    destinations.add(const NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Akun',
    ));
    paths.add('/akun');

    // Calculate current index based on route
    final location = GoRouterState.of(context).matchedLocation;
    int currentIndex = paths.indexOf(location);
    if (currentIndex == -1) currentIndex = 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          if (index >= 0 && index < paths.length) {
            context.go(paths[index]);
          }
        },
        destinations: destinations,
      ),
    );
  }
}
