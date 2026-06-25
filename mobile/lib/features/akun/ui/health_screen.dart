import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

final healthProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/health/');
  return response.data as Map<String, dynamic>;
});

class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(healthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Sistem'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(healthProvider),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: healthAsync.when(
        data: (data) => _buildDashboard(context, ref, data),
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00AA5B))),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Gagal memuat status server',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _restartAPI(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restart API?'),
        content: const Text('Ini akan menghentikan sementara API server dan menyalakannya kembali dalam 1 detik. Transaksi offline yang belum sinkron akan aman di perangkat.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restart', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        final dio = ref.read(dioProvider);
        await dio.post('/health/restart');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sinyal restart dikirim. Menghubungkan ulang...')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sinyal restart terkirim: $e')),
          );
        }
      }
    }
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

  Future<void> _rebootServer(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reboot VPS Server?'),
        content: const Text('Ini akan me-reboot seluruh Virtual Private Server. Server akan mati selama sekitar 1 menit. Semua koneksi ke aplikasi akan terputus sementara.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reboot', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        final dio = ref.read(dioProvider);
        await dio.post('/health/reboot');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sinyal reboot dikirim. Server sedang me-reboot...')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sinyal reboot terkirim: $e')),
          );
        }
      }
    }
  }

  Widget _buildDashboard(BuildContext context, WidgetRef ref, Map<String, dynamic> data) {
    final status = data['status'] as String? ?? 'unknown';
    
    final dbData = data['database'] as Map<String, dynamic>?;
    final dbStatus = dbData?['status'] as String? ?? 'unknown';
    final uptime = data['uptime'] as String? ?? '-';
    
    final sysData = data['system'] as Map<String, dynamic>?;
    final memUsage = sysData?['alloc_memory_mb'] as num? ?? 0;
    final memStr = '${memUsage.toStringAsFixed(2)} MB';
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Overall Status Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: status == 'UP' ? const Color(0xFF00AA5B) : Colors.red,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (status == 'UP' ? const Color(0xFF00AA5B) : Colors.red).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                status == 'UP' ? Icons.check_circle_outline : Icons.error_outline,
                size: 64,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                status == 'UP' ? 'Sistem Berjalan Normal' : 'Sistem Bermasalah',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Uptime: $uptime',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        const Text(
          'Detail Layanan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 12),
        
        // Database Card
        _buildDetailCard(
          icon: Icons.storage_rounded,
          title: 'Database (MySQL)',
          value: dbStatus.toUpperCase(),
          valueColor: dbStatus == 'connected' ? const Color(0xFF00AA5B) : Colors.red,
        ),
        
        const SizedBox(height: 12),
        
        // Memory Card
        _buildDetailCard(
          icon: Icons.memory_rounded,
          title: 'Penggunaan Memori',
          value: memStr,
          valueColor: Colors.blue,
        ),

        const SizedBox(height: 24),
        const Text(
          'Alat Pemeliharaan (Dev Only)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 12),
        
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          label: const Text('Restart API Service', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[800],
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => _restartAPI(context, ref),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.storage_rounded, color: Colors.white),
          label: const Text('Restart Database MySQL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[800],
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => _restartMySQL(context, ref),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white),
          label: const Text('Reboot Server VPS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[800],
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => _rebootServer(context, ref),
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF6B7280)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151))),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
