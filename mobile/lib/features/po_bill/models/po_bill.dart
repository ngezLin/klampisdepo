import 'package:freezed_annotation/freezed_annotation.dart';

part 'po_bill.freezed.dart';
part 'po_bill.g.dart';

@freezed
class POBillModel with _$POBillModel {
  const factory POBillModel({
    int? id,
    @JsonKey(name: 'invoice_number') required String invoiceNumber,
    @JsonKey(name: 'vendor_name') required String vendorName,
    required double amount,
    @JsonKey(name: 'received_date') required DateTime receivedDate,
    @JsonKey(name: 'due_date') required DateTime dueDate,
    @Default('pending') String status, // 'pending' or 'paid'
    @JsonKey(name: 'paid_date') DateTime? paidDate,
    @JsonKey(name: 'receipt_image') @Default('') String receiptImage,
    @Default('') String notes,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _POBillModel;

  factory POBillModel.fromJson(Map<String, dynamic> json) => _$POBillModelFromJson(json);
}
