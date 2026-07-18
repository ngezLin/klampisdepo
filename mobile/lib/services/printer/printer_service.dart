import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart' as esc;
import '../../core/network/dio_client.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Configuration class for Receipt Customizer (Receipt Format Maker)
class ReceiptFormatConfig {
  final bool showLogo;
  final bool showAddress;
  final bool showPhone;
  final bool showFooter;
  final bool showNotes;
  final String customHeaderMessage;
  final String customFooterMessage;
  final int paperWidth; // lineWidth: 32 (58mm) or 48 (80mm)

  ReceiptFormatConfig({
    this.showLogo = true,
    this.showAddress = true,
    this.showPhone = true,
    this.showFooter = true,
    this.showNotes = true,
    this.customHeaderMessage = '',
    this.customFooterMessage = 'Terima kasih telah\nberbelanja!',
    this.paperWidth = 32,
  });

  ReceiptFormatConfig copyWith({
    bool? showLogo,
    bool? showAddress,
    bool? showPhone,
    bool? showFooter,
    bool? showNotes,
    String? customHeaderMessage,
    String? customFooterMessage,
    int? paperWidth,
  }) {
    return ReceiptFormatConfig(
      showLogo: showLogo ?? this.showLogo,
      showAddress: showAddress ?? this.showAddress,
      showPhone: showPhone ?? this.showPhone,
      showFooter: showFooter ?? this.showFooter,
      showNotes: showNotes ?? this.showNotes,
      customHeaderMessage: customHeaderMessage ?? this.customHeaderMessage,
      customFooterMessage: customFooterMessage ?? this.customFooterMessage,
      paperWidth: paperWidth ?? this.paperWidth,
    );
  }

  Map<String, dynamic> toJson() => {
        'showLogo': showLogo,
        'showAddress': showAddress,
        'showPhone': showPhone,
        'showFooter': showFooter,
        'showNotes': showNotes,
        'customHeaderMessage': customHeaderMessage,
        'customFooterMessage': customFooterMessage,
        'paperWidth': paperWidth,
      };

  factory ReceiptFormatConfig.fromJson(Map<String, dynamic> json) => ReceiptFormatConfig(
        showLogo: json['showLogo'] ?? true,
        showAddress: json['showAddress'] ?? true,
        showPhone: json['showPhone'] ?? true,
        showFooter: json['showFooter'] ?? true,
        showNotes: json['showNotes'] ?? true,
        customHeaderMessage: json['customHeaderMessage'] ?? '',
        customFooterMessage: json['customFooterMessage'] ?? 'Terima kasih telah\nberbelanja!',
        paperWidth: json['paperWidth'] ?? 32,
      );
}

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
    required ReceiptFormatConfig config,
  }) {
    final buffer = StringBuffer();
    final width = config.paperWidth;

    // ─── HEADER ──────────────────────────
    if (config.customHeaderMessage.isNotEmpty) {
      buffer.writeln(_center(config.customHeaderMessage, width));
    }
    buffer.writeln(_center(storeName.toUpperCase(), width));
    if (config.showAddress && storeAddress != null) {
      buffer.writeln(_center(storeAddress, width));
    }
    if (config.showPhone && storePhone != null) {
      buffer.writeln(_center(storePhone, width));
    }
    buffer.writeln(_divider('=', width));
    buffer.writeln(_dateFormat.format(date));
    buffer.writeln('No. Transaksi: #$transactionId');
    if (cashierName != null) buffer.writeln('Kasir: $cashierName');
    buffer.writeln(_divider('-', width));

    // ─── ITEMS ───────────────────────────
    for (final item in items) {
      final name = item['item_name'] as String? ??
          item['item']?['name'] as String? ??
          item['name'] as String? ??
          '-';
      final qty = (item['quantity'] as num?)?.toInt() ?? 1;
      final price = (item['price'] as num).toDouble();
      final itemSubtotal = (item['subtotal'] as num?)?.toDouble() ?? (qty * price);

      buffer.writeln(name);
      buffer.writeln(_columns(
        '  $qty x ${_currencyFormat.format(price)}',
        _currencyFormat.format(itemSubtotal),
        width,
      ));
    }

    buffer.writeln(_divider('-', width));

    // ─── TOTALS ──────────────────────────
    buffer.writeln(_columns('Subtotal', _currencyFormat.format(subtotal), width));
    if (discount > 0) {
      buffer.writeln(_columns('Diskon', '- ${_currencyFormat.format(discount)}', width));
    }
    buffer.writeln(_divider('-', width));
    buffer.writeln(_columns('TOTAL', _currencyFormat.format(total), width));
    buffer.writeln(_divider('=', width));

    // ─── PAYMENT ─────────────────────────
    buffer.writeln(_columns('Bayar (${paymentType.toUpperCase()})', _currencyFormat.format(paymentAmount), width));
    if (paymentType.toLowerCase() == 'cash' && change > 0) {
      buffer.writeln(_columns('Kembalian', _currencyFormat.format(change), width));
    }

    if (config.showNotes && note != null && note.isNotEmpty) {
      buffer.writeln(_divider('-', width));
      buffer.writeln('Catatan: $note');
    }

    buffer.writeln(_divider('=', width));

    // ─── FOOTER ──────────────────────────
    if (config.showFooter && config.customFooterMessage.isNotEmpty) {
      for (final line in config.customFooterMessage.split('\n')) {
        buffer.writeln(_center(line, width));
      }
    }
    buffer.writeln('');
    buffer.writeln('');
    buffer.writeln('');

    return buffer.toString();
  }

  /// Center text within the receipt width
  static String _center(String text, int width) {
    if (text.length >= width) return text;
    final padding = (width - text.length) ~/ 2;
    return ' ' * padding + text;
  }

  /// Create a divider line
  static String _divider(String char, int width) => char * width;

  /// Two-column layout (left-aligned and right-aligned)
  static String _columns(String left, String right, int width) {
    final available = width - right.length;
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
  final _storage = const FlutterSecureStorage();
  ReceiptFormatConfig formatConfig = ReceiptFormatConfig();

  Timer? _reconnectTimer;
  final List<Map<String, dynamic>> _printQueue = [];

  List<Map<String, dynamic>> get printQueue => _printQueue;

  void startAutoReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      if (_receiptPrinter != null && _status == PrinterStatus.disconnected) {
        debugPrint('Auto-reconnect timer: attempting background reconnect to designated receipt printer...');
        await connectToPrinter(_receiptPrinter!);
      }
    });
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    super.dispose();
  }

  Future<void> loadFormatConfig() async {
    try {
      final jsonStr = await _storage.read(key: 'receipt_format_config');
      if (jsonStr != null) {
        formatConfig = ReceiptFormatConfig.fromJson(jsonDecode(jsonStr));
      }

      // Load designated printers from local storage
      final receiptStr = await _storage.read(key: 'designated_receipt_printer');
      if (receiptStr != null) {
        final data = jsonDecode(receiptStr);
        _receiptPrinter = PrinterDevice(
          name: data['name'] ?? '',
          address: data['address'] ?? '',
          type: PrinterConnectionType.values.firstWhere(
            (e) => e.name == data['type'],
            orElse: () => PrinterConnectionType.bluetooth,
          ),
        );
      }

      final kitchenStr = await _storage.read(key: 'designated_kitchen_printer');
      if (kitchenStr != null) {
        final data = jsonDecode(kitchenStr);
        _kitchenPrinter = PrinterDevice(
          name: data['name'] ?? '',
          address: data['address'] ?? '',
          type: PrinterConnectionType.values.firstWhere(
            (e) => e.name == data['type'],
            orElse: () => PrinterConnectionType.bluetooth,
          ),
        );
      }

      notifyListeners();
      
      // Auto-connect to receipt printer if defined
      if (_receiptPrinter != null) {
        connectToPrinter(_receiptPrinter!);
      }
      
      startAutoReconnectTimer();
    } catch (e) {
      debugPrint('Failed to load format config or printers: $e');
    }
  }

  Future<void> updateFormatConfig(ReceiptFormatConfig newConfig) async {
    formatConfig = newConfig;
    notifyListeners();
    try {
      await _storage.write(key: 'receipt_format_config', value: jsonEncode(newConfig.toJson()));
    } catch (e) {
      debugPrint('Failed to save format config: $e');
    }
  }

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

  Future<bool> designatePrinter(PrinterDevice device, String role) async {
    if (role == 'receipt') {
      _receiptPrinter = device;
      await _storage.write(
        key: 'designated_receipt_printer',
        value: jsonEncode({
          'name': device.name,
          'address': device.address,
          'type': device.type.name,
        }),
      );
      final result = await connectToPrinter(device);
      notifyListeners();
      return result;
    } else if (role == 'kitchen') {
      _kitchenPrinter = device;
      await _storage.write(
        key: 'designated_kitchen_printer',
        value: jsonEncode({
          'name': device.name,
          'address': device.address,
          'type': device.type.name,
        }),
      );
      notifyListeners();
      return true;
    }
    return false;
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
      
      // Auto-flush any queued print jobs when reconnected
      processPrintQueue();
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
      _addToQueue(transaction, role);
      return false;
    }

    // Connect to target printer if needed
    if (_connectedPrinter?.address != targetPrinter.address) {
      final success = await connectToPrinter(targetPrinter);
      if (!success) {
        _addToQueue(transaction, role);
        return false;
      }
    }

    _status = PrinterStatus.printing;
    notifyListeners();

    try {
      final items = _parseItems(transaction['items']);
      final DateTime date = _parseDateTime(transaction['created_at']);

      final receipt = ReceiptFormatter.formatReceipt(
        storeName: storeName,
        transactionId: (transaction['id'] as num?)?.toInt() ?? 0,
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
        config: formatConfig,
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
            ? _getQrCodeBytes((transaction['id'] as num?)?.toInt() ?? 0)
            : [];

        await _manager!.printBytes([...openDrawer, ...bytes, ...qrBytes, ...cutCommand]);
      }

      _status = PrinterStatus.connected;
      notifyListeners();
      
      // Successfully printed, remove from queue if it exists there
      _removeFromQueue((transaction['id'] as num?)?.toInt() ?? 0, role);
      return true;
    } catch (e) {
      _lastError = e.toString();
      _status = PrinterStatus.error;
      notifyListeners();
      _addToQueue(transaction, role);
      return false;
    }
  }

  void _addToQueue(Map<String, dynamic> transaction, String role) {
    final txId = (transaction['id'] as num?)?.toInt() ?? 0;
    final exists = _printQueue.any((q) => ((q['transaction']['id'] as num?)?.toInt() ?? 0) == txId && q['role'] == role);
    if (!exists) {
      if (_printQueue.length >= 50) {
        debugPrint('Print queue is full (max 50). Discarding oldest print job.');
        _printQueue.removeAt(0);
      }
      _printQueue.add({
        'transaction': transaction,
        'role': role,
        'timestamp': DateTime.now().toIso8601String(),
      });
      notifyListeners();
      debugPrint('Added transaction #$txId to print queue. Queue size: ${_printQueue.length}');
    }
  }

  void _removeFromQueue(int txId, String role) {
    final index = _printQueue.indexWhere((q) => q['transaction']['id'] == txId && q['role'] == role);
    if (index != -1) {
      _printQueue.removeAt(index);
      notifyListeners();
      debugPrint('Removed transaction #$txId from print queue. Queue size: ${_printQueue.length}');
    }
  }

  Future<void> processPrintQueue() async {
    if (_printQueue.isEmpty) return;
    debugPrint('Processing print queue: ${_printQueue.length} jobs...');
    final jobsCopy = List<Map<String, dynamic>>.from(_printQueue);
    for (final job in jobsCopy) {
      final success = await printReceipt(job['transaction'], role: job['role']);
      if (!success) {
        // Stop if a print job fails again to prevent thundering herd print failures
        break;
      }
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
    final items = _parseItems(transaction['items']);
    final DateTime date = _parseDateTime(transaction['created_at']);

    final receipt = ReceiptFormatter.formatReceipt(
      storeName: storeName,
      transactionId: (transaction['id'] as num?)?.toInt() ?? 0,
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
      config: formatConfig,
    );

    await SharePlus.instance.share(ShareParams(text: receipt, subject: 'Struk Belanja #${transaction['id']}'));
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
    final items = _parseItems(transaction['items']);
    return ReceiptFormatter.formatReceipt(
      storeName: storeName,
      transactionId: (transaction['id'] as num?)?.toInt() ?? 0,
      date: _parseDateTime(transaction['created_at']),
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
      config: formatConfig,
    );
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  List<Map<String, dynamic>> _parseItems(dynamic rawItems) {
    final List<Map<String, dynamic>> result = [];
    if (rawItems != null && rawItems is List) {
      for (final it in rawItems) {
        if (it is Map) {
          result.add(Map<String, dynamic>.from(it));
        }
      }
    }
    return result;
  }
}

// ─── Providers ─────────────────────────────────────

final printerServiceProvider = ChangeNotifierProvider<PrinterService>((ref) {
  final service = PrinterService();
  service.fetchStoreInfo(ref).then((_) => service.loadFormatConfig());
  return service;
});

DateTime _parseDateTime(dynamic raw) {
  if (raw == null) return DateTime.now();
  if (raw is DateTime) return raw;
  if (raw is num) {
    final value = raw.toInt();
    if (value > 9999999999) {
      return DateTime.fromMillisecondsSinceEpoch(value).toLocal();
    }
    return DateTime.fromMillisecondsSinceEpoch(value * 1000).toLocal();
  }
  final str = raw.toString().trim();
  if (str.isEmpty) return DateTime.now();
  final parsedInt = int.tryParse(str);
  if (parsedInt != null) {
    if (parsedInt > 9999999999) {
      return DateTime.fromMillisecondsSinceEpoch(parsedInt).toLocal();
    }
    return DateTime.fromMillisecondsSinceEpoch(parsedInt * 1000).toLocal();
  }
  try {
    if (!str.contains('Z') && !str.contains('+') && !RegExp(r'-\d{2}:\d{2}$').hasMatch(str)) {
      final formatted = str.replaceAll(' ', 'T') + 'Z';
      return DateTime.parse(formatted).toLocal();
    }
    return DateTime.parse(str).toLocal();
  } catch (_) {
    try {
      return DateTime.parse(str).toLocal();
    } catch (_) {
      return DateTime.now();
    }
  }
}
