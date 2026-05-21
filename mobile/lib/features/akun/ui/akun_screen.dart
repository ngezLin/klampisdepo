import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../services/printer/printer_service.dart';
import '../../../services/sync/offline_sync_service.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/notification_helper.dart';

class AkunScreen extends ConsumerWidget {
  const AkunScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final pendingSync = ref.watch(pendingSyncCountProvider);
    final printer = ref.watch(printerServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Profile Card ───────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFFE5F7EE),
                  child: Text(
                    (auth.username ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00AA5B),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.username ?? 'User',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _roleColor(auth.role).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _roleLabel(auth.role),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _roleColor(auth.role),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ─── Sinkronisasi Section ───────────────
          _SectionHeader(title: 'Sinkronisasi'),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.cloud_sync_outlined,
            title: 'Status Sinkronisasi',
            subtitle: pendingSync.when(
              data: (count) => count == 0
                  ? 'Semua transaksi tersinkronisasi'
                  : '$count transaksi menunggu sync',
              loading: () => 'Memeriksa...',
              error: (_, __) => 'Gagal memeriksa status',
            ),
            trailing: pendingSync.when(
              data: (count) => count > 0
                  ? Badge(
                      label: Text('$count'),
                      backgroundColor: Colors.orange,
                      child: const Icon(Icons.cloud_off, color: Colors.orange),
                    )
                  : const Icon(Icons.cloud_done, color: Color(0xFF00AA5B)),
              loading: () => const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, __) => const Icon(Icons.error_outline, color: Colors.red),
            ),
            onTap: () async {
              final result = await ref.read(offlineSyncServiceProvider).syncPendingTransactions();
              if (context.mounted) {
                showTopSnackBar(
                  context,
                  'Sync: ${result.synced} berhasil, ${result.failed} gagal',
                );
              }
            },
          ),

          const SizedBox(height: 24),

          // ─── Printer Section ────────────────────
          _SectionHeader(title: 'Printer'),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.print_outlined,
            title: 'Printer Thermal',
            subtitle: printer.isConnected
                ? 'Terhubung: ${printer.connectedPrinter?.name}'
                : 'Belum terhubung',
            trailing: Icon(
              printer.isConnected ? Icons.check_circle : Icons.circle_outlined,
              color: printer.isConnected ? const Color(0xFF00AA5B) : Colors.grey,
            ),
            onTap: () {
              _showPrinterSettings(context, ref);
            },
          ),

          const SizedBox(height: 24),

          // ─── Toko Section (Owner only) ──────────
          if (auth.role == 'owner' || auth.role == 'admin') ...[
            _SectionHeader(title: 'Toko'),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.storefront_outlined,
              title: 'Informasi Toko',
              subtitle: 'Nama, alamat, dan nomor telepon toko',
              onTap: () {
                _showStoreInfoDialog(context, ref);
              },
            ),
            _SettingsTile(
              icon: Icons.people_outline,
              title: 'Manajemen Pengguna',
              subtitle: 'Lihat daftar pengguna & role',
              onTap: () {
                _showUsersDialog(context, ref);
              },
            ),
            const SizedBox(height: 24),
          ],

          // ─── Aplikasi Section ───────────────────
          _SectionHeader(title: 'Aplikasi'),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            subtitle: 'KlampisDepo POS v1.0.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'KlampisDepo POS',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(
                  Icons.storefront_rounded,
                  size: 48,
                  color: Color(0xFF00AA5B),
                ),
                children: [
                  const Text('Aplikasi Point of Sale untuk KlampisDepo.'),
                ],
              );
            },
          ),
          _SettingsTile(
            icon: Icons.link_outlined,
            title: 'Server API',
            subtitle: apiBaseUrl,
            onTap: null,
          ),

          const SizedBox(height: 32),

          // ─── Logout Button ──────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Keluar?'),
                    content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Keluar'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(authProvider.notifier).logout();
                }
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static Color _roleColor(String? role) {
    switch (role) {
      case 'owner':
        return const Color(0xFF7C3AED); // purple
      case 'admin':
        return const Color(0xFF0284C7); // blue
      case 'cashier':
        return const Color(0xFF00AA5B); // green
      default:
        return Colors.grey;
    }
  }

  static String _roleLabel(String? role) {
    switch (role) {
      case 'owner':
        return 'OWNER';
      case 'admin':
        return 'ADMIN';
      case 'cashier':
        return 'KASIR';
      default:
        return role?.toUpperCase() ?? 'UNKNOWN';
    }
  }

  void _showPrinterSettings(BuildContext context, WidgetRef ref) {
    final printer = ref.read(printerServiceProvider);
    final ipController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pengaturan Printer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ipController,
              decoration: const InputDecoration(
                labelText: 'IP Printer',
                hintText: '192.168.1.100:9100',
              ),
            ),
            const SizedBox(height: 16),
            if (printer.isConnected)
              ListTile(
                leading: const Icon(Icons.check_circle, color: Color(0xFF00AA5B)),
                title: Text('Terhubung: ${printer.connectedPrinter?.name}'),
                trailing: TextButton(
                  onPressed: () {
                    printer.disconnect();
                    Navigator.pop(context);
                  },
                  child: const Text('Putuskan', style: TextStyle(color: Colors.red)),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () async {
              final ip = ipController.text.trim();
              if (ip.isNotEmpty) {
                final device = PrinterDevice(
                  name: 'Network Printer',
                  address: ip.contains(':') ? ip : '$ip:9100',
                  type: PrinterConnectionType.network,
                );
                await printer.connectToPrinter(device);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Hubungkan'),
          ),
        ],
      ),
    );
  }

  void _showStoreInfoDialog(BuildContext context, WidgetRef ref) {
    final printer = ref.read(printerServiceProvider);
    final nameCtrl = TextEditingController(text: printer.storeName);
    final addressCtrl = TextEditingController(text: printer.storeAddress ?? '');
    final phoneCtrl = TextEditingController(text: printer.storePhone ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informasi Toko'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Toko')),
            const SizedBox(height: 8),
            TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Alamat')),
            const SizedBox(height: 8),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Telepon')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              printer.storeName = nameCtrl.text.trim();
              printer.storeAddress = addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim();
              printer.storePhone = phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim();
              Navigator.pop(context);
              showTopSnackBar(
                context,
                'Informasi toko berhasil disimpan!',
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showUsersDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const _UsersListDialog(),
    );
  }
}

// ─── Reusable Widgets ──────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.grey[500],
        letterSpacing: 0.5,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF212121), size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, color: Colors.grey) : null),
        onTap: onTap,
      ),
    );
  }
}

// ─── Users List Dialog ─────────────────────────

class _UsersListDialog extends ConsumerWidget {
  const _UsersListDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(_usersProvider);

    return AlertDialog(
      title: const Text('Daftar Pengguna'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: usersAsync.when(
          data: (users) {
            if (users.isEmpty) {
              return const Center(child: Text('Tidak ada data pengguna.'));
            }
            return ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = users[index] as Map<String, dynamic>;
                final role = user['role'] as String? ?? 'unknown';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AkunScreen._roleColor(role).withOpacity(0.15),
                    child: Text(
                      (user['username'] as String? ?? 'U')[0].toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AkunScreen._roleColor(role),
                      ),
                    ),
                  ),
                  title: Text(user['username'] as String? ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(role.toUpperCase(),
                      style: TextStyle(fontSize: 11, color: AkunScreen._roleColor(role), fontWeight: FontWeight.bold)),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}

final _usersProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/users/');
  return response.data as List<dynamic>;
});
