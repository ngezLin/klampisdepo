import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/transaction_provider.dart';
import '../../../../core/theme/notification_helper.dart';
import '../../../../services/printer/printer_service.dart';

class DraftsDialog extends ConsumerWidget {
  const DraftsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftsAsync = ref.watch(draftsProvider);
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return AlertDialog(
      title: const Text('Transaksi Draft'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: draftsAsync.when(
          data: (drafts) {
            if (drafts.isEmpty) {
              return const Center(child: Text('Tidak ada draft transaksi.'));
            }
            return ListView.separated(
              itemCount: drafts.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final draft = drafts[index] as Map<String, dynamic>;
                final int id = (draft['id'] as num).toInt();
                final double total = (draft['total'] as num).toDouble();
                final String dateStr = draft['created_at'] as String;
                final String formattedDate = dateFormat.format(_parseDateTime(dateStr));
                final String? note = draft['note'] as String?;
                final itemsList = draft['items'] as List<dynamic>;

                return InkWell(
                  onTap: () {
                    ref.read(transactionProvider.notifier).loadDraft(draft);
                    Navigator.pop(context);
                    showTopSnackBar(
                      context,
                      'Draft #$id berhasil dimuat!',
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Draft #$id',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$formattedDate\n${itemsList.length} item | ${note ?? "Tanpa catatan"}',
                                style: const TextStyle(color: Colors.grey, fontSize: 11, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currencyFormat.format(total),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.print_outlined, color: Colors.blue, size: 20),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () async {
                                    final printer = ref.read(printerServiceProvider);
                                    if (printer.isConnected) {
                                      final draftTransaction = {
                                        'id': id,
                                        'created_at': dateStr,
                                        'items': itemsList.map((it) {
                                          final itemObj = it['item'] ?? {};
                                          return {
                                            'item_name': itemObj['name'] ?? it['name'] ?? '-',
                                            'quantity': it['quantity'] ?? 1,
                                            'price': it['price'] ?? 0.0,
                                            'subtotal': it['subtotal'] ?? 0.0,
                                          };
                                        }).toList(),
                                        'subtotal': total,
                                        'discount': (draft['discount'] as num?)?.toDouble() ?? 0.0,
                                        'total': total,
                                        'payment_type': 'draft',
                                        'payment': total,
                                        'change': 0.0,
                                        'note': note,
                                      };
                                      final success = await printer.printReceipt(draftTransaction);
                                      if (context.mounted) {
                                        showTopSnackBar(
                                          context,
                                          success ? 'Draft berhasil dicetak!' : 'Gagal mencetak: ${printer.lastError}',
                                          backgroundColor: success ? null : Colors.red[700],
                                        );
                                      }
                                    } else {
                                      showTopSnackBar(
                                        context,
                                        '⚠️ Printer belum terhubung! Silakan hubungkan printer.',
                                        backgroundColor: Colors.amber[800],
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Hapus Draft?'),
                                        content: const Text('Apakah Anda yakin ingin menghapus draft ini?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await ref.read(transactionProvider.notifier).deleteDraft(id);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}

DateTime _parseDateTime(dynamic raw) {
  if (raw == null) return DateTime.now();
  if (raw is DateTime) return raw;
  if (raw is num) {
    return DateTime.fromMillisecondsSinceEpoch(raw.toInt() * 1000).toLocal();
  }
  final str = raw.toString().trim();
  if (str.isEmpty) return DateTime.now();
  final parsedInt = int.tryParse(str);
  if (parsedInt != null) {
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
