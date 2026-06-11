// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'po_bill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$POBillModelImpl _$$POBillModelImplFromJson(Map<String, dynamic> json) =>
    _$POBillModelImpl(
      id: (json['id'] as num?)?.toInt(),
      invoiceNumber: json['invoice_number'] as String,
      vendorName: json['vendor_name'] as String,
      amount: (json['amount'] as num).toDouble(),
      receivedDate: DateTime.parse(json['received_date'] as String),
      dueDate: DateTime.parse(json['due_date'] as String),
      status: json['status'] as String? ?? 'pending',
      paidDate: json['paid_date'] == null
          ? null
          : DateTime.parse(json['paid_date'] as String),
      receiptImage: json['receipt_image'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$POBillModelImplToJson(_$POBillModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invoice_number': instance.invoiceNumber,
      'vendor_name': instance.vendorName,
      'amount': instance.amount,
      'received_date': instance.receivedDate.toIso8601String(),
      'due_date': instance.dueDate.toIso8601String(),
      'status': instance.status,
      'paid_date': instance.paidDate?.toIso8601String(),
      'receipt_image': instance.receiptImage,
      'notes': instance.notes,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
