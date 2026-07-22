import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction_models.dart';
import '../../../../core/theme/notification_helper.dart';
import 'checkout_sheet_content.dart';

class CartPanel extends ConsumerWidget {
  const CartPanel({super.key});

  Future<void> _openScaleDialog(BuildContext context, WidgetRef ref, CartItem cartItem) async {
    double weight = 1.0;
    bool isScanning = true;
    bool isConnected = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (isScanning) {
              Future.delayed(const Duration(seconds: 1), () {
                if (context.mounted) {
                  setState(() {
                    isScanning = false;
                    isConnected = true;
                  });
                }
              });
            }

            final double calculatedPrice = cartItem.item.price * weight;
            final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.scale, color: Color(0xFF00AA5B)),
                  SizedBox(width: 8),
                  Text('Timbangan Bluetooth', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isScanning) ...[
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 16),
                    const Text('Mencari timbangan Bluetooth... ⚖️', style: TextStyle(fontStyle: FontStyle.italic)),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          '${weight.toStringAsFixed(2)} kg',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.greenAccent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bluetooth_connected, color: Colors.blue, size: 16),
                        SizedBox(width: 4),
                        Text('KD-Scale Pro Terhubung', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Harga Item: ${currencyFormat.format(cartItem.item.price)} / kg',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Subtotal Timbang: ${currencyFormat.format(calculatedPrice)}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    const Text('Simulasi Beban Timbangan (Geser Slider):', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Slider(
                      value: weight,
                      min: 0.1,
                      max: 10.0,
                      divisions: 99,
                      label: '${weight.toStringAsFixed(2)} kg',
                      onChanged: (val) {
                        setState(() {
                          weight = val;
                        });
                      },
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                if (!isScanning && isConnected)
                  ElevatedButton(
                    onPressed: () {
                      ref.read(transactionProvider.notifier).setCustomPrice(cartItem.item.id, calculatedPrice);
                      ref.read(transactionProvider.notifier).updateQuantity(cartItem.item.id, 1 - cartItem.quantity);
                      Navigator.pop(context);
                      showTopSnackBar(
                        context,
                        '⚖️ Hasil timbang ${weight.toStringAsFixed(2)} kg berhasil diterapkan!',
                      );
                    },
                    child: const Text('Gunakan Berat'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _editQuantity(BuildContext context, WidgetRef ref, CartItem item) async {
    final textController = TextEditingController(text: item.quantity.toString());
    final int? newQty = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Setel Jumlah ${item.item.name}'),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Jumlah',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(textController.text);
              if (val != null && val > 0) {
                Navigator.pop(context, val);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (newQty != null) {
      final difference = newQty - item.quantity;
      ref.read(transactionProvider.notifier).updateQuantity(item.item.id, difference);
    }
  }

  Future<void> _editCustomPrice(BuildContext context, WidgetRef ref, CartItem item) async {
    final textController = TextEditingController(
      text: item.customPrice != null 
          ? item.customPrice!.toStringAsFixed(0) 
          : item.item.price.toStringAsFixed(0),
    );
    final double? newPrice = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setel Harga Kustom'),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            prefixText: 'Rp ',
            labelText: 'Harga Baru',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          if (item.customPrice != null)
            TextButton(
              onPressed: () => Navigator.pop(context, -1.0),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Reset'),
            ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(textController.text);
              if (val != null && val >= 0) {
                Navigator.pop(context, val);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (newPrice != null) {
      if (newPrice < 0) {
        ref.read(transactionProvider.notifier).setCustomPrice(item.item.id, null);
      } else {
        ref.read(transactionProvider.notifier).setCustomPrice(item.item.id, newPrice);
      }
    }
  }

  Future<void> _editDiscount(BuildContext context, WidgetRef ref, double currentDiscount) async {
    final textController = TextEditingController(
      text: currentDiscount > 0 ? currentDiscount.toStringAsFixed(0) : '',
    );
    final double? newDiscount = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setel Diskon Transaksi'),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            prefixText: 'Rp ',
            labelText: 'Diskon Baru',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          if (currentDiscount > 0)
            TextButton(
              onPressed: () => Navigator.pop(context, 0.0),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus Diskon'),
            ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(textController.text) ?? 0.0;
              Navigator.pop(context, val);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (newDiscount != null) {
      ref.read(transactionProvider.notifier).setDiscount(newDiscount);
    }
  }

  Future<void> _editNote(BuildContext context, WidgetRef ref, String currentNote) async {
    final textController = TextEditingController(text: currentNote);
    final String? newNote = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambahkan Catatan Transaksi'),
        content: TextField(
          controller: textController,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Tulis catatan di sini...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          if (currentNote.isNotEmpty)
            TextButton(
              onPressed: () => Navigator.pop(context, ''),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus Catatan'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, textController.text.trim());
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (newNote != null) {
      ref.read(transactionProvider.notifier).setNote(newNote);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaksi = ref.watch(transactionProvider);
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final isTablet = MediaQuery.of(context).size.width > 900;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (!isTablet)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  Text(
                    'Keranjang (${transaksi.cart.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  ref.read(transactionProvider.notifier).reset();
                  if (!isTablet) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Bersihkan'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: transaksi.cart.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final item = transaksi.cart[index];
              return Dismissible(
                key: ValueKey(item.item.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  ref.read(transactionProvider.notifier).removeFromCart(item.item.id);
                  showTopSnackBar(
                    context,
                    '🗑️ "${item.item.name}" dihapus dari keranjang',
                  );
                },
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.item.name),
                  subtitle: InkWell(
                    onTap: () => _editCustomPrice(context, ref, item),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (item.customPrice != null) ...[
                            Text(currencyFormat.format(item.item.price), style: const TextStyle(decoration: TextDecoration.lineThrough, fontSize: 12, color: Colors.grey)),
                            const SizedBox(width: 4),
                          ],
                          Text(currencyFormat.format(item.currentPrice), style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 4),
                          const Icon(Icons.edit, size: 14, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.scale, color: Color(0xFF00AA5B)),
                        tooltip: 'Timbang Item',
                        onPressed: () => _openScaleDialog(context, ref, item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => ref.read(transactionProvider.notifier).updateQuantity(item.item.id, -1),
                      ),
                      InkWell(
                        onTap: () => _editQuantity(context, ref, item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.grey[50],
                          ),
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => ref.read(transactionProvider.notifier).updateQuantity(item.item.id, 1),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        tooltip: 'Hapus Item',
                        onPressed: () => ref.read(transactionProvider.notifier).removeFromCart(item.item.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(top: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Column(
            children: [
              // Interactive Tipe Transaksi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tipe Transaksi', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  DropdownButton<String>(
                    value: transaksi.transactionType,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'onsite', child: Text('Onsite (Ambil di Toko)', style: TextStyle(fontSize: 14))),
                      DropdownMenuItem(value: 'deliver', child: Text('Deliver (Kirim)', style: TextStyle(fontSize: 14))),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(transactionProvider.notifier).setTransactionType(val);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Interactive Notes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Catatan', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  InkWell(
                    onTap: () => _editNote(context, ref, transaksi.note ?? ''),
                    child: Row(
                      children: [
                        Container(
                          constraints: const BoxConstraints(maxWidth: 150),
                          child: Text(
                            transaksi.note != null && transaksi.note!.isNotEmpty ? transaksi.note! : 'Tambah Catatan',
                            style: TextStyle(
                              color: transaksi.note != null && transaksi.note!.isNotEmpty ? Colors.black87 : const Color(0xFF00AA5B),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: Color(0xFF00AA5B),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Interactive Discount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Diskon', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  InkWell(
                    onTap: () => _editDiscount(context, ref, transaksi.discount),
                    child: Row(
                      children: [
                        Text(
                          transaksi.discount > 0 ? '- ${currencyFormat.format(transaksi.discount)}' : 'Tambah Diskon',
                          style: TextStyle(
                            color: transaksi.discount > 0 ? Colors.red[700] : const Color(0xFF00AA5B),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: transaksi.discount > 0 ? Colors.red[700] : const Color(0xFF00AA5B),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  Text(currencyFormat.format(transaksi.totalBeforeDiscount), style: const TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  Text(currencyFormat.format(transaksi.finalTotal), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).primaryColor)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(transactionProvider.notifier).saveDraft();
                        if (!isTablet) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Draft'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: transaksi.cart.isEmpty ? null : () {
                        if (!isTablet) {
                          Navigator.pop(context);
                        }
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) => const CheckoutSheetContent(),
                        );
                      },
                      child: const Text('BAYAR'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
