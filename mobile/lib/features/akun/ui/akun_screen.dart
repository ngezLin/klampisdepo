import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../services/printer/printer_service.dart';
import '../../../services/sync/offline_sync_service.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/notification_helper.dart';
import 'package:intl/intl.dart';
import '../../cash_session/providers/cash_session_provider.dart';
import '../../cash_session/ui/close_session_sheet.dart';
import '../../attendance/providers/attendance_provider.dart';

class AkunScreen extends ConsumerWidget {
  const AkunScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    
    if (auth.role == 'dev') {
      return _buildDevLayout(context, ref, auth);
    }
    
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
          _SettingsTile(
            icon: Icons.receipt_long_outlined,
            title: 'Format Struk',
            subtitle: 'Kustomisasi layout, lebar kertas, & header/footer',
            onTap: () {
              _showReceiptFormatDialog(context, ref);
            },
          ),

          const SizedBox(height: 24),

          // ─── Shift Kasir Section ────────────────
          _SectionHeader(title: 'Shift Kasir'),
          const SizedBox(height: 8),
          _buildShiftTile(context, ref),
          _SettingsTile(
            icon: Icons.history_outlined,
            title: 'Riwayat Laci Kas',
            subtitle: 'Lihat rekonsiliasi kas dan selisih shift',
            onTap: () {
              _showCashSessionHistoryDialog(context, ref);
            },
          ),
          const SizedBox(height: 24),

          // ─── Absensi Section ───────────────────
          _SectionHeader(title: 'Absensi'),
          const SizedBox(height: 8),
          _buildAttendanceTile(context, ref),
          if (auth.role == 'owner' || auth.role == 'admin') ...[
            _SettingsTile(
              icon: Icons.assignment_outlined,
              title: 'Riwayat Absensi Karyawan',
              subtitle: 'Lihat daftar absensi harian staf',
              onTap: () {
                _showAttendanceHistoryDialog(context, ref);
              },
            ),
          ],
          const SizedBox(height: 24),

          // ─── Toko Section (Owner & Admin) ───────
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
              icon: Icons.receipt_long_outlined,
              title: 'Tagihan Pembelian (PO)',
              subtitle: 'Kelola tagihan PO, tempo, dan foto nota',
              onTap: () {
                context.push('/po-bills');
              },
            ),
            if (auth.role == 'owner')
              _SettingsTile(
                icon: Icons.people_outline,
                title: 'Manajemen Pengguna',
                subtitle: 'Lihat daftar pengguna & role',
                onTap: () {
                  context.push('/users');
                },
              ),
            if (auth.role == 'owner')
              _SettingsTile(
                icon: Icons.receipt_long_outlined,
                title: 'Riwayat Inventori Toko',
                subtitle: 'Pantau mutasi stok inventori toko',
                onTap: () {
                  _showStoreLogsDialog(context, ref);
                },
              ),
            const SizedBox(height: 24),
          ],

          // ─── Developer Tools Section ────────────
          if (auth.role == 'dev') ...[
            _SectionHeader(title: 'Developer Tools'),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.people_outline,
              title: 'Manajemen Pengguna',
              subtitle: 'Buat, ubah, atau hapus pengguna',
              onTap: () {
                context.push('/users');
              },
            ),
            _SettingsTile(
              icon: Icons.monitor_heart_outlined,
              title: 'Sistem & Health Check',
              subtitle: 'Status server dan database backend',
              onTap: () {
                context.push('/health');
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

  Widget _buildDevLayout(BuildContext context, WidgetRef ref, AuthState auth) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Console'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ─── Profile Card ───────────────────────
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue[900]?.withValues(alpha: 0.3),
                  child: const Icon(
                    Icons.terminal_rounded,
                    size: 32,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.username ?? 'Developer',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.4)),
                        ),
                        child: const Text(
                          'DEVELOPER MODE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          const Text(
            'MENU PEMELIHARAAN',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B7280),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // ─── Dev Tools Card List ────────────────
          _buildDevActionCard(
            context: context,
            icon: Icons.people_outline_rounded,
            color: const Color(0xFF3B82F6), // Blue
            title: 'Manajemen Pengguna',
            subtitle: 'Buat, ubah, atau hapus user (CRUD)',
            onTap: () => context.push('/users'),
          ),
          const SizedBox(height: 16),
          _buildDevActionCard(
            context: context,
            icon: Icons.monitor_heart_outlined,
            color: const Color(0xFF10B981), // Green
            title: 'Cek Status Sistem',
            subtitle: 'Pantau health check server dan DB',
            onTap: () => context.push('/health'),
          ),
          const SizedBox(height: 16),
          _buildDevActionCard(
            context: context,
            icon: Icons.receipt_long_rounded,
            color: const Color(0xFF8B5CF6), // Purple
            title: 'Lihat Log Server',
            subtitle: 'Pantau log API & database terupdate',
            onTap: () => context.push('/logs'),
          ),
          const SizedBox(height: 16),
          _buildDevActionCard(
            context: context,
            icon: Icons.storage_rounded,
            color: const Color(0xFFF59E0B), // Amber/Orange
            title: 'Restart Database MySQL',
            subtitle: 'Mulai ulang database service secara instan',
            onTap: () => _restartMySQL(context, ref),
          ),

          const SizedBox(height: 48),

          // ─── Logout Button ──────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Keluar Akun Dev', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Keluar Dev Mode?'),
                    content: const Text('Apakah Anda yakin ingin keluar dari sesi developer?'),
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
        ],
      ),
    );
  }

  Widget _buildDevActionCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF9CA3AF),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _restartMySQL(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restart MySQL?'),
        content: const Text('Ini akan menghentikan sementara database MySQL dan menyalakannya kembali dalam 1 detik. Semua koneksi database aktif akan terputus sesaat.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restart', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        final dio = ref.read(dioProvider);
        await dio.post('/health/restart-mysql');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sinyal restart MySQL dikirim. Menghubungkan ulang...')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sinyal restart MySQL terkirim: $e')),
          );
        }
      }
    }
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
      case 'dev':
        return 'DEVELOPER';
      case 'cashier':
        return 'KASIR';
      default:
        return role?.toUpperCase() ?? 'UNKNOWN';
    }
  }

  void _showPrinterSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return _PrinterSettingsSheet(scrollController: scrollController);
          },
        );
      },
    );
  }

  void _showReceiptFormatDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return _ReceiptFormatSettingsSheet(scrollController: scrollController);
          },
        );
      },
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

  void _showStoreLogsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const _StoreLogsDialog(),
    );
  }

  Widget _buildShiftTile(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(cashSessionProvider);
    final activeSession = sessionState.activeSession;
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    if (sessionState.isLoading) {
      return const _SettingsTile(
        icon: Icons.lock_outline,
        title: 'Memeriksa Shift Kasir...',
        subtitle: 'Harap tunggu...',
        trailing: SizedBox(
          width: 20, height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (activeSession != null) {
      final double openingCash = (activeSession['opening_cash'] as num?)?.toDouble() ?? 0.0;
      return _SettingsTile(
        icon: Icons.lock_open_outlined,
        title: 'Shift Kasir Aktif',
        subtitle: 'Modal Awal: ${currencyFormat.format(openingCash)}',
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: const Text(
            'TUTUP SHIFT',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const CloseSessionSheet(),
          );
        },
      );
    }

    return _SettingsTile(
      icon: Icons.lock_outline,
      title: 'Buka Shift Kasir',
      subtitle: 'Ketuk untuk mengaktifkan laci kasir',
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        _showOpenShiftDialog(context, ref);
      },
    );
  }

  void _showOpenShiftDialog(BuildContext parentContext, WidgetRef ref) {
    final cashController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (statefulContext, setState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.lock_open, color: Color(0xFF00AA5B)),
                  SizedBox(width: 8),
                  Text('Buka Shift Kasir', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Masukkan jumlah modal awal di laci kasir untuk memulai shift baru.'),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: cashController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Modal Awal (Rupiah)',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Harap masukkan modal awal';
                        }
                        if (double.tryParse(val) == null) {
                          return 'Harus berupa angka';
                        }
                        if (double.parse(val) < 0) {
                          return 'Tidak boleh kurang dari 0';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setState(() => isSubmitting = true);
                          final startingCash = double.parse(cashController.text.trim());
                          final success = await ref.read(cashSessionProvider.notifier).openSession(startingCash);
                          setState(() => isSubmitting = false);
                          if (success && statefulContext.mounted) {
                            Navigator.pop(dialogContext);
                            showTopSnackBar(parentContext, 'Shift Kasir Berhasil Dibuka!');
                          } else if (statefulContext.mounted) {
                            final err = ref.read(cashSessionProvider).error ?? 'Gagal membuka shift.';
                            showTopSnackBar(statefulContext, err, backgroundColor: Colors.red[700]);
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Buka Shift'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCashSessionHistoryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const _CashSessionHistoryDialog(),
    );
  }

  Widget _buildAttendanceTile(BuildContext context, WidgetRef ref) {
    final attendanceState = ref.watch(attendanceProvider);

    if (attendanceState.isLoading) {
      return const _SettingsTile(
        icon: Icons.check_circle_outline,
        title: 'Memeriksa Status Absensi...',
        subtitle: 'Harap tunggu...',
        trailing: SizedBox(
          width: 20, height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (attendanceState.isTodayClockedIn) {
      return const _SettingsTile(
        icon: Icons.check_circle,
        title: 'Sudah Absen Hari Ini',
        subtitle: 'Terima kasih, selamat bekerja!',
        trailing: Icon(Icons.check, color: Color(0xFF00AA5B)),
        onTap: null,
      );
    }

    return _SettingsTile(
      icon: Icons.assignment_turned_in_outlined,
      title: 'Absen Masuk Kerja',
      subtitle: 'Ketuk untuk absensi kehadiran hari ini',
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        _showClockInDialog(context, ref);
      },
    );
  }

  void _showClockInDialog(BuildContext context, WidgetRef ref) {
    String selectedStatus = 'present';
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.assignment_turned_in, color: Color(0xFF00AA5B)),
                  SizedBox(width: 8),
                  Text('Absen Hari Ini', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Harap pilih status kehadiran Anda hari ini:'),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status Kehadiran',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'present', child: Text('Hadir (Present)')),
                        DropdownMenuItem(value: 'absent', child: Text('Absen (Absent)')),
                        DropdownMenuItem(value: 'off', child: Text('Libur (Off)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => selectedStatus = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: 'Catatan / Keterangan',
                        border: OutlineInputBorder(),
                        hintText: 'Misal: Hadir shift pagi, atau sakit flu',
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setState(() => isSubmitting = true);
                          final success = await ref.read(attendanceProvider.notifier).clockIn(
                                status: selectedStatus,
                                note: noteController.text.trim(),
                              );
                          setState(() => isSubmitting = false);
                          if (success && context.mounted) {
                            Navigator.pop(context);
                            showTopSnackBar(context, 'Absensi Anda berhasil disimpan!');
                          } else if (context.mounted) {
                            final err = ref.read(attendanceProvider).error ?? 'Gagal absensi.';
                            showTopSnackBar(context, err, backgroundColor: Colors.red[700]);
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Kirim Absen'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAttendanceHistoryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const _AttendanceHistoryDialog(),
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

class _CashSessionHistoryDialog extends ConsumerWidget {
  const _CashSessionHistoryDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM HH:mm');
    final historyAsync = ref.watch(cashSessionHistoryProvider);

    return AlertDialog(
      title: const Text('Riwayat Laci Kas'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: historyAsync.when(
          data: (sessions) {
            if (sessions.isEmpty) {
              return const Center(child: Text('Belum ada riwayat shift.'));
            }
            return ListView.separated(
              itemCount: sessions.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final sess = Map<String, dynamic>.from(sessions[index] as Map);
                final double opening = (sess['OpeningCash'] as num?)?.toDouble() ?? 0.0;
                final double closing = sess['ClosingCash'] != null ? (sess['ClosingCash'] as num).toDouble() : 0.0;
                final double diff = sess['Difference'] != null ? (sess['Difference'] as num).toDouble() : 0.0;
                final String openedAtStr = sess['OpenedAt'] ?? '';
                final String closedAtStr = sess['ClosedAt'] ?? '';
                
                final openTime = openedAtStr.isNotEmpty ? dateFormat.format(_parseDateTime(openedAtStr)) : '-';
                final closeTime = closedAtStr.isNotEmpty ? dateFormat.format(_parseDateTime(closedAtStr)) : 'Aktif';

                return ListTile(
                  title: Text(
                    'Shift #${sess['ID']} (${sess['Status'].toUpperCase()})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  subtitle: Text(
                    'Buka: $openTime | Tutup: $closeTime\nModal: ${currencyFormat.format(opening)} | Fisik: ${currencyFormat.format(closing)}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: sess['Status'] == 'open'
                      ? const Chip(label: Text('AKTIF', style: TextStyle(fontSize: 9, color: Colors.green)), backgroundColor: Color(0xFFE5F7EE))
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Selisih', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            Text(
                              currencyFormat.format(diff),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: diff == 0 ? Colors.green : (diff > 0 ? Colors.blue : Colors.red),
                              ),
                            ),
                          ],
                        ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
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

class _AttendanceHistoryDialog extends ConsumerWidget {
  const _AttendanceHistoryDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    final historyAsync = ref.watch(attendanceHistoryProvider);

    return AlertDialog(
      title: const Text('Riwayat Absensi Karyawan'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: historyAsync.when(
          data: (logs) {
            if (logs.isEmpty) {
              return const Center(child: Text('Belum ada riwayat absensi.'));
            }
            return ListView.separated(
              itemCount: logs.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final log = Map<String, dynamic>.from(logs[index] as Map);
                final userObj = log['user'] != null ? Map<String, dynamic>.from(log['user'] as Map) : {};
                final String username = userObj['username'] as String? ?? 'Staff';
                final String status = log['status'] ?? 'unknown';
                final String? note = log['note'];
                final String dateStr = log['date'] ?? '';
                final String formattedDate = dateStr.isNotEmpty 
                    ? dateFormat.format(_parseDateTime(dateStr))
                    : '-';

                Color statusColor = Colors.grey;
                if (status == 'present') statusColor = const Color(0xFF00AA5B);
                if (status == 'absent') statusColor = Colors.red;
                if (status == 'off') statusColor = Colors.orange;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.15),
                    child: Icon(
                      status == 'present' ? Icons.check_rounded : Icons.close_rounded,
                      color: statusColor,
                    ),
                  ),
                  title: Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '$formattedDate\nCatatan: ${note ?? "-"}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
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

DateTime _parseDateTime(dynamic raw) {
  if (raw == null) return DateTime.now();
  if (raw is DateTime) return raw;
  if (raw is num) {
    return DateTime.fromMillisecondsSinceEpoch(raw.toInt() * 1000).toLocal();
  }
  final str = raw.toString().trim();
  if (str.isEmpty) return DateTime.now();
  final parsedInt = int.tryParse(str);
  if (parsedInt != null) {
    return DateTime.fromMillisecondsSinceEpoch(parsedInt * 1000).toLocal();
  }
  try {
    if (!str.contains('Z') && !str.contains('+') && !RegExp(r'-\d{2}:\d{2}$').hasMatch(str)) {
      final formatted = str.replaceAll(' ', 'T') + 'Z';
      return DateTime.parse(formatted).toLocal();
    }
    return DateTime.parse(str).toLocal();
  } catch (_) {
    try {
      return DateTime.parse(str).toLocal();
    } catch (_) {
      return DateTime.now();
    }
  }
}

class _PrinterSettingsSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  const _PrinterSettingsSheet({required this.scrollController});

  @override
  ConsumerState<_PrinterSettingsSheet> createState() => _PrinterSettingsSheetState();
}

class _PrinterSettingsSheetState extends ConsumerState<_PrinterSettingsSheet> {
  List<PrinterDevice> _devices = [];
  bool _isScanning = false;
  final _ipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scan();
    });
  }

  Future<void> _scan() async {
    if (_isScanning) return;
    setState(() {
      _isScanning = true;
      _devices = [];
    });
    try {
      final printerService = ref.read(printerServiceProvider);
      final list = await printerService.scanPrinters();
      setState(() {
        _devices = list;
      });
    } catch (e) {
      debugPrint('Scan error: $e');
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final printer = ref.watch(printerServiceProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pengaturan Printer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 12),
          if (printer.isConnected) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE5F7EE),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF00AA5B).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF00AA5B), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Terhubung ke: ${printer.connectedPrinter?.name}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF212121)),
                        ),
                        Text(
                          'Alamat: ${printer.connectedPrinter?.address} (${printer.connectedPrinter?.type.name.toUpperCase()})',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => printer.disconnect(),
                    child: const Text('Putuskan', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Perangkat Tersedia',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              Row(
                children: [
                  if (_isScanning)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      onPressed: _scan,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _devices.isEmpty
                ? Center(
                    child: _isScanning
                        ? const Text('Mencari printer...', style: TextStyle(color: Colors.grey))
                        : const Text('Tidak ada printer ditemukan. Hubungkan manual di bawah.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  )
                : ListView.separated(
                    controller: widget.scrollController,
                    itemCount: _devices.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final dev = _devices[index];
                      if (dev.address == 'manual') return const SizedBox.shrink();
                      
                      final isCurrent = printer.connectedPrinter?.address == dev.address;
                      final isReceipt = printer.receiptPrinter?.address == dev.address;
                      final isKitchen = printer.kitchenPrinter?.address == dev.address;

                      IconData typeIcon = Icons.print;
                      if (dev.type == PrinterConnectionType.bluetooth) typeIcon = Icons.bluetooth;
                      if (dev.type == PrinterConnectionType.network) typeIcon = Icons.wifi;
                      if (dev.type == PrinterConnectionType.usb) typeIcon = Icons.usb;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: isCurrent ? const Color(0xFFE5F7EE) : const Color(0xFFF3F4F5),
                          child: Icon(typeIcon, color: isCurrent ? const Color(0xFF00AA5B) : const Color(0xFF212121)),
                        ),
                        title: Text(dev.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text('${dev.address} | ${dev.type.name.toUpperCase()}', style: const TextStyle(fontSize: 11)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isReceipt)
                              const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Chip(
                                  label: Text('STRUK', style: TextStyle(fontSize: 8, color: Colors.blue)),
                                  backgroundColor: Color(0xFFE0F2FE),
                                ),
                              ),
                            if (isKitchen)
                              const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Chip(
                                  label: Text('DAPUR', style: TextStyle(fontSize: 8, color: Colors.orange)),
                                  backgroundColor: Color(0xFFFEF3C7),
                                ),
                              ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (val) async {
                                if (val == 'connect') {
                                  await printer.connectToPrinter(dev);
                                } else if (val == 'receipt') {
                                  printer.designatePrinter(dev, 'receipt');
                                } else if (val == 'kitchen') {
                                  printer.designatePrinter(dev, 'kitchen');
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'connect',
                                  child: Row(
                                    children: [
                                      Icon(Icons.link, size: 16, color: isCurrent ? const Color(0xFF00AA5B) : null),
                                      const SizedBox(width: 8),
                                      Text(isCurrent ? 'Hubungkan Ulang' : 'Hubungkan Utama'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'receipt',
                                  child: Row(
                                    children: [
                                      Icon(Icons.receipt_long, size: 16, color: Colors.blue),
                                      const SizedBox(width: 8),
                                      Text('Jadikan Printer Struk'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'kitchen',
                                  child: Row(
                                    children: [
                                      Icon(Icons.restaurant_menu, size: 16, color: Colors.orange),
                                      const SizedBox(width: 8),
                                      Text('Jadikan Printer Dapur'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'Tambah Printer IP Manual',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ipController,
                  decoration: InputDecoration(
                    hintText: '192.168.1.100:9100',
                    hintStyle: const TextStyle(fontSize: 12),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AA5B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Simpan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                onPressed: () async {
                  final ip = _ipController.text.trim();
                  if (ip.isNotEmpty) {
                    final device = PrinterDevice(
                      name: 'Network Printer (Manual)',
                      address: ip.contains(':') ? ip : '$ip:9100',
                      type: PrinterConnectionType.network,
                    );
                    final success = await printer.connectToPrinter(device);
                    if (success) {
                      printer.designatePrinter(device, 'receipt');
                      _ipController.clear();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Printer manual ditambahkan sebagai printer struk')),
                        );
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReceiptFormatSettingsSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  const _ReceiptFormatSettingsSheet({required this.scrollController});

  @override
  ConsumerState<_ReceiptFormatSettingsSheet> createState() => _ReceiptFormatSettingsSheetState();
}

class _ReceiptFormatSettingsSheetState extends ConsumerState<_ReceiptFormatSettingsSheet> {
  late TextEditingController _headerController;
  late TextEditingController _footerController;
  late int _paperWidth;
  late bool _showLogo;
  late bool _showAddress;
  late bool _showPhone;
  late bool _showFooter;
  late bool _showNotes;

  @override
  void initState() {
    super.initState();
    final printer = ref.read(printerServiceProvider);
    final config = printer.formatConfig;
    _headerController = TextEditingController(text: config.customHeaderMessage);
    _footerController = TextEditingController(text: config.customFooterMessage);
    _paperWidth = config.paperWidth;
    _showLogo = config.showLogo;
    _showAddress = config.showAddress;
    _showPhone = config.showPhone;
    _showFooter = config.showFooter;
    _showNotes = config.showNotes;
  }

  @override
  void dispose() {
    _headerController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final printer = ref.watch(printerServiceProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kustomisasi Format Struk',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              children: [
                const Text(
                  'Ukuran Kertas',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _paperWidth,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 32, child: Text('58mm (32 Karakter)')),
                    DropdownMenuItem(value: 48, child: Text('80mm (48 Karakter)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _paperWidth = val);
                    }
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pengaturan Visibilitas',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Tampilkan Logo Toko', style: TextStyle(fontSize: 14)),
                  value: _showLogo,
                  activeThumbColor: const Color(0xFF00AA5B),
                  onChanged: (val) => setState(() => _showLogo = val),
                ),
                SwitchListTile(
                  title: const Text('Tampilkan Alamat Toko', style: TextStyle(fontSize: 14)),
                  value: _showAddress,
                  activeThumbColor: const Color(0xFF00AA5B),
                  onChanged: (val) => setState(() => _showAddress = val),
                ),
                SwitchListTile(
                  title: const Text('Tampilkan Telepon Toko', style: TextStyle(fontSize: 14)),
                  value: _showPhone,
                  activeThumbColor: const Color(0xFF00AA5B),
                  onChanged: (val) => setState(() => _showPhone = val),
                ),
                SwitchListTile(
                  title: const Text('Tampilkan Catatan Transaksi', style: TextStyle(fontSize: 14)),
                  value: _showNotes,
                  activeThumbColor: const Color(0xFF00AA5B),
                  onChanged: (val) => setState(() => _showNotes = val),
                ),
                SwitchListTile(
                  title: const Text('Tampilkan Pesan Footer', style: TextStyle(fontSize: 14)),
                  value: _showFooter,
                  activeThumbColor: const Color(0xFF00AA5B),
                  onChanged: (val) => setState(() => _showFooter = val),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pesan Header Tambahan',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _headerController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Misal: Selamat Datang!',
                    hintStyle: TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pesan Footer',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _footerController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Terima kasih telah berbelanja!',
                    hintStyle: TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00AA5B),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final newConfig = ReceiptFormatConfig(
                      showLogo: _showLogo,
                      showAddress: _showAddress,
                      showPhone: _showPhone,
                      showFooter: _showFooter,
                      showNotes: _showNotes,
                      customHeaderMessage: _headerController.text.trim(),
                      customFooterMessage: _footerController.text.trim(),
                      paperWidth: _paperWidth,
                    );
                    await printer.updateFormatConfig(newConfig);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Format struk berhasil disimpan!')),
                      );
                    }
                  },
                  child: const Text('Simpan Pengaturan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreLogsDialog extends StatelessWidget {
  const _StoreLogsDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.receipt_long_outlined, color: Color(0xFF00AA5B)),
          SizedBox(width: 8),
          Text('Riwayat Inventori Toko', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
      content: const SizedBox(
        width: double.maxFinite,
        height: 500,
        child: _GlobalInventoryView(),
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

class _GlobalInventoryView extends ConsumerStatefulWidget {
  const _GlobalInventoryView();

  @override
  ConsumerState<_GlobalInventoryView> createState() => _GlobalInventoryViewState();
}

class _GlobalInventoryViewState extends ConsumerState<_GlobalInventoryView> {
  final List<dynamic> _logs = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  final int _limit = 20;
  final _scrollController = ScrollController();

  // Filter states
  String _selectedType = ''; // '' means all
  DateTimeRange? _selectedDateRange;

  bool get _hasActiveFilters => _selectedType.isNotEmpty || _selectedDateRange != null;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      final dio = ref.read(dioProvider);
      final Map<String, dynamic> params = {
        'page': _page,
        'limit': _limit,
      };

      if (_selectedType.isNotEmpty) {
        params['type'] = _selectedType;
      }

      if (_selectedDateRange != null) {
        final df = DateFormat('yyyy-MM-dd');
        params['start_date'] = df.format(_selectedDateRange!.start);
        params['end_date'] = df.format(_selectedDateRange!.end);
      }

      final response = await dio.get('/inventory/history', queryParameters: params);

      final dataMap = response.data as Map<String, dynamic>;
      final List<dynamic> newLogs = dataMap['data'] ?? [];

      setState(() {
        _logs.addAll(newLogs);
        _page++;
        _isLoading = false;
        _hasMore = newLogs.length == _limit;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        showTopSnackBar(context, 'Gagal memuat riwayat: $e', backgroundColor: Colors.red[700]);
      }
    }
  }

  void _onFilterChanged() {
    setState(() {
      _logs.clear();
      _page = 1;
      _hasMore = true;
    });
    _loadMore();
  }

  void _resetFilters() {
    setState(() {
      _selectedType = '';
      _selectedDateRange = null;
      _logs.clear();
      _page = 1;
      _hasMore = true;
    });
    _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Column(
      children: [
        // ─── Filter Bar ──────────────────────────
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                    color: Colors.white,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedType,
                      isExpanded: true,
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                      items: const [
                        DropdownMenuItem(value: '', child: Text('Semua Tipe')),
                        DropdownMenuItem(value: 'restock', child: Text('Restock')),
                        DropdownMenuItem(value: 'sale', child: Text('Penjualan')),
                        DropdownMenuItem(value: 'adjustment', child: Text('Adjustment')),
                        DropdownMenuItem(value: 'refund', child: Text('Refund')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          _selectedType = val;
                          _onFilterChanged();
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: InkWell(
                  onTap: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                      initialDateRange: _selectedDateRange,
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF00AA5B),
                              onPrimary: Colors.white,
                              onSurface: Colors.black87,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (range != null) {
                      _selectedDateRange = range;
                      _onFilterChanged();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDateRange == null
                                ? 'Pilih Tanggal'
                                : '${DateFormat('dd/MM').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM').format(_selectedDateRange!.end)}',
                            style: const TextStyle(fontSize: 12, color: Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                ),
              ),
              if (_hasActiveFilters) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.redAccent, size: 20),
                  tooltip: 'Reset Filter',
                  onPressed: _resetFilters,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
              ],
            ],
          ),
        ),

        // ─── Logs List ───────────────────────────
        Expanded(
          child: _logs.isEmpty && _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _logs.isEmpty
                  ? const Center(child: Text('Tidak ada riwayat inventori.'))
                  : ListView.separated(
                      controller: _scrollController,
                      itemCount: _logs.length + (_hasMore ? 1 : 0),
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        if (index >= _logs.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                            ),
                          );
                        }

                        final log = Map<String, dynamic>.from(_logs[index] as Map);
                        final itemObj = log['item'] != null ? Map<String, dynamic>.from(log['item'] as Map) : {};
                        final userObj = log['user'] != null ? Map<String, dynamic>.from(log['user'] as Map) : {};

                        final itemName = itemObj['name'] as String? ?? 'Item #${log['item_id']}';
                        final change = (log['change'] as num?)?.toInt() ?? 0;
                        final finalStock = (log['final_stock'] as num?)?.toInt() ?? 0;
                        final String type = log['type'] ?? 'adjustment';
                        final String refId = log['reference_id'] ?? '';
                        final String note = log['note'] ?? '';
                        final String username = userObj['username'] as String? ?? 'System';
                        final String dateStr = log['created_at'] ?? '';
                        final formattedDate = dateStr.isNotEmpty 
                            ? dateFormat.format(_parseDateTime(dateStr)) 
                            : '-';

                        Color changeColor = Colors.grey;
                        String changeSign = '';
                        if (change > 0) {
                          changeColor = const Color(0xFF00AA5B);
                          changeSign = '+';
                        } else if (change < 0) {
                          changeColor = Colors.red;
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      itemName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: changeColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '$changeSign$change',
                                      style: TextStyle(
                                        color: changeColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tipe: ${type.toUpperCase()}${refId.isNotEmpty ? " ($refId)" : ""}',
                                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                  ),
                                  Text(
                                    'Stok Akhir: $finalStock',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              if (note.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Catatan: $note',
                                  style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.black54),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Oleh: $username',
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}


