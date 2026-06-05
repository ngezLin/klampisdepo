import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../services/sync/offline_sync_service.dart';

class ConflictResolutionDialog extends ConsumerStatefulWidget {
  const ConflictResolutionDialog({super.key});

  @override
  ConsumerState<ConflictResolutionDialog> createState() => _ConflictResolutionDialogState();
}

class _ConflictResolutionDialogState extends ConsumerState<ConflictResolutionDialog> {
  bool _isLoading = true;
  List<dynamic> _conflictedTxs = [];

  @override
  void initState() {
    super.initState();
    _loadConflicts();
  }

  Future<void> _loadConflicts() async {
    setState(() => _isLoading = true);
    final db = ref.read(appDatabaseProvider);
    final conflicted = await (db.select(db.transactions)
          ..where((t) => t.syncStatus.equals('conflict')))
        .get();

    if (mounted) {
      setState(() {
        _conflictedTxs = conflicted;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 8),
          Text('Konflik Harga Offline', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 450,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _conflictedTxs.isEmpty
                ? const Center(child: Text('Semua konflik telah diselesaikan!'))
                : ListView.separated(
                    itemCount: _conflictedTxs.length,
                    separatorBuilder: (_, __) => const Divider(height: 32),
                    itemBuilder: (context, index) {
                      final tx = _conflictedTxs[index];
                      final int txId = tx.id;
                      final List<dynamic> conflicts = json.decode(tx.conflictDetails ?? '[]');

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transaksi #$txId (Total Offline: ${currencyFormat.format(tx.total)})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          ...conflicts.map((c) {
                            final itemName = c['item_name'] ?? '-';
                            final double checkoutPrice = (c['checkout_price'] as num).toDouble();
                            final double serverPrice = (c['server_price'] as num).toDouble();
                            final int qty = (c['quantity'] as num).toInt();

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(itemName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Offline ($qty x): ${currencyFormat.format(checkoutPrice)}', style: const TextStyle(color: Colors.red, fontSize: 12)),
                                      Text('Server: ${currencyFormat.format(serverPrice)}', style: const TextStyle(color: Colors.green, fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () async {
                                  setState(() => _isLoading = true);
                                  await ref.read(offlineSyncServiceProvider).resolveConflictKeepOffline(txId);
                                  await _loadConflicts();
                                },
                                child: const Text('Tetap Harga Offline', style: TextStyle(fontSize: 12)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  setState(() => _isLoading = true);
                                  await ref.read(offlineSyncServiceProvider).resolveConflictUseServerPrice(txId);
                                  await _loadConflicts();
                                },
                                child: const Text('Gunakan Harga Server', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
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
