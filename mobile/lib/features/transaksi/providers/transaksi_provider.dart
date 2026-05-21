import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_models.dart';
import '../../../core/network/dio_client.dart';
import '../../../services/sync/offline_sync_service.dart';

class TransaksiState {
  final List<CartItem> cart;
  final double discount;
  final String? note;
  final String transactionType;
  final String paymentType;
  final double paymentAmount;
  final int? currentDraftId;
  final bool isSubmitting;
  final bool lastCheckoutWasOffline; // Notify UI that checkout was saved offline

  TransaksiState({
    this.cart = const [],
    this.discount = 0,
    this.note,
    this.transactionType = 'onsite',
    this.paymentType = 'cash',
    this.paymentAmount = 0,
    this.currentDraftId,
    this.isSubmitting = false,
    this.lastCheckoutWasOffline = false,
  });

  double get totalBeforeDiscount => cart.fold(0, (sum, item) => sum + item.subtotal);
  double get finalTotal => totalBeforeDiscount - discount;
  double get change => paymentAmount - finalTotal;

  TransaksiState copyWith({
    List<CartItem>? cart,
    double? discount,
    String? note,
    String? transactionType,
    String? paymentType,
    double? paymentAmount,
    int? currentDraftId,
    bool? isSubmitting,
    bool? lastCheckoutWasOffline,
  }) {
    return TransaksiState(
      cart: cart ?? this.cart,
      discount: discount ?? this.discount,
      note: note ?? this.note,
      transactionType: transactionType ?? this.transactionType,
      paymentType: paymentType ?? this.paymentType,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      currentDraftId: currentDraftId ?? this.currentDraftId,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      lastCheckoutWasOffline: lastCheckoutWasOffline ?? false,
    );
  }
}

class TransaksiNotifier extends StateNotifier<TransaksiState> {
  final Ref ref;

  TransaksiNotifier(this.ref) : super(TransaksiState());

  void addToCart(ItemModel item) {
    final existingIndex = state.cart.indexWhere((i) => i.item.id == item.id);
    if (existingIndex >= 0) {
      final updatedCart = List<CartItem>.from(state.cart);
      updatedCart[existingIndex] = updatedCart[existingIndex].copyWith(
        quantity: updatedCart[existingIndex].quantity + 1,
      );
      state = state.copyWith(cart: updatedCart);
    } else {
      state = state.copyWith(cart: [...state.cart, CartItem(item: item)]);
    }
  }

  void updateQuantity(int itemId, int delta) {
    final updatedCart = state.cart.map((i) {
      if (i.item.id == itemId) {
        final newQty = i.quantity + delta;
        return i.copyWith(quantity: newQty < 1 ? 1 : newQty);
      }
      return i;
    }).toList();
    state = state.copyWith(cart: updatedCart);
  }

  void removeFromCart(int itemId) {
    state = state.copyWith(cart: state.cart.where((i) => i.item.id != itemId).toList());
  }

  void setCustomPrice(int itemId, double? price) {
    final updatedCart = state.cart.map((i) {
      if (i.item.id == itemId) return i.copyWith(customPrice: price);
      return i;
    }).toList();
    state = state.copyWith(cart: updatedCart);
  }

  void setDiscount(double discount) => state = state.copyWith(discount: discount);
  void setNote(String note) => state = state.copyWith(note: note);
  void setTransactionType(String type) => state = state.copyWith(transactionType: type);
  void setPaymentType(String type) => state = state.copyWith(paymentType: type);
  void setPaymentAmount(double amount) => state = state.copyWith(paymentAmount: amount);

  void reset() {
    state = TransaksiState();
  }

  /// Checkout with automatic offline fallback.
  /// If the API call fails due to connectivity, the transaction is saved locally
  /// and will auto-sync when connection is restored.
  Future<bool> checkout() async {
    state = state.copyWith(isSubmitting: true);
    try {
      final dio = ref.read(dioProvider);
      final input = CreateTransactionInput(
        id: state.currentDraftId,
        status: 'completed',
        paymentAmount: state.paymentAmount,
        paymentType: state.paymentType,
        note: state.note,
        transactionType: state.transactionType,
        discount: state.discount,
        items: state.cart.map((i) => TransactionItemInput(
          itemId: i.item.id,
          quantity: i.quantity,
          customPrice: i.customPrice,
        )).toList(),
      );

      await dio.post('/transactions/', data: input.toJson());
      reset();
      return true;
    } on DioException catch (e) {
      // If it's a connection error, save offline
      if (_isConnectionError(e)) {
        return _saveOffline();
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  /// Check if Dio error is a connectivity issue
  bool _isConnectionError(DioException e) {
    return e.type == DioExceptionType.connectionError ||
           e.type == DioExceptionType.connectionTimeout ||
           e.type == DioExceptionType.sendTimeout ||
           e.type == DioExceptionType.receiveTimeout;
  }

  /// Save the current cart as an offline pending transaction
  Future<bool> _saveOffline() async {
    try {
      final syncService = ref.read(offlineSyncServiceProvider);

      final items = state.cart.map((cartItem) => {
        'item_id': cartItem.item.id,
        'item_name': cartItem.item.name,
        'quantity': cartItem.quantity,
        'price': cartItem.currentPrice,
        'custom_price': cartItem.customPrice,
        'subtotal': cartItem.subtotal,
      }).toList();

      await syncService.saveOfflineTransaction(
        status: 'completed',
        total: state.finalTotal,
        discount: state.discount,
        paymentAmount: state.paymentAmount,
        paymentType: state.paymentType,
        transactionType: state.transactionType,
        note: state.note,
        items: items,
      );

      state = state.copyWith(lastCheckoutWasOffline: true);
      reset();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Manually trigger sync of pending transactions
  Future<SyncResult> syncNow() async {
    final syncService = ref.read(offlineSyncServiceProvider);
    return syncService.syncPendingTransactions();
  }

  Future<bool> saveDraft() async {
    state = state.copyWith(isSubmitting: true);
    try {
      final dio = ref.read(dioProvider);
      final input = CreateTransactionInput(
        id: state.currentDraftId,
        status: 'draft',
        note: state.note,
        transactionType: state.transactionType,
        discount: state.discount,
        items: state.cart.map((i) => TransactionItemInput(
          itemId: i.item.id,
          quantity: i.quantity,
          customPrice: i.customPrice,
        )).toList(),
      );

      await dio.post('/transactions/', data: input.toJson());
      reset();
      return true;
    } catch (e) {
      return false;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  void loadDraft(Map<String, dynamic> draft) {
    reset();
    final itemsList = draft['items'] as List<dynamic>;
    final List<CartItem> loadedCart = [];

    for (final itemData in itemsList) {
      final itemObj = itemData['item'] as Map<String, dynamic>;
      final itemModel = ItemModel(
        id: itemObj['id'] as int,
        name: itemObj['name'] as String,
        description: itemObj['description'] as String?,
        stock: itemObj['stock'] as int? ?? 0,
        isStockManaged: itemObj['is_stock_managed'] as bool? ?? true,
        buyPrice: (itemObj['buy_price'] as num).toDouble(),
        price: (itemObj['price'] as num).toDouble(),
        imageUrl: itemObj['image_url'] as String?,
      );

      final double originalPrice = (itemData['price'] as num).toDouble();
      // If the checkout/draft price is different from actual item price, it's a custom price!
      final double? customPrice = originalPrice != itemModel.price ? originalPrice : null;

      loadedCart.add(CartItem(
        item: itemModel,
        quantity: itemData['quantity'] as int? ?? 1,
        customPrice: customPrice,
      ));
    }

    state = state.copyWith(
      currentDraftId: draft['id'] as int?,
      cart: loadedCart,
      discount: (draft['discount'] as num?)?.toDouble() ?? 0.0,
      note: draft['note'] as String?,
      transactionType: draft['transaction_type'] as String? ?? 'onsite',
    );
  }

  Future<bool> deleteDraft(int id) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/transactions/$id');
      ref.invalidate(draftsProvider);
      return true;
    } catch (e) {
      return false;
    }
  }
}

final transaksiProvider = StateNotifierProvider<TransaksiNotifier, TransaksiState>((ref) {
  return TransaksiNotifier(ref);
});

final draftsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/transactions/drafts');
  return response.data as List<dynamic>;
});
