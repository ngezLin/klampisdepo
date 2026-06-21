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
        data: (data) => _buildDashboard(data),
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

  Widget _buildDashboard(Map<String, dynamic> data) {
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
