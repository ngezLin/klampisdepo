import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transaction/models/transaction_models.dart';
import '../../../core/network/dio_client.dart';
import '../../../services/database/app_database.dart';
import '../../../services/sync/offline_sync_service.dart';

final transactionSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final itemManagementSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final itemsProvider = FutureProvider.family<List<ItemModel>, String>((ref, search) async {
  final dio = ref.read(dioProvider);
  final appDb = ref.read(appDatabaseProvider);
  
  try {
    final response = search.isEmpty
        ? await dio.get('/items/', queryParameters: {'page_size': 100}) // safe fallback size for simple lists
        : await dio.get('/items/search', queryParameters: {'name': search, 'page_size': 100, 'skip_count': 'true'});
    
    final List data = response.data['data'] ?? [];
    final List<ItemModel> remoteItems = data.map((e) => ItemModel.fromJson(e)).toList();
    
    // Cache items locally in Drift SQLite asynchronously (don't block the UI)
    final dbItems = remoteItems.map((e) => Item(
      id: e.id,
      name: e.name,
      description: e.description,
      stock: e.stock,
      isStockManaged: e.isStockManaged,
      buyPrice: e.buyPrice,
      price: e.price,
      imageUrl: e.imageUrl,
      updatedAt: DateTime.now(),
    )).toList();
    
    appDb.upsertItems(dbItems).catchError((err) {
      debugPrint('[ItemsProvider] DB cache write failed: $err');
    });
    
    return remoteItems;
  } catch (e) {
    // Fallback to local SQLite cache when offline or network fails
    try {
      final localItems = await appDb.getItemsOffline(search);
      return localItems.map((item) => ItemModel(
        id: item.id,
        name: item.name,
        description: item.description,
        stock: item.stock,
        isStockManaged: item.isStockManaged,
        buyPrice: item.buyPrice,
        price: item.price,
        imageUrl: item.imageUrl,
      )).toList();
    } catch (_) {
      return [];
    }
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
          : await dio.get('/items/search', queryParameters: {'name': search, 'page': state.page, 'page_size': 20, 'skip_count': 'true'});

      final List data = response.data['data'] ?? [];
      final List<ItemModel> newItems = data.map((e) => ItemModel.fromJson(e)).toList();

      // Cache items locally in Drift SQLite asynchronously
      try {
        final appDb = ref.read(appDatabaseProvider);
        final dbItems = newItems.map((e) => Item(
          id: e.id,
          name: e.name,
          description: e.description,
          stock: e.stock,
          isStockManaged: e.isStockManaged,
          buyPrice: e.buyPrice,
          price: e.price,
          imageUrl: e.imageUrl,
          updatedAt: DateTime.now(),
        )).toList();
        await appDb.upsertItems(dbItems);
      } catch (_) {
        // Silently catch cache save errors
      }

      if (!mounted) return;
      state = state.copyWith(
        items: [...state.items, ...newItems],
        page: state.page + 1,
        hasMore: newItems.length == 20,
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      // Offline fallback: load cached items from Drift on first page load
      if (state.page == 1) {
        try {
          final appDb = ref.read(appDatabaseProvider);
          final localItems = await appDb.getItemsOffline(search);
          if (!mounted) return;
          final models = localItems.map((item) => ItemModel(
            id: item.id,
            name: item.name,
            description: item.description,
            stock: item.stock,
            isStockManaged: item.isStockManaged,
            buyPrice: item.buyPrice,
            price: item.price,
            imageUrl: item.imageUrl,
          )).toList();
          
          state = state.copyWith(
            items: models,
            hasMore: false,
            isLoading: false,
          );
          return;
        } catch (_) {}
      }
      if (!mounted) return;
      state = state.copyWith(isLoading: false, hasMore: false);
    }
  }

  Future<void> refresh() async {
    state = PaginatedItemsState(items: [], page: 1, hasMore: true, isLoading: false);
    await loadNextPage();
  }
}

final paginatedItemsProvider = StateNotifierProvider.autoDispose.family<PaginatedItemsNotifier, PaginatedItemsState, String>((ref, search) {
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
