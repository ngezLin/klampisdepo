// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ItemModelImpl _$$ItemModelImplFromJson(Map<String, dynamic> json) =>
    _$ItemModelImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      isStockManaged: json['is_stock_managed'] as bool? ?? true,
      buyPrice: (json['buy_price'] as num?)?.toDouble(),
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
    );

Map<String, dynamic> _$$ItemModelImplToJson(_$ItemModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'stock': instance.stock,
      'is_stock_managed': instance.isStockManaged,
      'buy_price': instance.buyPrice,
      'price': instance.price,
      'image_url': instance.imageUrl,
    };

_$TransactionItemInputImpl _$$TransactionItemInputImplFromJson(
        Map<String, dynamic> json) =>
    _$TransactionItemInputImpl(
      itemId: (json['item_id'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      customPrice: (json['customPrice'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$TransactionItemInputImplToJson(
        _$TransactionItemInputImpl instance) =>
    <String, dynamic>{
      'item_id': instance.itemId,
      'quantity': instance.quantity,
      'customPrice': instance.customPrice,
    };

_$CreateTransactionInputImpl _$$CreateTransactionInputImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateTransactionInputImpl(
      id: (json['id'] as num?)?.toInt(),
      status: json['status'] as String,
      paymentAmount: (json['paymentAmount'] as num?)?.toDouble(),
      paymentType: json['paymentType'] as String?,
      note: json['note'] as String?,
      transactionType: json['transaction_type'] as String?,
      discount: (json['discount'] as num?)?.toDouble(),
      items: (json['items'] as List<dynamic>)
          .map((e) => TransactionItemInput.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$CreateTransactionInputImplToJson(
        _$CreateTransactionInputImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'paymentAmount': instance.paymentAmount,
      'paymentType': instance.paymentType,
      'note': instance.note,
      'transaction_type': instance.transactionType,
      'discount': instance.discount,
      'items': instance.items,
    };
