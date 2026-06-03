import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_models.freezed.dart';
part 'transaction_models.g.dart';

@freezed
class ItemModel with _$ItemModel {
  const factory ItemModel({
    required int id,
    required String name,
    String? description,
    @Default(0) int stock,
    @JsonKey(name: 'is_stock_managed') @Default(true) bool isStockManaged,
    @JsonKey(name: 'buy_price') double? buyPrice,
    required double price,
    @JsonKey(name: 'image_url') String? imageUrl,
  }) = _ItemModel;

  factory ItemModel.fromJson(Map<String, dynamic> json) => _$ItemModelFromJson(json);
}

@freezed
class CartItem with _$CartItem {
  const factory CartItem({
    required ItemModel item,
    @Default(1) int quantity,
    double? customPrice,
  }) = _CartItem;

  const CartItem._();

  double get currentPrice => customPrice ?? item.price;
  double get subtotal => quantity * currentPrice;
}

@freezed
class TransactionItemInput with _$TransactionItemInput {
  const factory TransactionItemInput({
    @JsonKey(name: 'item_id') required int itemId,
    required int quantity,
    double? customPrice,
  }) = _TransactionItemInput;

  factory TransactionItemInput.fromJson(Map<String, dynamic> json) => _$TransactionItemInputFromJson(json);
}

@freezed
class CreateTransactionInput with _$CreateTransactionInput {
  const factory CreateTransactionInput({
    int? id,
    required String status,
    double? paymentAmount,
    String? paymentType,
    String? note,
    @JsonKey(name: 'transaction_type') String? transactionType,
    double? discount,
    required List<TransactionItemInput> items,
  }) = _CreateTransactionInput;

  factory CreateTransactionInput.fromJson(Map<String, dynamic> json) => _$CreateTransactionInputFromJson(json);
}

class CheckoutResult {
  final bool success;
  final int? transactionId;
  final bool wasOffline;
  final Map<String, dynamic>? transactionData;

  CheckoutResult({
    required this.success,
    this.transactionId,
    this.wasOffline = false,
    this.transactionData,
  });
}
