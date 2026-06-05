import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/printer/printer_service.dart';
import '../../../../core/theme/notification_helper.dart';

class PrinterSetupDialog extends ConsumerStatefulWidget {
  const PrinterSetupDialog({super.key});

  @override
  ConsumerState<PrinterSetupDialog> createState() => _PrinterSetupDialogState();
}

class _PrinterSetupDialogState extends ConsumerState<PrinterSetupDialog> {
  List<PrinterDevice> _devices = [];
  bool _isScanning = false;
  final _ipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scan();
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    setState(() => _isScanning = true);
    final printer = ref.read(printerServiceProvider);
    final devices = await printer.scanPrinters();
    if (mounted) {
      setState(() {
        _devices = devices;
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final printer = ref.watch(printerServiceProvider);

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Pengaturan Printer'),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: printer.isConnected ? const Color(0xFFE5F7EE) : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: printer.isConnected ? const Color(0xFF00AA5B) : Colors.grey[300]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    printer.isConnected ? Icons.check_circle : Icons.print_disabled,
                    color: printer.isConnected ? const Color(0xFF00AA5B) : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      printer.isConnected
                          ? 'Terhubung: ${printer.connectedPrinter?.name}'
                          : 'Belum terhubung',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: printer.isConnected ? const Color(0xFF00AA5B) : Colors.grey[600],
                      ),
                    ),
                  ),
                  if (printer.isConnected)
                    TextButton(
                      onPressed: () => printer.disconnect(),
                      child: const Text('Putuskan', style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ),

            if (!printer.isConnected) ...[
              const SizedBox(height: 16),

              // Manual IP input
              TextField(
                controller: _ipController,
                decoration: InputDecoration(
                  labelText: 'IP Printer (contoh: 192.168.1.100)',
                  hintText: '192.168.1.100:9100',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.link),
                    onPressed: () async {
                      final ip = _ipController.text.trim();
                      if (ip.isNotEmpty) {
                        final device = PrinterDevice(
                          name: 'Network Printer',
                          address: ip.contains(':') ? ip : '$ip:9100',
                          type: PrinterConnectionType.network,
                        );
                        final success = await printer.connectToPrinter(device);
                        if (mounted && success) {
                          showTopSnackBar(
                            context,
                            'Printer terhubung!',
                          );
                        }
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // Discovered printers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Printer Ditemukan', style: TextStyle(fontWeight: FontWeight.bold)),
                  _isScanning
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : IconButton(icon: const Icon(Icons.refresh), onPressed: _scan),
                ],
              ),

              if (_devices.isEmpty && !_isScanning)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Tidak ada printer ditemukan.\nGunakan IP manual di atas.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                ),

              ..._devices.map((device) => ListTile(
                leading: Icon(
                  device.type == PrinterConnectionType.bluetooth
                      ? Icons.bluetooth
                      : Icons.wifi,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(device.name),
                subtitle: Text(device.address),
                onTap: () async {
                  final success = await printer.connectToPrinter(device);
                  if (mounted && success) {
                    showTopSnackBar(
                      context,
                      'Printer terhubung!',
                    );
                  }
                },
              )),
            ],

            if (printer.isConnected) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.print),
                label: const Text('Test Print'),
                onPressed: () async {
                  final success = await printer.printReceipt({
                    'id': 0,
                    'created_at': DateTime.now().toIso8601String(),
                    'items': [
                      {'item_name': 'Test Item', 'quantity': 1, 'price': 10000, 'subtotal': 10000},
                    ],
                    'subtotal': 10000,
                    'discount': 0,
                    'total': 10000,
                    'payment_type': 'cash',
                    'payment': 10000,
                    'change': 0,
                  });
                  if (mounted) {
                    showTopSnackBar(
                      context,
                      success ? 'Test print berhasil!' : 'Gagal print: ${printer.lastError}',
                      backgroundColor: success ? null : Colors.red[700],
                    );
                  }
                },
              ),
            ],

            if (printer.lastError != null) ...[
              const SizedBox(height: 8),
              Text('Error: ${printer.lastError}', style: const TextStyle(color: Colors.red, fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }
}
