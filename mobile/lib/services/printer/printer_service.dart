import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart' as esc;
import '../../core/network/dio_client.dart';
import 'package:share_plus/share_plus.dart';

/// Represents a discovered printer
class PrinterDevice {
  final String name;
  final String address; // IP:port or BT address
  final PrinterConnectionType type;

  PrinterDevice({
    required this.name,
    required this.address,
    required this.type,
  });

  @override
  String toString() => '$name ($address)';
}

enum PrinterConnectionType { bluetooth, network, usb }

/// Status of the printer connection
enum PrinterStatus { disconnected, connecting, connected, printing, error }

/// Generates ESC/POS receipt text (plain text layout for any printer)
class ReceiptFormatter {
  static const int lineWidth = 32; // Standard 58mm thermal receipt width
  static final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  static final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  /// Generate a full receipt from transaction data
  static String formatReceipt({
    required String storeName,
    required int transactionId,
    required DateTime date,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double discount,
    required double total,
    required String paymentType,
    required double paymentAmount,
    required double change,
    String? note,
    String? cashierName,
    String? storeAddress,
    String? storePhone,
  }) {
    final buffer = StringBuffer();

    // ─── HEADER ──────────────────────────
    buffer.writeln(_center(storeName.toUpperCase()));
    if (storeAddress != null) buffer.writeln(_center(storeAddress));
    if (storePhone != null) buffer.writeln(_center(storePhone));
    buffer.writeln(_divider('='));
    buffer.writeln(_dateFormat.format(date));
    buffer.writeln('No. Transaksi: #$transactionId');
    if (cashierName != null) buffer.writeln('Kasir: $cashierName');
    buffer.writeln(_divider('-'));

    // ─── ITEMS ───────────────────────────
    for (final item in items) {
      final name = item['item_name'] as String? ?? item['name'] as String? ?? '-';
      final qty = item['quantity'] as int? ?? 1;
      final price = (item['price'] as num).toDouble();
      final itemSubtotal = (item['subtotal'] as num?)?.toDouble() ?? (qty * price);

      buffer.writeln(name);
      buffer.writeln(_columns(
        '  $qty x ${_currencyFormat.format(price)}',
        _currencyFormat.format(itemSubtotal),
      ));
    }

    buffer.writeln(_divider('-'));

    // ─── TOTALS ──────────────────────────
    buffer.writeln(_columns('Subtotal', _currencyFormat.format(subtotal)));
    if (discount > 0) {
      buffer.writeln(_columns('Diskon', '- ${_currencyFormat.format(discount)}'));
    }
    buffer.writeln(_divider('-'));
    buffer.writeln(_columns('TOTAL', _currencyFormat.format(total)));
    buffer.writeln(_divider('='));

    // ─── PAYMENT ─────────────────────────
    buffer.writeln(_columns('Bayar (${paymentType.toUpperCase()})', _currencyFormat.format(paymentAmount)));
    if (paymentType.toLowerCase() == 'cash' && change > 0) {
      buffer.writeln(_columns('Kembalian', _currencyFormat.format(change)));
    }

    if (note != null && note.isNotEmpty) {
      buffer.writeln(_divider('-'));
      buffer.writeln('Catatan: $note');
    }

    buffer.writeln(_divider('='));

    // ─── FOOTER ──────────────────────────
    buffer.writeln(_center('Terima kasih telah'));
    buffer.writeln(_center('berbelanja!'));
    buffer.writeln('');
    buffer.writeln('');
    buffer.writeln('');

    return buffer.toString();
  }

  /// Center text within the receipt width
  static String _center(String text) {
    if (text.length >= lineWidth) return text;
    final padding = (lineWidth - text.length) ~/ 2;
    return ' ' * padding + text;
  }

  /// Create a divider line
  static String _divider(String char) => char * lineWidth;

  /// Two-column layout (left-aligned and right-aligned)
  static String _columns(String left, String right) {
    final available = lineWidth - right.length;
    if (left.length > available) {
      left = left.substring(0, available);
    }
    return left.padRight(available) + right;
  }
}

/// Manages the printer connection state and print operations
class PrinterService extends ChangeNotifier {
  PrinterDevice? _connectedPrinter;
  PrinterStatus _status = PrinterStatus.disconnected;
  String? _lastError;

  final esc.PrinterManager? _manager = kIsWeb ? null : esc.PrinterManager();

  // Store info for receipts
  String storeName = 'KlampisDepo';
  String? storeAddress;
  String? storePhone;
  String? cashierName;

  // Multiple printer designations
  PrinterDevice? _receiptPrinter;
  PrinterDevice? _kitchenPrinter;

  PrinterDevice? get connectedPrinter => _connectedPrinter;
  PrinterDevice? get receiptPrinter => _receiptPrinter;
  PrinterDevice? get kitchenPrinter => _kitchenPrinter;
  PrinterStatus get status => _status;
  String? get lastError => _lastError;
  bool get isConnected => _status == PrinterStatus.connected;

  void designatePrinter(PrinterDevice device, String role) {
    if (role == 'receipt') {
      _receiptPrinter = device;
    } else if (role == 'kitchen') {
      _kitchenPrinter = device;
    }
    notifyListeners();
  }

  /// Fetch store information from public store.json
  Future<void> fetchStoreInfo(Ref ref) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/uploads/store.json');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        storeName = data['name'] ?? 'KlampisDepo';
        storeAddress = data['address'];
        storePhone = data['phone'];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load store info: $e');
    }
  }

  /// Scan for available printers
  Future<List<PrinterDevice>> scanPrinters() async {
    if (kIsWeb) {
      return [
        PrinterDevice(
          name: 'Browser Print (Preview)',
          address: 'browser',
          type: PrinterConnectionType.network,
        ),
      ];
    }

    final List<PrinterDevice> discovered = [];

    discovered.add(PrinterDevice(
      name: 'Masukan IP Manual',
      address: 'manual',
      type: PrinterConnectionType.network,
    ));

    try {
      if (_manager == null) return discovered;
      final devices = await _manager!.scanPrinters(
        timeout: const Duration(seconds: 4),
        types: {
          esc.PrinterConnectionType.bluetooth,
          esc.PrinterConnectionType.ble,
          esc.PrinterConnectionType.network,
          esc.PrinterConnectionType.usb,
        },
      );

      for (final dev in devices) {
        PrinterConnectionType appType = PrinterConnectionType.network;
        String address = '';

        if (dev is esc.BluetoothPrinterDevice) {
          appType = PrinterConnectionType.bluetooth;
          address = dev.address;
        } else if (dev is esc.BlePrinterDevice) {
          appType = PrinterConnectionType.bluetooth;
          address = dev.deviceId;
        } else if (dev is esc.NetworkPrinterDevice) {
          appType = PrinterConnectionType.network;
          address = '${dev.host}:${dev.port}';
        } else if (dev is esc.UsbPrinterDevice) {
          appType = PrinterConnectionType.usb;
          address = dev.identifier;
        }

        discovered.add(PrinterDevice(
          name: dev.name.isEmpty ? 'Unknown Printer' : dev.name,
          address: address,
          type: appType,
        ));
      }
    } catch (e) {
      debugPrint('Error scanning printers: $e');
    }

    return discovered;
  }

  /// Connect to a specific printer
  Future<bool> connectToPrinter(PrinterDevice device) async {
    _status = PrinterStatus.connecting;
    _lastError = null;
    notifyListeners();

    try {
      if (kIsWeb || device.address == 'browser') {
        _connectedPrinter = device;
        _status = PrinterStatus.connected;
        notifyListeners();
        return true;
      }

      if (device.address == 'manual') {
        _status = PrinterStatus.disconnected;
        notifyListeners();
        return false;
      }

      esc.PrinterDevice escDevice;
      if (device.type == PrinterConnectionType.bluetooth) {
        if (device.address.contains('-')) {
          escDevice = esc.BlePrinterDevice(
            name: device.name,
            deviceId: device.address,
          );
        } else {
          escDevice = esc.BluetoothPrinterDevice(
            name: device.name,
            address: device.address,
          );
        }
      } else if (device.type == PrinterConnectionType.network) {
        final parts = device.address.split(':');
        final host = parts[0];
        final port = parts.length > 1 ? (int.tryParse(parts[1]) ?? 9100) : 9100;
        escDevice = esc.NetworkPrinterDevice(
          name: device.name,
          host: host,
          port: port,
        );
      } else {
        escDevice = esc.UsbPrinterDevice(
          name: device.name,
          identifier: device.address,
          usbPlatform: esc.UsbPlatform.android,
        );
      }

      if (_manager == null) return false;
      await _manager!.connect(escDevice);

      _connectedPrinter = device;
      _status = PrinterStatus.connected;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = e.toString();
      _status = PrinterStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Disconnect the current printer
  void disconnect() {
    try {
      if (_manager != null) {
        _manager!.disconnect();
      }
    } catch (e) {
      debugPrint('Error disconnecting manager: $e');
    }
    _connectedPrinter = null;
    _status = PrinterStatus.disconnected;
    _lastError = null;
    notifyListeners();
  }

  /// Trigger cash drawer open via ESC/POS command
  Future<bool> openCashDrawer() async {
    if (_status != PrinterStatus.connected) return false;
    if (kIsWeb || _connectedPrinter?.address == 'browser') return true;
    if (_manager == null) return false;
    try {
      // ESC p m t1 t2 - Trigger cash drawer pin 2 and pin 5
      final List<int> openDrawer = [
        0x1B, 0x70, 0x00, 0x19, 0x78,
        0x1B, 0x70, 0x01, 0x19, 0x78,
      ];
      await _manager!.printBytes(openDrawer);
      return true;
    } catch (e) {
      debugPrint('Failed to open cash drawer: $e');
      return false;
    }
  }

  /// Print a receipt for a transaction (with role selection support)
  Future<bool> printReceipt(Map<String, dynamic> transaction, {String role = 'receipt'}) async {
    final targetPrinter = role == 'kitchen' ? _kitchenPrinter : (_receiptPrinter ?? _connectedPrinter);
    if (targetPrinter == null) {
      _lastError = 'Printer $role belum terhubung';
      notifyListeners();
      return false;
    }

    // Connect to target printer if needed
    if (_connectedPrinter?.address != targetPrinter.address) {
      final success = await connectToPrinter(targetPrinter);
      if (!success) return false;
    }

    _status = PrinterStatus.printing;
    notifyListeners();

    try {
      final items = (transaction['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final DateTime date = transaction['created_at'] != null
          ? DateTime.parse(transaction['created_at'] as String).toLocal()
          : DateTime.now();

      final receipt = ReceiptFormatter.formatReceipt(
        storeName: storeName,
        transactionId: transaction['id'] as int? ?? 0,
        date: date,
        items: items,
        subtotal: _toDouble(transaction['subtotal'] ?? transaction['total']),
        discount: _toDouble(transaction['discount'] ?? 0),
        total: _toDouble(transaction['total'] ?? 0),
        paymentType: transaction['payment_type'] as String? ?? 'cash',
        paymentAmount: _toDouble(transaction['payment'] ?? transaction['total'] ?? 0),
        change: _toDouble(transaction['change'] ?? 0),
        note: transaction['note'] as String?,
        cashierName: cashierName,
        storeAddress: storeAddress,
        storePhone: storePhone,
      );

      if (kIsWeb || _connectedPrinter?.address == 'browser') {
        debugPrint('══════ RECEIPT PREVIEW ($role) ══════');
        debugPrint(receipt);
        debugPrint('════════════════════════════');
      } else {
        if (_manager == null) return false;
        
        final List<int> bytes = utf8.encode(receipt);
        final List<int> cutCommand = [0x1D, 0x56, 0x01];

        // 1. Cash drawer pulse (Receipt printer only)
        final List<int> openDrawer = role == 'receipt'
            ? [0x1B, 0x70, 0x00, 0x19, 0x78, 0x1B, 0x70, 0x01, 0x19, 0x78]
            : [];

        // 2. WhatsApp QR code feedback URL (Receipt printer only)
        final List<int> qrBytes = role == 'receipt'
            ? _getQrCodeBytes(transaction['id'] as int? ?? 0)
            : [];

        await _manager!.printBytes([...openDrawer, ...bytes, ...qrBytes, ...cutCommand]);
      }

      _status = PrinterStatus.connected;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = e.toString();
      _status = PrinterStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Generate ESC/POS bytes for WhatsApp Feedback QR Code
  List<int> _getQrCodeBytes(int transactionId) {
    final cleanPhone = storePhone?.replaceAll(RegExp(r'\D'), '') ?? '628123456789';
    final url = 'https://wa.me/$cleanPhone?text=Feedback%20KlampisDepo%20No%20%23$transactionId';
    final List<int> dataBytes = utf8.encode(url);
    final int len = dataBytes.length + 3;
    final int pL = len % 256;
    final int pH = len ~/ 256;

    return [
      0x0A, 0x0A,
      // Center align
      0x1B, 0x61, 0x01,
      // Model 2 QR
      0x1D, 0x28, 0x6B, 0x04, 0x00, 0x31, 0x41, 0x32, 0x00,
      // Size 5
      0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x43, 0x05,
      // EC Level M
      0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x44, 0x31,
      // Store data
      0x1D, 0x28, 0x6B, pL, pH, 0x31, 0x50, 0x30, ...dataBytes,
      // Print QR code
      0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x51, 0x30,
      0x0A,
      ...utf8.encode('PINDAI UNTUK FEEDBACK WA'),
      0x0A,
      // Left align (default)
      0x1B, 0x61, 0x00,
      0x0A, 0x0A,
    ];
  }

  /// Share digital receipt via WhatsApp/Telegram
  Future<void> shareReceipt(Map<String, dynamic> transaction) async {
    final items = (transaction['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final DateTime date = transaction['created_at'] != null
        ? DateTime.parse(transaction['created_at'] as String).toLocal()
        : DateTime.now();

    final receipt = ReceiptFormatter.formatReceipt(
      storeName: storeName,
      transactionId: transaction['id'] as int? ?? 0,
      date: date,
      items: items,
      subtotal: _toDouble(transaction['subtotal'] ?? transaction['total']),
      discount: _toDouble(transaction['discount'] ?? 0),
      total: _toDouble(transaction['total'] ?? 0),
      paymentType: transaction['payment_type'] as String? ?? 'cash',
      paymentAmount: _toDouble(transaction['payment'] ?? transaction['total'] ?? 0),
      change: _toDouble(transaction['change'] ?? 0),
      note: transaction['note'] as String?,
      cashierName: cashierName,
      storeAddress: storeAddress,
      storePhone: storePhone,
    );

    await Share.share(receipt, subject: 'Struk Belanja #${transaction['id']}');
  }

  /// Print a receipt directly from current checkout state
  Future<bool> printCheckoutReceipt({
    required int transactionId,
    required List<Map<String, dynamic>> cartItems,
    required double subtotal,
    required double discount,
    required double total,
    required String paymentType,
    required double paymentAmount,
    required double change,
    String? note,
  }) async {
    final transaction = {
      'id': transactionId,
      'created_at': DateTime.now().toIso8601String(),
      'items': cartItems,
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
      'payment_type': paymentType,
      'payment': paymentAmount,
      'change': change,
      'note': note,
    };
    return printReceipt(transaction);
  }

  /// Get the formatted receipt text (for preview)
  String getReceiptPreview(Map<String, dynamic> transaction) {
    final items = (transaction['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return ReceiptFormatter.formatReceipt(
      storeName: storeName,
      transactionId: transaction['id'] as int? ?? 0,
      date: transaction['created_at'] != null
          ? DateTime.parse(transaction['created_at'] as String).toLocal()
          : DateTime.now(),
      items: items,
      subtotal: _toDouble(transaction['subtotal'] ?? transaction['total']),
      discount: _toDouble(transaction['discount'] ?? 0),
      total: _toDouble(transaction['total'] ?? 0),
      paymentType: transaction['payment_type'] as String? ?? 'cash',
      paymentAmount: _toDouble(transaction['payment'] ?? transaction['total'] ?? 0),
      change: _toDouble(transaction['change'] ?? 0),
      note: transaction['note'] as String?,
      cashierName: cashierName,
      storeAddress: storeAddress,
      storePhone: storePhone,
    );
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}

// ─── Providers ─────────────────────────────────────

final printerServiceProvider = ChangeNotifierProvider<PrinterService>((ref) {
  final service = PrinterService();
  service.fetchStoreInfo(ref);
  return service;
});
