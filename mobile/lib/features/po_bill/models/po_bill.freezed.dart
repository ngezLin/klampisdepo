// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'po_bill.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

POBillModel _$POBillModelFromJson(Map<String, dynamic> json) {
  return _POBillModel.fromJson(json);
}

/// @nodoc
mixin _$POBillModel {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'invoice_number')
  String get invoiceNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'vendor_name')
  String get vendorName => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'received_date')
  DateTime get receivedDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'due_date')
  DateTime get dueDate => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // 'pending' or 'paid'
  @JsonKey(name: 'paid_date')
  DateTime? get paidDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'receipt_image')
  String get receiptImage => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this POBillModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of POBillModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $POBillModelCopyWith<POBillModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $POBillModelCopyWith<$Res> {
  factory $POBillModelCopyWith(
          POBillModel value, $Res Function(POBillModel) then) =
      _$POBillModelCopyWithImpl<$Res, POBillModel>;
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'invoice_number') String invoiceNumber,
      @JsonKey(name: 'vendor_name') String vendorName,
      double amount,
      @JsonKey(name: 'received_date') DateTime receivedDate,
      @JsonKey(name: 'due_date') DateTime dueDate,
      String status,
      @JsonKey(name: 'paid_date') DateTime? paidDate,
      @JsonKey(name: 'receipt_image') String receiptImage,
      String notes,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$POBillModelCopyWithImpl<$Res, $Val extends POBillModel>
    implements $POBillModelCopyWith<$Res> {
  _$POBillModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of POBillModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? invoiceNumber = null,
    Object? vendorName = null,
    Object? amount = null,
    Object? receivedDate = null,
    Object? dueDate = null,
    Object? status = null,
    Object? paidDate = freezed,
    Object? receiptImage = null,
    Object? notes = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      invoiceNumber: null == invoiceNumber
          ? _value.invoiceNumber
          : invoiceNumber // ignore: cast_nullable_to_non_nullable
              as String,
      vendorName: null == vendorName
          ? _value.vendorName
          : vendorName // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      receivedDate: null == receivedDate
          ? _value.receivedDate
          : receivedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      paidDate: freezed == paidDate
          ? _value.paidDate
          : paidDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      receiptImage: null == receiptImage
          ? _value.receiptImage
          : receiptImage // ignore: cast_nullable_to_non_nullable
              as String,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$POBillModelImplCopyWith<$Res>
    implements $POBillModelCopyWith<$Res> {
  factory _$$POBillModelImplCopyWith(
          _$POBillModelImpl value, $Res Function(_$POBillModelImpl) then) =
      __$$POBillModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'invoice_number') String invoiceNumber,
      @JsonKey(name: 'vendor_name') String vendorName,
      double amount,
      @JsonKey(name: 'received_date') DateTime receivedDate,
      @JsonKey(name: 'due_date') DateTime dueDate,
      String status,
      @JsonKey(name: 'paid_date') DateTime? paidDate,
      @JsonKey(name: 'receipt_image') String receiptImage,
      String notes,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$POBillModelImplCopyWithImpl<$Res>
    extends _$POBillModelCopyWithImpl<$Res, _$POBillModelImpl>
    implements _$$POBillModelImplCopyWith<$Res> {
  __$$POBillModelImplCopyWithImpl(
      _$POBillModelImpl _value, $Res Function(_$POBillModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of POBillModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? invoiceNumber = null,
    Object? vendorName = null,
    Object? amount = null,
    Object? receivedDate = null,
    Object? dueDate = null,
    Object? status = null,
    Object? paidDate = freezed,
    Object? receiptImage = null,
    Object? notes = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$POBillModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      invoiceNumber: null == invoiceNumber
          ? _value.invoiceNumber
          : invoiceNumber // ignore: cast_nullable_to_non_nullable
              as String,
      vendorName: null == vendorName
          ? _value.vendorName
          : vendorName // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      receivedDate: null == receivedDate
          ? _value.receivedDate
          : receivedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      paidDate: freezed == paidDate
          ? _value.paidDate
          : paidDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      receiptImage: null == receiptImage
          ? _value.receiptImage
          : receiptImage // ignore: cast_nullable_to_non_nullable
              as String,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$POBillModelImpl implements _POBillModel {
  const _$POBillModelImpl(
      {this.id,
      @JsonKey(name: 'invoice_number') required this.invoiceNumber,
      @JsonKey(name: 'vendor_name') required this.vendorName,
      required this.amount,
      @JsonKey(name: 'received_date') required this.receivedDate,
      @JsonKey(name: 'due_date') required this.dueDate,
      this.status = 'pending',
      @JsonKey(name: 'paid_date') this.paidDate,
      @JsonKey(name: 'receipt_image') this.receiptImage = '',
      this.notes = '',
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt});

  factory _$POBillModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$POBillModelImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'invoice_number')
  final String invoiceNumber;
  @override
  @JsonKey(name: 'vendor_name')
  final String vendorName;
  @override
  final double amount;
  @override
  @JsonKey(name: 'received_date')
  final DateTime receivedDate;
  @override
  @JsonKey(name: 'due_date')
  final DateTime dueDate;
  @override
  @JsonKey()
  final String status;
// 'pending' or 'paid'
  @override
  @JsonKey(name: 'paid_date')
  final DateTime? paidDate;
  @override
  @JsonKey(name: 'receipt_image')
  final String receiptImage;
  @override
  @JsonKey()
  final String notes;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'POBillModel(id: $id, invoiceNumber: $invoiceNumber, vendorName: $vendorName, amount: $amount, receivedDate: $receivedDate, dueDate: $dueDate, status: $status, paidDate: $paidDate, receiptImage: $receiptImage, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$POBillModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.invoiceNumber, invoiceNumber) ||
                other.invoiceNumber == invoiceNumber) &&
            (identical(other.vendorName, vendorName) ||
                other.vendorName == vendorName) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.receivedDate, receivedDate) ||
                other.receivedDate == receivedDate) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paidDate, paidDate) ||
                other.paidDate == paidDate) &&
            (identical(other.receiptImage, receiptImage) ||
                other.receiptImage == receiptImage) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      invoiceNumber,
      vendorName,
      amount,
      receivedDate,
      dueDate,
      status,
      paidDate,
      receiptImage,
      notes,
      createdAt,
      updatedAt);

  /// Create a copy of POBillModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$POBillModelImplCopyWith<_$POBillModelImpl> get copyWith =>
      __$$POBillModelImplCopyWithImpl<_$POBillModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$POBillModelImplToJson(
      this,
    );
  }
}

abstract class _POBillModel implements POBillModel {
  const factory _POBillModel(
          {final int? id,
          @JsonKey(name: 'invoice_number') required final String invoiceNumber,
          @JsonKey(name: 'vendor_name') required final String vendorName,
          required final double amount,
          @JsonKey(name: 'received_date') required final DateTime receivedDate,
          @JsonKey(name: 'due_date') required final DateTime dueDate,
          final String status,
          @JsonKey(name: 'paid_date') final DateTime? paidDate,
          @JsonKey(name: 'receipt_image') final String receiptImage,
          final String notes,
          @JsonKey(name: 'created_at') final DateTime? createdAt,
          @JsonKey(name: 'updated_at') final DateTime? updatedAt}) =
      _$POBillModelImpl;

  factory _POBillModel.fromJson(Map<String, dynamic> json) =
      _$POBillModelImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'invoice_number')
  String get invoiceNumber;
  @override
  @JsonKey(name: 'vendor_name')
  String get vendorName;
  @override
  double get amount;
  @override
  @JsonKey(name: 'received_date')
  DateTime get receivedDate;
  @override
  @JsonKey(name: 'due_date')
  DateTime get dueDate;
  @override
  String get status; // 'pending' or 'paid'
  @override
  @JsonKey(name: 'paid_date')
  DateTime? get paidDate;
  @override
  @JsonKey(name: 'receipt_image')
  String get receiptImage;
  @override
  String get notes;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of POBillModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$POBillModelImplCopyWith<_$POBillModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
