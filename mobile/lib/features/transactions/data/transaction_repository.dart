import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

class TransactionRepository {
  final Dio _dio;

  TransactionRepository(this._dio);

  Future<void> createTransaction({
    required List<Map<String, dynamic>> items,
    required double paymentAmount,
    required String paymentType,
    String status = 'completed',
  }) async {
    try {
      await _dio.post('/transactions', data: {
        'status': status,
        'paymentAmount': paymentAmount,
        'paymentType': paymentType,
        'items': items,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getTransactionHistory() async {
    try {
      final response = await _dio.get('/transactions/history');
      if (response.statusCode == 200) {
        return response.data['data'] ?? [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(dioProvider));
});
