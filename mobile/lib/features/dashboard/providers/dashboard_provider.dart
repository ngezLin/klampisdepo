import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../po_bill/models/po_bill.dart';

class TopSellingItem {
  final int itemId;
  final int quantity;
  final String name;

  TopSellingItem({
    required this.itemId,
    required this.quantity,
    required this.name,
  });

  factory TopSellingItem.fromJson(Map<String, dynamic> json) {
    return TopSellingItem(
      itemId: (json['item_id'] as num?)?.toInt() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? 'Item #${json['item_id']}',
    );
  }
}

class DashboardStats {
  final double todayProfit;
  final double monthlyProfit;
  final double todayOmzet;
  final double monthlyOmzet;
  final int todayTransactions;
  final int lowStock;
  final List<TopSellingItem> topSellingItems;

  DashboardStats({
    required this.todayProfit,
    required this.monthlyProfit,
    required this.todayOmzet,
    required this.monthlyOmzet,
    required this.todayTransactions,
    required this.lowStock,
    required this.topSellingItems,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    var list = json['top_selling_items'] as List? ?? [];
    List<TopSellingItem> topItems = list.map((i) => TopSellingItem.fromJson(i as Map<String, dynamic>)).toList();

    return DashboardStats(
      todayProfit: (json['today_profit'] as num?)?.toDouble() ?? 0.0,
      monthlyProfit: (json['monthly_profit'] as num?)?.toDouble() ?? 0.0,
      todayOmzet: (json['today_omzet'] as num?)?.toDouble() ?? 0.0,
      monthlyOmzet: (json['monthly_omzet'] as num?)?.toDouble() ?? 0.0,
      todayTransactions: (json['today_transactions'] as num?)?.toInt() ?? 0,
      lowStock: (json['low_stock'] as num?)?.toInt() ?? 0,
      topSellingItems: topItems,
    );
  }
}

final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/dashboard/');
  return DashboardStats.fromJson(response.data as Map<String, dynamic>);
});

final upcomingPOBillsProvider = FutureProvider.autoDispose<List<POBillModel>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/po-bills/', queryParameters: {
    'status': 'pending',
  });
  final List data = response.data['data'] ?? [];
  final List<POBillModel> fetchedBills = data.map((e) => POBillModel.fromJson(e as Map<String, dynamic>)).toList();
  
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  return fetchedBills.where((bill) {
    final due = DateTime(bill.dueDate.year, bill.dueDate.month, bill.dueDate.day);
    final diff = due.difference(today).inDays;
    return diff <= 3; // due in 3 days or already overdue
  }).toList();
});
