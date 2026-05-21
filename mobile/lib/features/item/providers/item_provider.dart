import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transaksi/models/transaction_models.dart';
import '../../../core/network/dio_client.dart';
import '../../../services/database/app_database.dart';

final transaksiSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final itemManagementSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final itemsProvider = FutureProvider.family<List<ItemModel>, String>((ref, search) async {
  final dio = ref.read(dioProvider);
  
  try {
    final response = search.isEmpty
        ? await dio.get('/items/', queryParameters: {'page_size': 100}) // safe fallback size for simple lists
        : await dio.get('/items/search', queryParameters: {'name': search, 'page_size': 100});
    
    final List data = response.data['data'];
    return data.map((e) => ItemModel.fromJson(e)).toList();
  } catch (e) {
    return [];
  }
});

class PaginatedItemsState {
  final List<ItemModel> items;
  final int page;
  final bool hasMore;
  final bool isLoading;

  PaginatedItemsState({
    required this.items,
    required this.page,
    required this.hasMore,
    required this.isLoading,
  });

  PaginatedItemsState copyWith({
    List<ItemModel>? items,
    int? page,
    bool? hasMore,
    bool? isLoading,
  }) {
    return PaginatedItemsState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PaginatedItemsNotifier extends StateNotifier<PaginatedItemsState> {
  final Ref ref;
  final String search;

  PaginatedItemsNotifier(this.ref, this.search)
      : super(PaginatedItemsState(items: [], page: 1, hasMore: true, isLoading: false)) {
    loadNextPage();
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);
    final dio = ref.read(dioProvider);

    try {
      final response = search.isEmpty
          ? await dio.get('/items/', queryParameters: {'page': state.page, 'page_size': 20})
          : await dio.get('/items/search', queryParameters: {'name': search, 'page': state.page, 'page_size': 20});

      final List data = response.data['data'] ?? [];
      final List<ItemModel> newItems = data.map((e) => ItemModel.fromJson(e)).toList();

      state = state.copyWith(
        items: [...state.items, ...newItems],
        page: state.page + 1,
        hasMore: newItems.length == 20,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, hasMore: false);
    }
  }

  Future<void> refresh() async {
    state = PaginatedItemsState(items: [], page: 1, hasMore: true, isLoading: false);
    await loadNextPage();
  }
}

final paginatedItemsProvider = StateNotifierProvider.family<PaginatedItemsNotifier, PaginatedItemsState, String>((ref, search) {
  return PaginatedItemsNotifier(ref, search);
});

final itemCrudProvider = Provider((ref) => ItemCrud(ref));

class ItemCrud {
  final Ref ref;
  ItemCrud(this.ref);

  Future<bool> createItem(ItemModel item) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/items/', data: item.toJson());
      ref.invalidate(itemsProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateItem(ItemModel item) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.put('/items/${item.id}', data: item.toJson());
      ref.invalidate(itemsProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteItem(int id) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/items/$id');
      ref.invalidate(itemsProvider);
      return true;
    } catch (e) {
      return false;
    }
  }
}
