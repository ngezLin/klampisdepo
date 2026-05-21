// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ItemModel _$ItemModelFromJson(Map<String, dynamic> json) {
  return _ItemModel.fromJson(json);
}

/// @nodoc
mixin _$ItemModel {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get stock => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_stock_managed')
  bool get isStockManaged => throw _privateConstructorUsedError;
  @JsonKey(name: 'buy_price')
  double get buyPrice => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;

  /// Serializes this ItemModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ItemModelCopyWith<ItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItemModelCopyWith<$Res> {
  factory $ItemModelCopyWith(ItemModel value, $Res Function(ItemModel) then) =
      _$ItemModelCopyWithImpl<$Res, ItemModel>;
  @useResult
  $Res call(
      {int id,
      String name,
      String? description,
      int stock,
      @JsonKey(name: 'is_stock_managed') bool isStockManaged,
      @JsonKey(name: 'buy_price') double buyPrice,
      double price,
      @JsonKey(name: 'image_url') String? imageUrl});
}

/// @nodoc
class _$ItemModelCopyWithImpl<$Res, $Val extends ItemModel>
    implements $ItemModelCopyWith<$Res> {
  _$ItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? stock = null,
    Object? isStockManaged = null,
    Object? buyPrice = null,
    Object? price = null,
    Object? imageUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      stock: null == stock
          ? _value.stock
          : stock // ignore: cast_nullable_to_non_nullable
              as int,
      isStockManaged: null == isStockManaged
          ? _value.isStockManaged
          : isStockManaged // ignore: cast_nullable_to_non_nullable
              as bool,
      buyPrice: null == buyPrice
          ? _value.buyPrice
          : buyPrice // ignore: cast_nullable_to_non_nullable
              as double,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ItemModelImplCopyWith<$Res>
    implements $ItemModelCopyWith<$Res> {
  factory _$$ItemModelImplCopyWith(
          _$ItemModelImpl value, $Res Function(_$ItemModelImpl) then) =
      __$$ItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String? description,
      int stock,
      @JsonKey(name: 'is_stock_managed') bool isStockManaged,
      @JsonKey(name: 'buy_price') double buyPrice,
      double price,
      @JsonKey(name: 'image_url') String? imageUrl});
}

/// @nodoc
class __$$ItemModelImplCopyWithImpl<$Res>
    extends _$ItemModelCopyWithImpl<$Res, _$ItemModelImpl>
    implements _$$ItemModelImplCopyWith<$Res> {
  __$$ItemModelImplCopyWithImpl(
      _$ItemModelImpl _value, $Res Function(_$ItemModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? stock = null,
    Object? isStockManaged = null,
    Object? buyPrice = null,
    Object? price = null,
    Object? imageUrl = freezed,
  }) {
    return _then(_$ItemModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      stock: null == stock
          ? _value.stock
          : stock // ignore: cast_nullable_to_non_nullable
              as int,
      isStockManaged: null == isStockManaged
          ? _value.isStockManaged
          : isStockManaged // ignore: cast_nullable_to_non_nullable
              as bool,
      buyPrice: null == buyPrice
          ? _value.buyPrice
          : buyPrice // ignore: cast_nullable_to_non_nullable
              as double,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ItemModelImpl implements _ItemModel {
  const _$ItemModelImpl(
      {required this.id,
      required this.name,
      this.description,
      this.stock = 0,
      @JsonKey(name: 'is_stock_managed') this.isStockManaged = true,
      @JsonKey(name: 'buy_price') required this.buyPrice,
      required this.price,
      @JsonKey(name: 'image_url') this.imageUrl});

  factory _$ItemModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ItemModelImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey()
  final int stock;
  @override
  @JsonKey(name: 'is_stock_managed')
  final bool isStockManaged;
  @override
  @JsonKey(name: 'buy_price')
  final double buyPrice;
  @override
  final double price;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  @override
  String toString() {
    return 'ItemModel(id: $id, name: $name, description: $description, stock: $stock, isStockManaged: $isStockManaged, buyPrice: $buyPrice, price: $price, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItemModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.stock, stock) || other.stock == stock) &&
            (identical(other.isStockManaged, isStockManaged) ||
                other.isStockManaged == isStockManaged) &&
            (identical(other.buyPrice, buyPrice) ||
                other.buyPrice == buyPrice) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, description, stock,
      isStockManaged, buyPrice, price, imageUrl);

  /// Create a copy of ItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ItemModelImplCopyWith<_$ItemModelImpl> get copyWith =>
      __$$ItemModelImplCopyWithImpl<_$ItemModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ItemModelImplToJson(
      this,
    );
  }
}

abstract class _ItemModel implements ItemModel {
  const factory _ItemModel(
      {required final int id,
      required final String name,
      final String? description,
      final int stock,
      @JsonKey(name: 'is_stock_managed') final bool isStockManaged,
      @JsonKey(name: 'buy_price') required final double buyPrice,
      required final double price,
      @JsonKey(name: 'image_url') final String? imageUrl}) = _$ItemModelImpl;

  factory _ItemModel.fromJson(Map<String, dynamic> json) =
      _$ItemModelImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  int get stock;
  @override
  @JsonKey(name: 'is_stock_managed')
  bool get isStockManaged;
  @override
  @JsonKey(name: 'buy_price')
  double get buyPrice;
  @override
  double get price;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;

  /// Create a copy of ItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ItemModelImplCopyWith<_$ItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CartItem {
  ItemModel get item => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double? get customPrice => throw _privateConstructorUsedError;

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CartItemCopyWith<CartItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartItemCopyWith<$Res> {
  factory $CartItemCopyWith(CartItem value, $Res Function(CartItem) then) =
      _$CartItemCopyWithImpl<$Res, CartItem>;
  @useResult
  $Res call({ItemModel item, int quantity, double? customPrice});

  $ItemModelCopyWith<$Res> get item;
}

/// @nodoc
class _$CartItemCopyWithImpl<$Res, $Val extends CartItem>
    implements $CartItemCopyWith<$Res> {
  _$CartItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? item = null,
    Object? quantity = null,
    Object? customPrice = freezed,
  }) {
    return _then(_value.copyWith(
      item: null == item
          ? _value.item
          : item // ignore: cast_nullable_to_non_nullable
              as ItemModel,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      customPrice: freezed == customPrice
          ? _value.customPrice
          : customPrice // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ItemModelCopyWith<$Res> get item {
    return $ItemModelCopyWith<$Res>(_value.item, (value) {
      return _then(_value.copyWith(item: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CartItemImplCopyWith<$Res>
    implements $CartItemCopyWith<$Res> {
  factory _$$CartItemImplCopyWith(
          _$CartItemImpl value, $Res Function(_$CartItemImpl) then) =
      __$$CartItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ItemModel item, int quantity, double? customPrice});

  @override
  $ItemModelCopyWith<$Res> get item;
}

/// @nodoc
class __$$CartItemImplCopyWithImpl<$Res>
    extends _$CartItemCopyWithImpl<$Res, _$CartItemImpl>
    implements _$$CartItemImplCopyWith<$Res> {
  __$$CartItemImplCopyWithImpl(
      _$CartItemImpl _value, $Res Function(_$CartItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? item = null,
    Object? quantity = null,
    Object? customPrice = freezed,
  }) {
    return _then(_$CartItemImpl(
      item: null == item
          ? _value.item
          : item // ignore: cast_nullable_to_non_nullable
              as ItemModel,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      customPrice: freezed == customPrice
          ? _value.customPrice
          : customPrice // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc

class _$CartItemImpl extends _CartItem {
  const _$CartItemImpl(
      {required this.item, this.quantity = 1, this.customPrice})
      : super._();

  @override
  final ItemModel item;
  @override
  @JsonKey()
  final int quantity;
  @override
  final double? customPrice;

  @override
  String toString() {
    return 'CartItem(item: $item, quantity: $quantity, customPrice: $customPrice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartItemImpl &&
            (identical(other.item, item) || other.item == item) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.customPrice, customPrice) ||
                other.customPrice == customPrice));
  }

  @override
  int get hashCode => Object.hash(runtimeType, item, quantity, customPrice);

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CartItemImplCopyWith<_$CartItemImpl> get copyWith =>
      __$$CartItemImplCopyWithImpl<_$CartItemImpl>(this, _$identity);
}

abstract class _CartItem extends CartItem {
  const factory _CartItem(
      {required final ItemModel item,
      final int quantity,
      final double? customPrice}) = _$CartItemImpl;
  const _CartItem._() : super._();

  @override
  ItemModel get item;
  @override
  int get quantity;
  @override
  double? get customPrice;

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CartItemImplCopyWith<_$CartItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TransactionItemInput _$TransactionItemInputFromJson(Map<String, dynamic> json) {
  return _TransactionItemInput.fromJson(json);
}

/// @nodoc
mixin _$TransactionItemInput {
  @JsonKey(name: 'item_id')
  int get itemId => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double? get customPrice => throw _privateConstructorUsedError;

  /// Serializes this TransactionItemInput to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TransactionItemInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransactionItemInputCopyWith<TransactionItemInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionItemInputCopyWith<$Res> {
  factory $TransactionItemInputCopyWith(TransactionItemInput value,
          $Res Function(TransactionItemInput) then) =
      _$TransactionItemInputCopyWithImpl<$Res, TransactionItemInput>;
  @useResult
  $Res call(
      {@JsonKey(name: 'item_id') int itemId,
      int quantity,
      double? customPrice});
}

/// @nodoc
class _$TransactionItemInputCopyWithImpl<$Res,
        $Val extends TransactionItemInput>
    implements $TransactionItemInputCopyWith<$Res> {
  _$TransactionItemInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TransactionItemInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemId = null,
    Object? quantity = null,
    Object? customPrice = freezed,
  }) {
    return _then(_value.copyWith(
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as int,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      customPrice: freezed == customPrice
          ? _value.customPrice
          : customPrice // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TransactionItemInputImplCopyWith<$Res>
    implements $TransactionItemInputCopyWith<$Res> {
  factory _$$TransactionItemInputImplCopyWith(_$TransactionItemInputImpl value,
          $Res Function(_$TransactionItemInputImpl) then) =
      __$$TransactionItemInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'item_id') int itemId,
      int quantity,
      double? customPrice});
}

/// @nodoc
class __$$TransactionItemInputImplCopyWithImpl<$Res>
    extends _$TransactionItemInputCopyWithImpl<$Res, _$TransactionItemInputImpl>
    implements _$$TransactionItemInputImplCopyWith<$Res> {
  __$$TransactionItemInputImplCopyWithImpl(_$TransactionItemInputImpl _value,
      $Res Function(_$TransactionItemInputImpl) _then)
      : super(_value, _then);

  /// Create a copy of TransactionItemInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemId = null,
    Object? quantity = null,
    Object? customPrice = freezed,
  }) {
    return _then(_$TransactionItemInputImpl(
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as int,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      customPrice: freezed == customPrice
          ? _value.customPrice
          : customPrice // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TransactionItemInputImpl implements _TransactionItemInput {
  const _$TransactionItemInputImpl(
      {@JsonKey(name: 'item_id') required this.itemId,
      required this.quantity,
      this.customPrice});

  factory _$TransactionItemInputImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionItemInputImplFromJson(json);

  @override
  @JsonKey(name: 'item_id')
  final int itemId;
  @override
  final int quantity;
  @override
  final double? customPrice;

  @override
  String toString() {
    return 'TransactionItemInput(itemId: $itemId, quantity: $quantity, customPrice: $customPrice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionItemInputImpl &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.customPrice, customPrice) ||
                other.customPrice == customPrice));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, itemId, quantity, customPrice);

  /// Create a copy of TransactionItemInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionItemInputImplCopyWith<_$TransactionItemInputImpl>
      get copyWith =>
          __$$TransactionItemInputImplCopyWithImpl<_$TransactionItemInputImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionItemInputImplToJson(
      this,
    );
  }
}

abstract class _TransactionItemInput implements TransactionItemInput {
  const factory _TransactionItemInput(
      {@JsonKey(name: 'item_id') required final int itemId,
      required final int quantity,
      final double? customPrice}) = _$TransactionItemInputImpl;

  factory _TransactionItemInput.fromJson(Map<String, dynamic> json) =
      _$TransactionItemInputImpl.fromJson;

  @override
  @JsonKey(name: 'item_id')
  int get itemId;
  @override
  int get quantity;
  @override
  double? get customPrice;

  /// Create a copy of TransactionItemInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransactionItemInputImplCopyWith<_$TransactionItemInputImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CreateTransactionInput _$CreateTransactionInputFromJson(
    Map<String, dynamic> json) {
  return _CreateTransactionInput.fromJson(json);
}

/// @nodoc
mixin _$CreateTransactionInput {
  int? get id => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  double? get paymentAmount => throw _privateConstructorUsedError;
  String? get paymentType => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_type')
  String? get transactionType => throw _privateConstructorUsedError;
  double? get discount => throw _privateConstructorUsedError;
  List<TransactionItemInput> get items => throw _privateConstructorUsedError;

  /// Serializes this CreateTransactionInput to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateTransactionInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateTransactionInputCopyWith<CreateTransactionInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateTransactionInputCopyWith<$Res> {
  factory $CreateTransactionInputCopyWith(CreateTransactionInput value,
          $Res Function(CreateTransactionInput) then) =
      _$CreateTransactionInputCopyWithImpl<$Res, CreateTransactionInput>;
  @useResult
  $Res call(
      {int? id,
      String status,
      double? paymentAmount,
      String? paymentType,
      String? note,
      @JsonKey(name: 'transaction_type') String? transactionType,
      double? discount,
      List<TransactionItemInput> items});
}

/// @nodoc
class _$CreateTransactionInputCopyWithImpl<$Res,
        $Val extends CreateTransactionInput>
    implements $CreateTransactionInputCopyWith<$Res> {
  _$CreateTransactionInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateTransactionInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? status = null,
    Object? paymentAmount = freezed,
    Object? paymentType = freezed,
    Object? note = freezed,
    Object? transactionType = freezed,
    Object? discount = freezed,
    Object? items = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      paymentAmount: freezed == paymentAmount
          ? _value.paymentAmount
          : paymentAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      paymentType: freezed == paymentType
          ? _value.paymentType
          : paymentType // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionType: freezed == transactionType
          ? _value.transactionType
          : transactionType // ignore: cast_nullable_to_non_nullable
              as String?,
      discount: freezed == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double?,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<TransactionItemInput>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateTransactionInputImplCopyWith<$Res>
    implements $CreateTransactionInputCopyWith<$Res> {
  factory _$$CreateTransactionInputImplCopyWith(
          _$CreateTransactionInputImpl value,
          $Res Function(_$CreateTransactionInputImpl) then) =
      __$$CreateTransactionInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String status,
      double? paymentAmount,
      String? paymentType,
      String? note,
      @JsonKey(name: 'transaction_type') String? transactionType,
      double? discount,
      List<TransactionItemInput> items});
}

/// @nodoc
class __$$CreateTransactionInputImplCopyWithImpl<$Res>
    extends _$CreateTransactionInputCopyWithImpl<$Res,
        _$CreateTransactionInputImpl>
    implements _$$CreateTransactionInputImplCopyWith<$Res> {
  __$$CreateTransactionInputImplCopyWithImpl(
      _$CreateTransactionInputImpl _value,
      $Res Function(_$CreateTransactionInputImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateTransactionInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? status = null,
    Object? paymentAmount = freezed,
    Object? paymentType = freezed,
    Object? note = freezed,
    Object? transactionType = freezed,
    Object? discount = freezed,
    Object? items = null,
  }) {
    return _then(_$CreateTransactionInputImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      paymentAmount: freezed == paymentAmount
          ? _value.paymentAmount
          : paymentAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      paymentType: freezed == paymentType
          ? _value.paymentType
          : paymentType // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionType: freezed == transactionType
          ? _value.transactionType
          : transactionType // ignore: cast_nullable_to_non_nullable
              as String?,
      discount: freezed == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as double?,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<TransactionItemInput>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateTransactionInputImpl implements _CreateTransactionInput {
  const _$CreateTransactionInputImpl(
      {this.id,
      required this.status,
      this.paymentAmount,
      this.paymentType,
      this.note,
      @JsonKey(name: 'transaction_type') this.transactionType,
      this.discount,
      required final List<TransactionItemInput> items})
      : _items = items;

  factory _$CreateTransactionInputImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateTransactionInputImplFromJson(json);

  @override
  final int? id;
  @override
  final String status;
  @override
  final double? paymentAmount;
  @override
  final String? paymentType;
  @override
  final String? note;
  @override
  @JsonKey(name: 'transaction_type')
  final String? transactionType;
  @override
  final double? discount;
  final List<TransactionItemInput> _items;
  @override
  List<TransactionItemInput> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'CreateTransactionInput(id: $id, status: $status, paymentAmount: $paymentAmount, paymentType: $paymentType, note: $note, transactionType: $transactionType, discount: $discount, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateTransactionInputImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paymentAmount, paymentAmount) ||
                other.paymentAmount == paymentAmount) &&
            (identical(other.paymentType, paymentType) ||
                other.paymentType == paymentType) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.transactionType, transactionType) ||
                other.transactionType == transactionType) &&
            (identical(other.discount, discount) ||
                other.discount == discount) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      status,
      paymentAmount,
      paymentType,
      note,
      transactionType,
      discount,
      const DeepCollectionEquality().hash(_items));

  /// Create a copy of CreateTransactionInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateTransactionInputImplCopyWith<_$CreateTransactionInputImpl>
      get copyWith => __$$CreateTransactionInputImplCopyWithImpl<
          _$CreateTransactionInputImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateTransactionInputImplToJson(
      this,
    );
  }
}

abstract class _CreateTransactionInput implements CreateTransactionInput {
  const factory _CreateTransactionInput(
          {final int? id,
          required final String status,
          final double? paymentAmount,
          final String? paymentType,
          final String? note,
          @JsonKey(name: 'transaction_type') final String? transactionType,
          final double? discount,
          required final List<TransactionItemInput> items}) =
      _$CreateTransactionInputImpl;

  factory _CreateTransactionInput.fromJson(Map<String, dynamic> json) =
      _$CreateTransactionInputImpl.fromJson;

  @override
  int? get id;
  @override
  String get status;
  @override
  double? get paymentAmount;
  @override
  String? get paymentType;
  @override
  String? get note;
  @override
  @JsonKey(name: 'transaction_type')
  String? get transactionType;
  @override
  double? get discount;
  @override
  List<TransactionItemInput> get items;

  /// Create a copy of CreateTransactionInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateTransactionInputImplCopyWith<_$CreateTransactionInputImpl>
      get copyWith => throw _privateConstructorUsedError;
}
