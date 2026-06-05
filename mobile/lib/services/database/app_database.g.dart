// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ItemsTable extends Items with TableInfo<$ItemsTable, Item> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<int> stock = GeneratedColumn<int>(
      'stock', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isStockManagedMeta =
      const VerificationMeta('isStockManaged');
  @override
  late final GeneratedColumn<bool> isStockManaged = GeneratedColumn<bool>(
      'is_stock_managed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_stock_managed" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _buyPriceMeta =
      const VerificationMeta('buyPrice');
  @override
  late final GeneratedColumn<double> buyPrice = GeneratedColumn<double>(
      'buy_price', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        stock,
        isStockManaged,
        buyPrice,
        price,
        imageUrl,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(Insertable<Item> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('stock')) {
      context.handle(
          _stockMeta, stock.isAcceptableOrUnknown(data['stock']!, _stockMeta));
    }
    if (data.containsKey('is_stock_managed')) {
      context.handle(
          _isStockManagedMeta,
          isStockManaged.isAcceptableOrUnknown(
              data['is_stock_managed']!, _isStockManagedMeta));
    }
    if (data.containsKey('buy_price')) {
      context.handle(_buyPriceMeta,
          buyPrice.isAcceptableOrUnknown(data['buy_price']!, _buyPriceMeta));
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Item map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Item(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      stock: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stock'])!,
      isStockManaged: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_stock_managed'])!,
      buyPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}buy_price']),
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price'])!,
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class Item extends DataClass implements Insertable<Item> {
  final int id;
  final String name;
  final String? description;
  final int stock;
  final bool isStockManaged;
  final double? buyPrice;
  final double price;
  final String? imageUrl;
  final DateTime updatedAt;
  const Item(
      {required this.id,
      required this.name,
      this.description,
      required this.stock,
      required this.isStockManaged,
      this.buyPrice,
      required this.price,
      this.imageUrl,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['stock'] = Variable<int>(stock);
    map['is_stock_managed'] = Variable<bool>(isStockManaged);
    if (!nullToAbsent || buyPrice != null) {
      map['buy_price'] = Variable<double>(buyPrice);
    }
    map['price'] = Variable<double>(price);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      stock: Value(stock),
      isStockManaged: Value(isStockManaged),
      buyPrice: buyPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(buyPrice),
      price: Value(price),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      updatedAt: Value(updatedAt),
    );
  }

  factory Item.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Item(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      stock: serializer.fromJson<int>(json['stock']),
      isStockManaged: serializer.fromJson<bool>(json['isStockManaged']),
      buyPrice: serializer.fromJson<double?>(json['buyPrice']),
      price: serializer.fromJson<double>(json['price']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'stock': serializer.toJson<int>(stock),
      'isStockManaged': serializer.toJson<bool>(isStockManaged),
      'buyPrice': serializer.toJson<double?>(buyPrice),
      'price': serializer.toJson<double>(price),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Item copyWith(
          {int? id,
          String? name,
          Value<String?> description = const Value.absent(),
          int? stock,
          bool? isStockManaged,
          Value<double?> buyPrice = const Value.absent(),
          double? price,
          Value<String?> imageUrl = const Value.absent(),
          DateTime? updatedAt}) =>
      Item(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        stock: stock ?? this.stock,
        isStockManaged: isStockManaged ?? this.isStockManaged,
        buyPrice: buyPrice.present ? buyPrice.value : this.buyPrice,
        price: price ?? this.price,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Item copyWithCompanion(ItemsCompanion data) {
    return Item(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      stock: data.stock.present ? data.stock.value : this.stock,
      isStockManaged: data.isStockManaged.present
          ? data.isStockManaged.value
          : this.isStockManaged,
      buyPrice: data.buyPrice.present ? data.buyPrice.value : this.buyPrice,
      price: data.price.present ? data.price.value : this.price,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Item(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('stock: $stock, ')
          ..write('isStockManaged: $isStockManaged, ')
          ..write('buyPrice: $buyPrice, ')
          ..write('price: $price, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, stock, isStockManaged,
      buyPrice, price, imageUrl, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Item &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.stock == this.stock &&
          other.isStockManaged == this.isStockManaged &&
          other.buyPrice == this.buyPrice &&
          other.price == this.price &&
          other.imageUrl == this.imageUrl &&
          other.updatedAt == this.updatedAt);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<int> stock;
  final Value<bool> isStockManaged;
  final Value<double?> buyPrice;
  final Value<double> price;
  final Value<String?> imageUrl;
  final Value<DateTime> updatedAt;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.stock = const Value.absent(),
    this.isStockManaged = const Value.absent(),
    this.buyPrice = const Value.absent(),
    this.price = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ItemsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.stock = const Value.absent(),
    this.isStockManaged = const Value.absent(),
    this.buyPrice = const Value.absent(),
    required double price,
    this.imageUrl = const Value.absent(),
    required DateTime updatedAt,
  })  : name = Value(name),
        price = Value(price),
        updatedAt = Value(updatedAt);
  static Insertable<Item> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? stock,
    Expression<bool>? isStockManaged,
    Expression<double>? buyPrice,
    Expression<double>? price,
    Expression<String>? imageUrl,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (stock != null) 'stock': stock,
      if (isStockManaged != null) 'is_stock_managed': isStockManaged,
      if (buyPrice != null) 'buy_price': buyPrice,
      if (price != null) 'price': price,
      if (imageUrl != null) 'image_url': imageUrl,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<int>? stock,
      Value<bool>? isStockManaged,
      Value<double?>? buyPrice,
      Value<double>? price,
      Value<String?>? imageUrl,
      Value<DateTime>? updatedAt}) {
    return ItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      stock: stock ?? this.stock,
      isStockManaged: isStockManaged ?? this.isStockManaged,
      buyPrice: buyPrice ?? this.buyPrice,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (stock.present) {
      map['stock'] = Variable<int>(stock.value);
    }
    if (isStockManaged.present) {
      map['is_stock_managed'] = Variable<bool>(isStockManaged.value);
    }
    if (buyPrice.present) {
      map['buy_price'] = Variable<double>(buyPrice.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('stock: $stock, ')
          ..write('isStockManaged: $isStockManaged, ')
          ..write('buyPrice: $buyPrice, ')
          ..write('price: $price, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
      'server_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
      'total', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _discountMeta =
      const VerificationMeta('discount');
  @override
  late final GeneratedColumn<double> discount = GeneratedColumn<double>(
      'discount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _paymentAmountMeta =
      const VerificationMeta('paymentAmount');
  @override
  late final GeneratedColumn<double> paymentAmount = GeneratedColumn<double>(
      'payment_amount', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _paymentTypeMeta =
      const VerificationMeta('paymentType');
  @override
  late final GeneratedColumn<String> paymentType = GeneratedColumn<String>(
      'payment_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _transactionTypeMeta =
      const VerificationMeta('transactionType');
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
      'transaction_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('onsite'));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _conflictDetailsMeta =
      const VerificationMeta('conflictDetails');
  @override
  late final GeneratedColumn<String> conflictDetails = GeneratedColumn<String>(
      'conflict_details', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        serverId,
        status,
        total,
        discount,
        paymentAmount,
        paymentType,
        transactionType,
        note,
        syncStatus,
        createdAt,
        conflictDetails,
        retryCount
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('discount')) {
      context.handle(_discountMeta,
          discount.isAcceptableOrUnknown(data['discount']!, _discountMeta));
    }
    if (data.containsKey('payment_amount')) {
      context.handle(
          _paymentAmountMeta,
          paymentAmount.isAcceptableOrUnknown(
              data['payment_amount']!, _paymentAmountMeta));
    }
    if (data.containsKey('payment_type')) {
      context.handle(
          _paymentTypeMeta,
          paymentType.isAcceptableOrUnknown(
              data['payment_type']!, _paymentTypeMeta));
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
          _transactionTypeMeta,
          transactionType.isAcceptableOrUnknown(
              data['transaction_type']!, _transactionTypeMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('conflict_details')) {
      context.handle(
          _conflictDetailsMeta,
          conflictDetails.isAcceptableOrUnknown(
              data['conflict_details']!, _conflictDetailsMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_id']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total'])!,
      discount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}discount'])!,
      paymentAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}payment_amount']),
      paymentType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_type']),
      transactionType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}transaction_type'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      conflictDetails: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}conflict_details']),
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final int? serverId;
  final String status;
  final double total;
  final double discount;
  final double? paymentAmount;
  final String? paymentType;
  final String transactionType;
  final String? note;
  final String syncStatus;
  final DateTime createdAt;
  final String? conflictDetails;
  final int retryCount;
  const Transaction(
      {required this.id,
      this.serverId,
      required this.status,
      required this.total,
      required this.discount,
      this.paymentAmount,
      this.paymentType,
      required this.transactionType,
      this.note,
      required this.syncStatus,
      required this.createdAt,
      this.conflictDetails,
      required this.retryCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['status'] = Variable<String>(status);
    map['total'] = Variable<double>(total);
    map['discount'] = Variable<double>(discount);
    if (!nullToAbsent || paymentAmount != null) {
      map['payment_amount'] = Variable<double>(paymentAmount);
    }
    if (!nullToAbsent || paymentType != null) {
      map['payment_type'] = Variable<String>(paymentType);
    }
    map['transaction_type'] = Variable<String>(transactionType);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || conflictDetails != null) {
      map['conflict_details'] = Variable<String>(conflictDetails);
    }
    map['retry_count'] = Variable<int>(retryCount);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      status: Value(status),
      total: Value(total),
      discount: Value(discount),
      paymentAmount: paymentAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentAmount),
      paymentType: paymentType == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentType),
      transactionType: Value(transactionType),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      conflictDetails: conflictDetails == null && nullToAbsent
          ? const Value.absent()
          : Value(conflictDetails),
      retryCount: Value(retryCount),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      status: serializer.fromJson<String>(json['status']),
      total: serializer.fromJson<double>(json['total']),
      discount: serializer.fromJson<double>(json['discount']),
      paymentAmount: serializer.fromJson<double?>(json['paymentAmount']),
      paymentType: serializer.fromJson<String?>(json['paymentType']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      note: serializer.fromJson<String?>(json['note']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      conflictDetails: serializer.fromJson<String?>(json['conflictDetails']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverId': serializer.toJson<int?>(serverId),
      'status': serializer.toJson<String>(status),
      'total': serializer.toJson<double>(total),
      'discount': serializer.toJson<double>(discount),
      'paymentAmount': serializer.toJson<double?>(paymentAmount),
      'paymentType': serializer.toJson<String?>(paymentType),
      'transactionType': serializer.toJson<String>(transactionType),
      'note': serializer.toJson<String?>(note),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'conflictDetails': serializer.toJson<String?>(conflictDetails),
      'retryCount': serializer.toJson<int>(retryCount),
    };
  }

  Transaction copyWith(
          {int? id,
          Value<int?> serverId = const Value.absent(),
          String? status,
          double? total,
          double? discount,
          Value<double?> paymentAmount = const Value.absent(),
          Value<String?> paymentType = const Value.absent(),
          String? transactionType,
          Value<String?> note = const Value.absent(),
          String? syncStatus,
          DateTime? createdAt,
          Value<String?> conflictDetails = const Value.absent(),
          int? retryCount}) =>
      Transaction(
        id: id ?? this.id,
        serverId: serverId.present ? serverId.value : this.serverId,
        status: status ?? this.status,
        total: total ?? this.total,
        discount: discount ?? this.discount,
        paymentAmount:
            paymentAmount.present ? paymentAmount.value : this.paymentAmount,
        paymentType: paymentType.present ? paymentType.value : this.paymentType,
        transactionType: transactionType ?? this.transactionType,
        note: note.present ? note.value : this.note,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
        conflictDetails: conflictDetails.present
            ? conflictDetails.value
            : this.conflictDetails,
        retryCount: retryCount ?? this.retryCount,
      );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      status: data.status.present ? data.status.value : this.status,
      total: data.total.present ? data.total.value : this.total,
      discount: data.discount.present ? data.discount.value : this.discount,
      paymentAmount: data.paymentAmount.present
          ? data.paymentAmount.value
          : this.paymentAmount,
      paymentType:
          data.paymentType.present ? data.paymentType.value : this.paymentType,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      note: data.note.present ? data.note.value : this.note,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      conflictDetails: data.conflictDetails.present
          ? data.conflictDetails.value
          : this.conflictDetails,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('status: $status, ')
          ..write('total: $total, ')
          ..write('discount: $discount, ')
          ..write('paymentAmount: $paymentAmount, ')
          ..write('paymentType: $paymentType, ')
          ..write('transactionType: $transactionType, ')
          ..write('note: $note, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('conflictDetails: $conflictDetails, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      serverId,
      status,
      total,
      discount,
      paymentAmount,
      paymentType,
      transactionType,
      note,
      syncStatus,
      createdAt,
      conflictDetails,
      retryCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.serverId == this.serverId &&
          other.status == this.status &&
          other.total == this.total &&
          other.discount == this.discount &&
          other.paymentAmount == this.paymentAmount &&
          other.paymentType == this.paymentType &&
          other.transactionType == this.transactionType &&
          other.note == this.note &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.conflictDetails == this.conflictDetails &&
          other.retryCount == this.retryCount);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<int?> serverId;
  final Value<String> status;
  final Value<double> total;
  final Value<double> discount;
  final Value<double?> paymentAmount;
  final Value<String?> paymentType;
  final Value<String> transactionType;
  final Value<String?> note;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<String?> conflictDetails;
  final Value<int> retryCount;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    this.status = const Value.absent(),
    this.total = const Value.absent(),
    this.discount = const Value.absent(),
    this.paymentAmount = const Value.absent(),
    this.paymentType = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.note = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.conflictDetails = const Value.absent(),
    this.retryCount = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    this.serverId = const Value.absent(),
    required String status,
    required double total,
    this.discount = const Value.absent(),
    this.paymentAmount = const Value.absent(),
    this.paymentType = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.note = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime createdAt,
    this.conflictDetails = const Value.absent(),
    this.retryCount = const Value.absent(),
  })  : status = Value(status),
        total = Value(total),
        createdAt = Value(createdAt);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<int>? serverId,
    Expression<String>? status,
    Expression<double>? total,
    Expression<double>? discount,
    Expression<double>? paymentAmount,
    Expression<String>? paymentType,
    Expression<String>? transactionType,
    Expression<String>? note,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<String>? conflictDetails,
    Expression<int>? retryCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      if (status != null) 'status': status,
      if (total != null) 'total': total,
      if (discount != null) 'discount': discount,
      if (paymentAmount != null) 'payment_amount': paymentAmount,
      if (paymentType != null) 'payment_type': paymentType,
      if (transactionType != null) 'transaction_type': transactionType,
      if (note != null) 'note': note,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (conflictDetails != null) 'conflict_details': conflictDetails,
      if (retryCount != null) 'retry_count': retryCount,
    });
  }

  TransactionsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? serverId,
      Value<String>? status,
      Value<double>? total,
      Value<double>? discount,
      Value<double?>? paymentAmount,
      Value<String?>? paymentType,
      Value<String>? transactionType,
      Value<String?>? note,
      Value<String>? syncStatus,
      Value<DateTime>? createdAt,
      Value<String?>? conflictDetails,
      Value<int>? retryCount}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      status: status ?? this.status,
      total: total ?? this.total,
      discount: discount ?? this.discount,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentType: paymentType ?? this.paymentType,
      transactionType: transactionType ?? this.transactionType,
      note: note ?? this.note,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      conflictDetails: conflictDetails ?? this.conflictDetails,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (discount.present) {
      map['discount'] = Variable<double>(discount.value);
    }
    if (paymentAmount.present) {
      map['payment_amount'] = Variable<double>(paymentAmount.value);
    }
    if (paymentType.present) {
      map['payment_type'] = Variable<String>(paymentType.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (conflictDetails.present) {
      map['conflict_details'] = Variable<String>(conflictDetails.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('serverId: $serverId, ')
          ..write('status: $status, ')
          ..write('total: $total, ')
          ..write('discount: $discount, ')
          ..write('paymentAmount: $paymentAmount, ')
          ..write('paymentType: $paymentType, ')
          ..write('transactionType: $transactionType, ')
          ..write('note: $note, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('conflictDetails: $conflictDetails, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }
}

class $TransactionItemsTable extends TransactionItems
    with TableInfo<$TransactionItemsTable, TransactionItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
      'transaction_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES transactions (id)'));
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
      'item_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _itemNameMeta =
      const VerificationMeta('itemName');
  @override
  late final GeneratedColumn<String> itemName = GeneratedColumn<String>(
      'item_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _customPriceMeta =
      const VerificationMeta('customPrice');
  @override
  late final GeneratedColumn<double> customPrice = GeneratedColumn<double>(
      'custom_price', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _subtotalMeta =
      const VerificationMeta('subtotal');
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
      'subtotal', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        transactionId,
        itemId,
        itemName,
        quantity,
        price,
        customPrice,
        subtotal
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_items';
  @override
  VerificationContext validateIntegrity(Insertable<TransactionItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('item_name')) {
      context.handle(_itemNameMeta,
          itemName.isAcceptableOrUnknown(data['item_name']!, _itemNameMeta));
    } else if (isInserting) {
      context.missing(_itemNameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('custom_price')) {
      context.handle(
          _customPriceMeta,
          customPrice.isAcceptableOrUnknown(
              data['custom_price']!, _customPriceMeta));
    }
    if (data.containsKey('subtotal')) {
      context.handle(_subtotalMeta,
          subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta));
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}transaction_id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}item_id'])!,
      itemName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_name'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price'])!,
      customPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}custom_price']),
      subtotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}subtotal'])!,
    );
  }

  @override
  $TransactionItemsTable createAlias(String alias) {
    return $TransactionItemsTable(attachedDatabase, alias);
  }
}

class TransactionItem extends DataClass implements Insertable<TransactionItem> {
  final int id;
  final int transactionId;
  final int itemId;
  final String itemName;
  final int quantity;
  final double price;
  final double? customPrice;
  final double subtotal;
  const TransactionItem(
      {required this.id,
      required this.transactionId,
      required this.itemId,
      required this.itemName,
      required this.quantity,
      required this.price,
      this.customPrice,
      required this.subtotal});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaction_id'] = Variable<int>(transactionId);
    map['item_id'] = Variable<int>(itemId);
    map['item_name'] = Variable<String>(itemName);
    map['quantity'] = Variable<int>(quantity);
    map['price'] = Variable<double>(price);
    if (!nullToAbsent || customPrice != null) {
      map['custom_price'] = Variable<double>(customPrice);
    }
    map['subtotal'] = Variable<double>(subtotal);
    return map;
  }

  TransactionItemsCompanion toCompanion(bool nullToAbsent) {
    return TransactionItemsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      itemId: Value(itemId),
      itemName: Value(itemName),
      quantity: Value(quantity),
      price: Value(price),
      customPrice: customPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(customPrice),
      subtotal: Value(subtotal),
    );
  }

  factory TransactionItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionItem(
      id: serializer.fromJson<int>(json['id']),
      transactionId: serializer.fromJson<int>(json['transactionId']),
      itemId: serializer.fromJson<int>(json['itemId']),
      itemName: serializer.fromJson<String>(json['itemName']),
      quantity: serializer.fromJson<int>(json['quantity']),
      price: serializer.fromJson<double>(json['price']),
      customPrice: serializer.fromJson<double?>(json['customPrice']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionId': serializer.toJson<int>(transactionId),
      'itemId': serializer.toJson<int>(itemId),
      'itemName': serializer.toJson<String>(itemName),
      'quantity': serializer.toJson<int>(quantity),
      'price': serializer.toJson<double>(price),
      'customPrice': serializer.toJson<double?>(customPrice),
      'subtotal': serializer.toJson<double>(subtotal),
    };
  }

  TransactionItem copyWith(
          {int? id,
          int? transactionId,
          int? itemId,
          String? itemName,
          int? quantity,
          double? price,
          Value<double?> customPrice = const Value.absent(),
          double? subtotal}) =>
      TransactionItem(
        id: id ?? this.id,
        transactionId: transactionId ?? this.transactionId,
        itemId: itemId ?? this.itemId,
        itemName: itemName ?? this.itemName,
        quantity: quantity ?? this.quantity,
        price: price ?? this.price,
        customPrice: customPrice.present ? customPrice.value : this.customPrice,
        subtotal: subtotal ?? this.subtotal,
      );
  TransactionItem copyWithCompanion(TransactionItemsCompanion data) {
    return TransactionItem(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      itemName: data.itemName.present ? data.itemName.value : this.itemName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      price: data.price.present ? data.price.value : this.price,
      customPrice:
          data.customPrice.present ? data.customPrice.value : this.customPrice,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionItem(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('itemId: $itemId, ')
          ..write('itemName: $itemName, ')
          ..write('quantity: $quantity, ')
          ..write('price: $price, ')
          ..write('customPrice: $customPrice, ')
          ..write('subtotal: $subtotal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, transactionId, itemId, itemName, quantity,
      price, customPrice, subtotal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionItem &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.itemId == this.itemId &&
          other.itemName == this.itemName &&
          other.quantity == this.quantity &&
          other.price == this.price &&
          other.customPrice == this.customPrice &&
          other.subtotal == this.subtotal);
}

class TransactionItemsCompanion extends UpdateCompanion<TransactionItem> {
  final Value<int> id;
  final Value<int> transactionId;
  final Value<int> itemId;
  final Value<String> itemName;
  final Value<int> quantity;
  final Value<double> price;
  final Value<double?> customPrice;
  final Value<double> subtotal;
  const TransactionItemsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.itemName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.price = const Value.absent(),
    this.customPrice = const Value.absent(),
    this.subtotal = const Value.absent(),
  });
  TransactionItemsCompanion.insert({
    this.id = const Value.absent(),
    required int transactionId,
    required int itemId,
    required String itemName,
    required int quantity,
    required double price,
    this.customPrice = const Value.absent(),
    required double subtotal,
  })  : transactionId = Value(transactionId),
        itemId = Value(itemId),
        itemName = Value(itemName),
        quantity = Value(quantity),
        price = Value(price),
        subtotal = Value(subtotal);
  static Insertable<TransactionItem> custom({
    Expression<int>? id,
    Expression<int>? transactionId,
    Expression<int>? itemId,
    Expression<String>? itemName,
    Expression<int>? quantity,
    Expression<double>? price,
    Expression<double>? customPrice,
    Expression<double>? subtotal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (itemId != null) 'item_id': itemId,
      if (itemName != null) 'item_name': itemName,
      if (quantity != null) 'quantity': quantity,
      if (price != null) 'price': price,
      if (customPrice != null) 'custom_price': customPrice,
      if (subtotal != null) 'subtotal': subtotal,
    });
  }

  TransactionItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? transactionId,
      Value<int>? itemId,
      Value<String>? itemName,
      Value<int>? quantity,
      Value<double>? price,
      Value<double?>? customPrice,
      Value<double>? subtotal}) {
    return TransactionItemsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      customPrice: customPrice ?? this.customPrice,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (itemName.present) {
      map['item_name'] = Variable<String>(itemName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (customPrice.present) {
      map['custom_price'] = Variable<double>(customPrice.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionItemsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('itemId: $itemId, ')
          ..write('itemName: $itemName, ')
          ..write('quantity: $quantity, ')
          ..write('price: $price, ')
          ..write('customPrice: $customPrice, ')
          ..write('subtotal: $subtotal')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $TransactionItemsTable transactionItems =
      $TransactionItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [items, transactions, transactionItems];
}

typedef $$ItemsTableCreateCompanionBuilder = ItemsCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> description,
  Value<int> stock,
  Value<bool> isStockManaged,
  Value<double?> buyPrice,
  required double price,
  Value<String?> imageUrl,
  required DateTime updatedAt,
});
typedef $$ItemsTableUpdateCompanionBuilder = ItemsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> description,
  Value<int> stock,
  Value<bool> isStockManaged,
  Value<double?> buyPrice,
  Value<double> price,
  Value<String?> imageUrl,
  Value<DateTime> updatedAt,
});

class $$ItemsTableFilterComposer extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stock => $composableBuilder(
      column: $table.stock, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isStockManaged => $composableBuilder(
      column: $table.isStockManaged,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get buyPrice => $composableBuilder(
      column: $table.buyPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stock => $composableBuilder(
      column: $table.stock, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isStockManaged => $composableBuilder(
      column: $table.isStockManaged,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get buyPrice => $composableBuilder(
      column: $table.buyPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<bool> get isStockManaged => $composableBuilder(
      column: $table.isStockManaged, builder: (column) => column);

  GeneratedColumn<double> get buyPrice =>
      $composableBuilder(column: $table.buyPrice, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ItemsTable,
    Item,
    $$ItemsTableFilterComposer,
    $$ItemsTableOrderingComposer,
    $$ItemsTableAnnotationComposer,
    $$ItemsTableCreateCompanionBuilder,
    $$ItemsTableUpdateCompanionBuilder,
    (Item, BaseReferences<_$AppDatabase, $ItemsTable, Item>),
    Item,
    PrefetchHooks Function()> {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> stock = const Value.absent(),
            Value<bool> isStockManaged = const Value.absent(),
            Value<double?> buyPrice = const Value.absent(),
            Value<double> price = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              ItemsCompanion(
            id: id,
            name: name,
            description: description,
            stock: stock,
            isStockManaged: isStockManaged,
            buyPrice: buyPrice,
            price: price,
            imageUrl: imageUrl,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> description = const Value.absent(),
            Value<int> stock = const Value.absent(),
            Value<bool> isStockManaged = const Value.absent(),
            Value<double?> buyPrice = const Value.absent(),
            required double price,
            Value<String?> imageUrl = const Value.absent(),
            required DateTime updatedAt,
          }) =>
              ItemsCompanion.insert(
            id: id,
            name: name,
            description: description,
            stock: stock,
            isStockManaged: isStockManaged,
            buyPrice: buyPrice,
            price: price,
            imageUrl: imageUrl,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ItemsTable,
    Item,
    $$ItemsTableFilterComposer,
    $$ItemsTableOrderingComposer,
    $$ItemsTableAnnotationComposer,
    $$ItemsTableCreateCompanionBuilder,
    $$ItemsTableUpdateCompanionBuilder,
    (Item, BaseReferences<_$AppDatabase, $ItemsTable, Item>),
    Item,
    PrefetchHooks Function()>;
typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> id,
  Value<int?> serverId,
  required String status,
  required double total,
  Value<double> discount,
  Value<double?> paymentAmount,
  Value<String?> paymentType,
  Value<String> transactionType,
  Value<String?> note,
  Value<String> syncStatus,
  required DateTime createdAt,
  Value<String?> conflictDetails,
  Value<int> retryCount,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> id,
  Value<int?> serverId,
  Value<String> status,
  Value<double> total,
  Value<double> discount,
  Value<double?> paymentAmount,
  Value<String?> paymentType,
  Value<String> transactionType,
  Value<String?> note,
  Value<String> syncStatus,
  Value<DateTime> createdAt,
  Value<String?> conflictDetails,
  Value<int> retryCount,
});

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionItemsTable, List<TransactionItem>>
      _transactionItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.transactionItems,
              aliasName: $_aliasNameGenerator(
                  db.transactions.id, db.transactionItems.transactionId));

  $$TransactionItemsTableProcessedTableManager get transactionItemsRefs {
    final manager = $$TransactionItemsTableTableManager(
            $_db, $_db.transactionItems)
        .filter((f) => f.transactionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_transactionItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get paymentAmount => $composableBuilder(
      column: $table.paymentAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentType => $composableBuilder(
      column: $table.paymentType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transactionType => $composableBuilder(
      column: $table.transactionType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conflictDetails => $composableBuilder(
      column: $table.conflictDetails,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  Expression<bool> transactionItemsRefs(
      Expression<bool> Function($$TransactionItemsTableFilterComposer f) f) {
    final $$TransactionItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactionItems,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionItemsTableFilterComposer(
              $db: $db,
              $table: $db.transactionItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get paymentAmount => $composableBuilder(
      column: $table.paymentAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentType => $composableBuilder(
      column: $table.paymentType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transactionType => $composableBuilder(
      column: $table.transactionType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conflictDetails => $composableBuilder(
      column: $table.conflictDetails,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<double> get discount =>
      $composableBuilder(column: $table.discount, builder: (column) => column);

  GeneratedColumn<double> get paymentAmount => $composableBuilder(
      column: $table.paymentAmount, builder: (column) => column);

  GeneratedColumn<String> get paymentType => $composableBuilder(
      column: $table.paymentType, builder: (column) => column);

  GeneratedColumn<String> get transactionType => $composableBuilder(
      column: $table.transactionType, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get conflictDetails => $composableBuilder(
      column: $table.conflictDetails, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  Expression<T> transactionItemsRefs<T extends Object>(
      Expression<T> Function($$TransactionItemsTableAnnotationComposer a) f) {
    final $$TransactionItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactionItems,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactionItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (Transaction, $$TransactionsTableReferences),
    Transaction,
    PrefetchHooks Function({bool transactionItemsRefs})> {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> serverId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<double> total = const Value.absent(),
            Value<double> discount = const Value.absent(),
            Value<double?> paymentAmount = const Value.absent(),
            Value<String?> paymentType = const Value.absent(),
            Value<String> transactionType = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String?> conflictDetails = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
          }) =>
              TransactionsCompanion(
            id: id,
            serverId: serverId,
            status: status,
            total: total,
            discount: discount,
            paymentAmount: paymentAmount,
            paymentType: paymentType,
            transactionType: transactionType,
            note: note,
            syncStatus: syncStatus,
            createdAt: createdAt,
            conflictDetails: conflictDetails,
            retryCount: retryCount,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> serverId = const Value.absent(),
            required String status,
            required double total,
            Value<double> discount = const Value.absent(),
            Value<double?> paymentAmount = const Value.absent(),
            Value<String?> paymentType = const Value.absent(),
            Value<String> transactionType = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required DateTime createdAt,
            Value<String?> conflictDetails = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
          }) =>
              TransactionsCompanion.insert(
            id: id,
            serverId: serverId,
            status: status,
            total: total,
            discount: discount,
            paymentAmount: paymentAmount,
            paymentType: paymentType,
            transactionType: transactionType,
            note: note,
            syncStatus: syncStatus,
            createdAt: createdAt,
            conflictDetails: conflictDetails,
            retryCount: retryCount,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TransactionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({transactionItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionItemsRefs) db.transactionItems
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionItemsRefs)
                    await $_getPrefetchedData<Transaction, $TransactionsTable,
                            TransactionItem>(
                        currentTable: table,
                        referencedTable: $$TransactionsTableReferences
                            ._transactionItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransactionsTableReferences(db, table, p0)
                                .transactionItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.transactionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (Transaction, $$TransactionsTableReferences),
    Transaction,
    PrefetchHooks Function({bool transactionItemsRefs})>;
typedef $$TransactionItemsTableCreateCompanionBuilder
    = TransactionItemsCompanion Function({
  Value<int> id,
  required int transactionId,
  required int itemId,
  required String itemName,
  required int quantity,
  required double price,
  Value<double?> customPrice,
  required double subtotal,
});
typedef $$TransactionItemsTableUpdateCompanionBuilder
    = TransactionItemsCompanion Function({
  Value<int> id,
  Value<int> transactionId,
  Value<int> itemId,
  Value<String> itemName,
  Value<int> quantity,
  Value<double> price,
  Value<double?> customPrice,
  Value<double> subtotal,
});

final class $$TransactionItemsTableReferences extends BaseReferences<
    _$AppDatabase, $TransactionItemsTable, TransactionItem> {
  $$TransactionItemsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias($_aliasNameGenerator(
          db.transactionItems.transactionId, db.transactions.id));

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<int>('transaction_id')!;

    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TransactionItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionItemsTable> {
  $$TransactionItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemName => $composableBuilder(
      column: $table.itemName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get customPrice => $composableBuilder(
      column: $table.customPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnFilters(column));

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionItemsTable> {
  $$TransactionItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemName => $composableBuilder(
      column: $table.itemName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get customPrice => $composableBuilder(
      column: $table.customPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnOrderings(column));

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableOrderingComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionItemsTable> {
  $$TransactionItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get itemName =>
      $composableBuilder(column: $table.itemName, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get customPrice => $composableBuilder(
      column: $table.customPrice, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionItemsTable,
    TransactionItem,
    $$TransactionItemsTableFilterComposer,
    $$TransactionItemsTableOrderingComposer,
    $$TransactionItemsTableAnnotationComposer,
    $$TransactionItemsTableCreateCompanionBuilder,
    $$TransactionItemsTableUpdateCompanionBuilder,
    (TransactionItem, $$TransactionItemsTableReferences),
    TransactionItem,
    PrefetchHooks Function({bool transactionId})> {
  $$TransactionItemsTableTableManager(
      _$AppDatabase db, $TransactionItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> transactionId = const Value.absent(),
            Value<int> itemId = const Value.absent(),
            Value<String> itemName = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<double> price = const Value.absent(),
            Value<double?> customPrice = const Value.absent(),
            Value<double> subtotal = const Value.absent(),
          }) =>
              TransactionItemsCompanion(
            id: id,
            transactionId: transactionId,
            itemId: itemId,
            itemName: itemName,
            quantity: quantity,
            price: price,
            customPrice: customPrice,
            subtotal: subtotal,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int transactionId,
            required int itemId,
            required String itemName,
            required int quantity,
            required double price,
            Value<double?> customPrice = const Value.absent(),
            required double subtotal,
          }) =>
              TransactionItemsCompanion.insert(
            id: id,
            transactionId: transactionId,
            itemId: itemId,
            itemName: itemName,
            quantity: quantity,
            price: price,
            customPrice: customPrice,
            subtotal: subtotal,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TransactionItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({transactionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (transactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.transactionId,
                    referencedTable: $$TransactionItemsTableReferences
                        ._transactionIdTable(db),
                    referencedColumn: $$TransactionItemsTableReferences
                        ._transactionIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TransactionItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionItemsTable,
    TransactionItem,
    $$TransactionItemsTableFilterComposer,
    $$TransactionItemsTableOrderingComposer,
    $$TransactionItemsTableAnnotationComposer,
    $$TransactionItemsTableCreateCompanionBuilder,
    $$TransactionItemsTableUpdateCompanionBuilder,
    (TransactionItem, $$TransactionItemsTableReferences),
    TransactionItem,
    PrefetchHooks Function({bool transactionId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$TransactionItemsTableTableManager get transactionItems =>
      $$TransactionItemsTableTableManager(_db, _db.transactionItems);
}
