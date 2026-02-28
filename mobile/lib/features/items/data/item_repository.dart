import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import 'item_model.dart';

class ItemRepository {
  final Dio _dio;

  ItemRepository(this._dio);

  Future<List<ItemModel>> getItems({int page = 1, int pageSize = 100}) async {
    try {
      final response = await _dio.get('/items', queryParameters: {
        'page': page,
        'page_size': pageSize,
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ItemModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ItemModel>> searchItems(String name) async {
    try {
      final response = await _dio.get('/items/search', queryParameters: {
        'name': name,
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ItemModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepository(ref.watch(dioProvider));
});

final itemsProvider = FutureProvider<List<ItemModel>>((ref) async {
  return ref.watch(itemRepositoryProvider).getItems();
});
