import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final upcomingBillsAsync = ref.watch(upcomingPOBillsProvider);
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Dashboard Bisnis', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(dashboardStatsProvider),
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardStatsProvider),
          child: ListView(
            padding: const EdgeInsets.all(20),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // ─── Welcome Header ───
              const Text(
                'Performa Toko Hari Ini',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Update terakhir: ${DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(DateTime.now())}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),

              // ─── Earnings Double Grid (Omzet & Profit today) ───
              Row(
                children: [
                  Expanded(
                    child: _buildGradientCard(
                      title: 'Omzet Hari Ini',
                      value: currencyFormat.format(stats.todayOmzet),
                      icon: Icons.payments_outlined,
                      colors: [const Color(0xFF00AA5B), const Color(0xFF00AA8B)],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGradientCard(
                      title: 'Profit Hari Ini',
                      value: currencyFormat.format(stats.todayProfit),
                      icon: Icons.trending_up_rounded,
                      colors: [const Color(0xFF2563EB), const Color(0xFF3B82F6)],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ─── Earnings Double Grid (Omzet & Profit monthly) ───
              Row(
                children: [
                  Expanded(
                    child: _buildGlassCard(
                      title: 'Omzet Bulan Ini',
                      value: currencyFormat.format(stats.monthlyOmzet),
                      icon: Icons.calendar_today_outlined,
                      iconColor: const Color(0xFF00AA5B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGlassCard(
                      title: 'Profit Bulan Ini',
                      value: currencyFormat.format(stats.monthlyProfit),
                      icon: Icons.analytics_outlined,
                      iconColor: const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ─── Today Transactions Count Card ───
              _buildMetricTile(
                icon: Icons.shopping_bag_outlined,
                iconColor: const Color(0xFF8B5CF6),
                title: 'Transaksi Sukses Hari Ini',
                value: '${stats.todayTransactions} Transaksi',
              ),
              const SizedBox(height: 12),

              // ─── Upcoming PO Bills (Tagihan Jatuh Tempo H-3) ───
              upcomingBillsAsync.when(
                data: (bills) {
                  if (bills.isEmpty) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildWarningTile(
                      context: context,
                      icon: Icons.receipt_long_rounded,
                      title: 'Tagihan Jatuh Tempo (H-3)!',
                      subtitle: '${bills.length} tagihan PO distributor mendekati jatuh tempo',
                      onTap: () => context.go('/po-bills'),
                      bgColor: const Color(0xFFFFFBEB),
                      borderColor: const Color(0xFFFDE68A),
                      iconBgColor: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFD97706),
                      textColor: const Color(0xFFB45309),
                      subtitleColor: const Color(0xFF92400E),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (err, stack) => const SizedBox.shrink(),
              ),

              // ─── Low Stock Indicator ───
              if (stats.lowStock > 0) ...[
                _buildWarningTile(
                  context: context,
                  icon: Icons.warning_amber_rounded,
                  title: 'Stok Menipis!',
                  subtitle: '${stats.lowStock} item memiliki stok di bawah 5 pcs',
                  onTap: () => context.go('/items'),
                ),
                const SizedBox(height: 24),
              ],

              // ─── Best Selling Products (Progress Bars) ───
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.stars_rounded, color: Color(0xFFFBBF24)),
                        SizedBox(width: 8),
                        Text(
                          'Produk Terlaris (Unit)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (stats.topSellingItems.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text('Belum ada transaksi terekam.'),
                        ),
                      )
                    else
                      ...stats.topSellingItems.map((item) {
                        // Find max quantity to scale progress bar
                        final maxQty = stats.topSellingItems.first.quantity;
                        final double percent = maxQty > 0 ? item.quantity / maxQty : 0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${item.quantity} pcs',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF00AA5B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: percent,
                                  minHeight: 8,
                                  backgroundColor: const Color(0xFFF3F4F6),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00AA5B)),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text('Gagal memuat dashboard: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(dashboardStatsProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Gradient Card Maker
  Widget _buildGradientCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.85), size: 22),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // Premium Glassmorphic Card Maker
  Widget _buildGlassCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // General Metric Tile Row
  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Warning Alert Banner Card
  Widget _buildWarningTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color bgColor = const Color(0xFFFEF2F2),
    Color borderColor = const Color(0xFFFCA5A5),
    Color iconBgColor = const Color(0xFFFEE2E2),
    Color iconColor = const Color(0xFFDC2626),
    Color textColor = const Color(0xFF991B1B),
    Color subtitleColor = const Color(0xFF7F1D1D),
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: iconColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
