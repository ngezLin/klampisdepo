import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_models.dart';
import '../../../core/network/dio_client.dart';
import '../../../services/sync/offline_sync_service.dart';

class TransactionState {
  final List<CartItem> cart;
  final double discount;
  final String? note;
  final String transactionType;
  final String paymentType;
  final double paymentAmount;
  final int? currentDraftId;
  final bool isSubmitting;
  final bool lastCheckoutWasOffline; // Notify UI that checkout was saved offline
  final String? idempotencyKey;

  TransactionState({
    this.cart = const [],
    this.discount = 0,
    this.note,
    this.transactionType = 'onsite',
    this.paymentType = 'cash',
    this.paymentAmount = 0,
    this.currentDraftId,
    this.isSubmitting = false,
    this.lastCheckoutWasOffline = false,
    this.idempotencyKey,
  });

  double get totalBeforeDiscount => cart.fold(0, (sum, item) => sum + item.subtotal);
  double get finalTotal => totalBeforeDiscount - discount;
  double get change => paymentAmount - finalTotal;

  TransactionState copyWith({
    List<CartItem>? cart,
    double? discount,
    String? note,
    String? transactionType,
    String? paymentType,
    double? paymentAmount,
    int? currentDraftId,
    bool? isSubmitting,
    bool? lastCheckoutWasOffline,
    String? idempotencyKey,
  }) {
    final hasChanges = cart != null ||
        discount != null ||
        note != null ||
        transactionType != null ||
        paymentType != null ||
        paymentAmount != null ||
        currentDraftId != null;

    return TransactionState(
      cart: cart ?? this.cart,
      discount: discount ?? this.discount,
      note: note ?? this.note,
      transactionType: transactionType ?? this.transactionType,
      paymentType: paymentType ?? this.paymentType,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      currentDraftId: currentDraftId ?? this.currentDraftId,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      lastCheckoutWasOffline: lastCheckoutWasOffline ?? false,
      idempotencyKey: idempotencyKey ?? (hasChanges ? null : this.idempotencyKey),
    );
  }
}

class TransactionNotifier extends StateNotifier<TransactionState> {
  final Ref ref;

  TransactionNotifier(this.ref) : super(TransactionState());

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
        final newQty = max(0, i.quantity + delta);
        return i.copyWith(quantity: newQty);
      }
      return i;
    }).toList();
    state = state.copyWith(cart: updatedCart.where((i) => i.quantity > 0).toList());
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
    state = TransactionState();
  }

  String _generateIdempotencyKey() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    values[6] = (values[6] & 0x0f) | 0x40; // v4
    values[8] = (values[8] & 0x3f) | 0x80; // variant
    final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).toList();
    return '${hex.sublist(0, 4).join()}-${hex.sublist(4, 6).join()}-${hex.sublist(6, 8).join()}-${hex.sublist(8, 10).join()}-${hex.sublist(10, 16).join()}';
  }

  /// Checkout with automatic offline fallback.
  /// If the API call fails due to connectivity, the transaction is saved locally
  /// and will auto-sync when connection is restored.
  Future<CheckoutResult> checkout() async {
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

      String? key = state.idempotencyKey;
      if (key == null) {
        key = _generateIdempotencyKey();
        state = state.copyWith(idempotencyKey: key);
      }

      final response = await dio.post(
        '/transactions/',
        data: input.toJson(),
        options: Options(
          headers: {
            'X-Idempotency-Key': key,
          },
        ),
      );
      final serverTx = response.data['transaction'] as Map<String, dynamic>;
      final int serverId = serverTx['id'] as int;
      final result = CheckoutResult(success: true, transactionId: serverId, wasOffline: false, transactionData: serverTx);
      reset();
      return result;
    } on DioException catch (e) {
      if (_isConnectionError(e)) {
        return _saveOffline();
      }
      String message = 'Terjadi kesalahan pada server';
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('error')) {
          message = data['error'].toString();
        } else if (e.response?.statusCode == 401) {
          message = 'Sesi telah berakhir, silakan login kembali.';
        } else if (e.response?.statusCode == 422) {
          message = 'Validasi transaksi gagal (stok tidak cukup atau data salah).';
        }
      }
      return CheckoutResult(success: false, errorMessage: message);
    } catch (e) {
      return CheckoutResult(success: false, errorMessage: e.toString());
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
  Future<CheckoutResult> _saveOffline() async {
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

      final txId = await syncService.saveOfflineTransaction(
        status: 'completed',
        total: state.finalTotal,
        discount: state.discount,
        paymentAmount: state.paymentAmount,
        paymentType: state.paymentType,
        transactionType: state.transactionType,
        note: state.note,
        items: items,
      );

      final txData = {
        'id': txId,
        'created_at': DateTime.now().toIso8601String(),
        'items': items,
        'subtotal': state.totalBeforeDiscount,
        'discount': state.discount,
        'total': state.finalTotal,
        'payment_type': state.paymentType,
        'payment': state.paymentAmount,
        'change': state.change,
        'note': state.note,
        'syncStatus': 'pending_sync',
      };

      final result = CheckoutResult(
        success: true,
        transactionId: txId,
        wasOffline: true,
        transactionData: txData,
      );

      state = state.copyWith(lastCheckoutWasOffline: true);
      reset();
      return result;
    } catch (e) {
      return CheckoutResult(success: false, errorMessage: 'Gagal menyimpan transaksi offline: $e');
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

final transactionProvider = StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
  return TransactionNotifier(ref);
});

final draftsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/transactions/drafts');
  return response.data as List<dynamic>;
});
