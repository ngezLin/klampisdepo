import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../models/po_bill.dart';

class POBillsState {
  final List<POBillModel> bills;
  final bool isLoading;
  final String? error;
  final String statusFilter; // 'all', 'pending', 'paid'
  final String searchQuery;

  POBillsState({
    required this.bills,
    this.isLoading = false,
    this.error,
    this.statusFilter = 'all',
    this.searchQuery = '',
  });

  POBillsState copyWith({
    List<POBillModel>? bills,
    bool? isLoading,
    String? error,
    String? statusFilter,
    String? searchQuery,
  }) {
    return POBillsState(
      bills: bills ?? this.bills,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      statusFilter: statusFilter ?? this.statusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class POBillsNotifier extends StateNotifier<POBillsState> {
  final Ref ref;

  POBillsNotifier(this.ref) : super(POBillsState(bills: [])) {
    loadBills();
  }

  Dio get _dio => ref.read(dioProvider);

  Future<void> loadBills() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get('/po-bills/', queryParameters: {
        'status': state.statusFilter == 'all' ? '' : state.statusFilter,
      });
      
      final List data = response.data['data'] ?? [];
      final List<POBillModel> fetchedBills = data.map((e) => POBillModel.fromJson(e)).toList();
      
      state = state.copyWith(
        bills: fetchedBills,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal memuat tagihan PO: $e',
      );
    }
  }

  void setStatusFilter(String filter) {
    if (state.statusFilter != filter) {
      state = state.copyWith(statusFilter: filter);
      loadBills();
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  List<POBillModel> get filteredBills {
    if (state.searchQuery.isEmpty) {
      return state.bills;
    }
    final q = state.searchQuery.toLowerCase();
    return state.bills.where((bill) {
      return bill.invoiceNumber.toLowerCase().contains(q) ||
             bill.vendorName.toLowerCase().contains(q) ||
             (bill.notes.toLowerCase().contains(q));
    }).toList();
  }

  Future<bool> createBill(POBillModel bill) async {
    try {
      await _dio.post('/po-bills/', data: bill.toJson());
      await loadBills();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateBill(int id, POBillModel bill) async {
    try {
      await _dio.put('/po-bills/$id', data: bill.toJson());
      await loadBills();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markBillAsPaid(int id) async {
    try {
      await _dio.put('/po-bills/$id/pay');
      await loadBills();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteBill(int id) async {
    try {
      await _dio.delete('/po-bills/$id');
      await loadBills();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final poBillsProvider = StateNotifierProvider<POBillsNotifier, POBillsState>((ref) {
  return POBillsNotifier(ref);
});
