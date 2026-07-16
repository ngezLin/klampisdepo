import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction_models.dart';
import '../../../../core/theme/notification_helper.dart';
import '../../../cash_session/providers/cash_session_provider.dart';
import '../../../history/ui/history_screen.dart';
import '../../../../services/printer/printer_service.dart';


class CheckoutSheetContent extends ConsumerStatefulWidget {
  const CheckoutSheetContent({super.key});

  @override
  ConsumerState<CheckoutSheetContent> createState() => _CheckoutSheetContentState();
}

class _CheckoutSheetContentState extends ConsumerState<CheckoutSheetContent> {
  late TextEditingController _paymentAmountController;
  late TextEditingController _discountController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(transactionProvider);
    _paymentAmountController = TextEditingController(text: state.finalTotal.toStringAsFixed(0));
    _discountController = TextEditingController(text: state.discount > 0 ? state.discount.toStringAsFixed(0) : '');
    _noteController = TextEditingController(text: state.note ?? '');

    // Set initial values in notifier
    Future.microtask(() {
      ref.read(transactionProvider.notifier).setPaymentAmount(state.finalTotal);
      ref.read(transactionProvider.notifier).setPaymentType('cash');
    });
  }

  @override
  void dispose() {
    _paymentAmountController.dispose();
    _discountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionProvider);
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Metode Pembayaran',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Payment type chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['cash', 'qris', 'debit', 'credit'].map((type) {
                final isSelected = state.paymentType == type;
                return ChoiceChip(
                  label: Text(type.toUpperCase()),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) {
                      ref.read(transactionProvider.notifier).setPaymentType(type);
                      if (type != 'cash') {
                        ref.read(transactionProvider.notifier).setPaymentAmount(state.finalTotal);
                        _paymentAmountController.text = state.finalTotal.toStringAsFixed(0);
                      }
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Note text field
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Catatan Transaksi (Opsional)',
                prefixIcon: Icon(Icons.notes),
              ),
              onChanged: (val) {
                ref.read(transactionProvider.notifier).setNote(val);
              },
            ),
            const SizedBox(height: 16),
            // Discount text field
            TextField(
              controller: _discountController,
              decoration: const InputDecoration(
                labelText: 'Diskon Tambahan (Rp)',
                prefixIcon: Icon(Icons.discount_outlined),
              ),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                final discount = double.tryParse(val) ?? 0;
                ref.read(transactionProvider.notifier).setDiscount(discount);
                
                // If payment type is not cash, update paymentAmount to finalTotal automatically
                if (state.paymentType != 'cash') {
                  final newTotal = state.totalBeforeDiscount - discount;
                  ref.read(transactionProvider.notifier).setPaymentAmount(newTotal);
                  _paymentAmountController.text = newTotal.toStringAsFixed(0);
                }
              },
            ),
            const SizedBox(height: 16),
            // Real cash input field
            if (state.paymentType == 'cash') ...[
              TextField(
                controller: _paymentAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Uang Diterima',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  final amt = double.tryParse(val) ?? 0;
                  ref.read(transactionProvider.notifier).setPaymentAmount(amt);
                },
              ),
              const SizedBox(height: 12),
              // Quick payment buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 40),
                      ),
                      onPressed: () {
                        ref.read(transactionProvider.notifier).setPaymentAmount(state.finalTotal);
                        _paymentAmountController.text = state.finalTotal.toStringAsFixed(0);
                      },
                      child: const Text('Pas'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 40),
                      ),
                      onPressed: () {
                        ref.read(transactionProvider.notifier).setPaymentAmount(50000);
                        _paymentAmountController.text = '50000';
                      },
                      child: const Text('50rb'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 40),
                      ),
                      onPressed: () {
                        ref.read(transactionProvider.notifier).setPaymentAmount(100000);
                        _paymentAmountController.text = '100000';
                      },
                      child: const Text('100rb'),
                    ),
                  ),
                ],
              ),
            ],
            const Divider(height: 32),
            // Calculations summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Belanja'),
                Text(currencyFormat.format(state.finalTotal), style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            if (state.paymentType == 'cash') ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kembalian'),
                  Text(
                    currencyFormat.format(state.change),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: state.change >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (state.paymentType == 'cash' && state.change < 0) || state.isSubmitting
                  ? null
                  : () async {
                      if (state.paymentType == 'cash') {
                        final sessionState = ref.read(cashSessionProvider);
                        if (!sessionState.isOpen) {
                          _showOpenSessionDialog(context);
                          return;
                        }
                      }

                      final notifier = ref.read(transactionProvider.notifier);
                      final result = await notifier.checkout();
                      if (result.success && context.mounted) {
                        ref.invalidate(historyProvider);
                        ref.invalidate(paginatedHistoryProvider);
                        Navigator.pop(context); // Close checkout sheet
                        _showSuccessDialog(context, result);
                      } else if (context.mounted) {
                        showTopSnackBar(
                          context,
                          result.errorMessage ?? 'Gagal checkout transaksi.',
                          backgroundColor: Colors.red[700],
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: state.isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('KONFIRMASI BAYAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showOpenSessionDialog(BuildContext sheetContext) {
    final cashController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: sheetContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (statefulContext, setState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.lock_open, color: Color(0xFF00AA5B)),
                  SizedBox(width: 8),
                  Text('Buka Shift Kasir', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Laci kas belum terbuka. Masukkan jumlah modal awal di laci kas untuk memulai shift.'),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: cashController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Modal Awal (Rupiah)',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Harap masukkan modal awal';
                        }
                        if (double.tryParse(val) == null) {
                          return 'Harus berupa angka';
                        }
                        if (double.parse(val) < 0) {
                          return 'Tidak boleh kurang dari 0';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setState(() => isSubmitting = true);
                          final startingCash = double.parse(cashController.text.trim());
                          final success = await ref.read(cashSessionProvider.notifier).openSession(startingCash);
                          setState(() => isSubmitting = false);
                          if (success && statefulContext.mounted) {
                            Navigator.pop(dialogContext); // Close open session dialog
                            showTopSnackBar(sheetContext, 'Shift Kasir Berhasil Dibuka!');
                            
                            // Re-trigger checkout since they successfully opened the session!
                             final result = await ref.read(transactionProvider.notifier).checkout();
                             if (result.success && sheetContext.mounted) {
                               ref.invalidate(historyProvider);
                               ref.invalidate(paginatedHistoryProvider);
                               Navigator.pop(sheetContext); // Close checkout sheet
                               _showSuccessDialog(sheetContext, result);
                             } else if (sheetContext.mounted) {
                              showTopSnackBar(
                                sheetContext,
                                result.errorMessage ?? 'Gagal checkout transaksi.',
                                backgroundColor: Colors.red[700],
                              );
                            }
                          } else if (statefulContext.mounted) {
                            final err = ref.read(cashSessionProvider).error ?? 'Gagal membuka shift.';
                            showTopSnackBar(statefulContext, err, backgroundColor: Colors.red[700]);
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Buka Shift'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, CheckoutResult result) {
    final txData = result.transactionData;
    if (txData == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
        final paymentType = txData['payment_type'] ?? 'cash';
        final total = (txData['total'] as num?)?.toDouble() ?? 0.0;
        final payment = (txData['payment'] as num?)?.toDouble() ?? 0.0;
        final change = (txData['change'] as num?)?.toDouble() ?? 0.0;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text('Transaksi Berhasil', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(result.wasOffline 
                ? 'Transaksi disimpan offline dan akan otomatis disinkronisasi saat koneksi kembali.' 
                : 'Transaksi berhasil disimpan.'),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Belanja:'),
                  Text(currencyFormat.format(total), style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              if (paymentType == 'cash') ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Uang Diterima:'),
                    Text(currencyFormat.format(payment)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kembalian:'),
                    Text(currencyFormat.format(change), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              const Divider(),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Bagikan'),
                    onPressed: () async {
                      await ref.read(printerServiceProvider).shareReceipt(txData);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.print, size: 18),
                    label: const Text('Cetak'),
                    onPressed: () async {
                      final printer = ref.read(printerServiceProvider);
                      if (printer.isConnected) {
                        final success = await printer.printReceipt(txData);
                        if (dialogContext.mounted) {
                          showTopSnackBar(
                            dialogContext,
                            success ? 'Struk berhasil dicetak!' : 'Gagal mencetak: ${printer.lastError}',
                            backgroundColor: success ? null : Colors.red[700],
                          );
                        }
                      } else {
                        showTopSnackBar(
                          dialogContext,
                          '⚠️ Printer belum terhubung! Silakan hubungkan printer di menu Transaksi.',
                          backgroundColor: Colors.amber[800],
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(dialogContext); // Close dialog
                },
                child: const Text('Tutup / Transaksi Baru', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }
}
