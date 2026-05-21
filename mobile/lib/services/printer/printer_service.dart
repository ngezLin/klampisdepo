import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart' as esc;
import '../../core/network/dio_client.dart';

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

  PrinterDevice? get connectedPrinter => _connectedPrinter;
  PrinterStatus get status => _status;
  String? get lastError => _lastError;
  bool get isConnected => _status == PrinterStatus.connected;

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
    // On web, we can't scan for printers
    if (kIsWeb) {
      return [
        PrinterDevice(
          name: 'Browser Print (Preview)',
          address: 'browser',
          type: PrinterConnectionType.network,
        ),
      ];
    }

    // For native, scan Bluetooth and Network
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
      // For web, just mark as connected (preview mode)
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

      // Convert our custom PrinterDevice back to esc.PrinterDevice
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

  /// Print a receipt for a transaction
  Future<bool> printReceipt(Map<String, dynamic> transaction) async {
    if (_status != PrinterStatus.connected) {
      _lastError = 'Printer belum terhubung';
      notifyListeners();
      return false;
    }

    _status = PrinterStatus.printing;
    notifyListeners();

    try {
      final items = (transaction['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final receipt = ReceiptFormatter.formatReceipt(
        storeName: storeName,
        transactionId: transaction['id'] as int? ?? 0,
        date: transaction['created_at'] != null
            ? DateTime.parse(transaction['created_at'] as String)
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

      if (kIsWeb || _connectedPrinter?.address == 'browser') {
        // On web, just print via debugPrint for preview
        debugPrint('══════ RECEIPT PREVIEW ══════');
        debugPrint(receipt);
        debugPrint('════════════════════════════');
      } else {
        if (_manager == null) return false;
        // Encode receipt text to UTF-8 bytes and send to printer with partial cut command (GS V 1)
        final List<int> bytes = utf8.encode(receipt);
        final List<int> cutCommand = [0x1D, 0x56, 0x01];
        await _manager!.printBytes([...bytes, ...cutCommand]);
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
          ? DateTime.parse(transaction['created_at'] as String)
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
