import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../items/data/item_model.dart';
import 'cart_provider.dart';

class ReceiptService {
  static Future<void> printReceipt({
    required List<CartItem> items,
    required double total,
    required double payment,
    required String transactionId,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // Standard 80mm thermal paper
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('KLAMPIS DEPO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                    pw.Text('POS Transaction Receipt'),
                    pw.Text('ID: $transactionId', style: const pw.TextStyle(fontSize: 8)),
                    pw.Divider(),
                  ],
                ),
              ),
              pw.Text('Date: ${DateTime.now().toLocal().toString().split('.')[0]}'),
              pw.SizedBox(height: 10),
              ...items.map((cartItem) {
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(child: pw.Text('${cartItem.item.name} x${cartItem.quantity}')),
                    pw.Text('\Rp ${(cartItem.item.price * cartItem.quantity).toStringAsFixed(0)}'),
                  ],
                );
              }),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('\Rp ${total.toStringAsFixed(0)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Payment:'),
                  pw.Text('\Rp ${payment.toStringAsFixed(0)}'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Change:'),
                  pw.Text('\Rp ${(payment - total).toStringAsFixed(0)}'),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Center(child: pw.Text('Thank you for your business!')),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'receipt_$transactionId.pdf',
    );
  }
}
