import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/notification_helper.dart';

class RiwayatScreen extends ConsumerStatefulWidget {
  const RiwayatScreen({super.key});

  @override
  ConsumerState<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends ConsumerState<RiwayatScreen> {
  DateTime _selectedDate = DateTime.now();
  final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final historyDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      ref.read(paginatedHistoryProvider(historyDate).notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final paginatedState = ref.watch(paginatedHistoryProvider(historyDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(paginatedHistoryProvider(historyDate).notifier).refresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  'Tanggal: ${DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(paginatedHistoryProvider(historyDate).notifier).refresh();
              },
              child: paginatedState.history.isEmpty && paginatedState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : paginatedState.history.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 100),
                            Center(child: Text('Tidak ada transaksi di tanggal ini.')),
                          ],
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: paginatedState.history.length + (paginatedState.isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= paginatedState.history.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            final tx = paginatedState.history[index];
                            final status = tx['status'];
                            final isRefund = status == 'refunded';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('#${tx['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isRefund ? Colors.red[50] : Colors.green[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        status.toUpperCase(),
                                        style: TextStyle(
                                          color: isRefund ? Colors.red : Colors.green,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(_currencyFormat.format(tx['total']), style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                                    Text(_dateFormat.format(DateTime.parse(tx['created_at']))),
                                  ],
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => _ReceiptDetailDialog(tx: tx),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaginatedHistoryState {
  final List<dynamic> history;
  final int page;
  final bool hasMore;
  final bool isLoading;

  PaginatedHistoryState({
    required this.history,
    required this.page,
    required this.hasMore,
    required this.isLoading,
  });

  PaginatedHistoryState copyWith({
    List<dynamic>? history,
    int? page,
    bool? hasMore,
    bool? isLoading,
  }) {
    return PaginatedHistoryState(
      history: history ?? this.history,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PaginatedHistoryNotifier extends StateNotifier<PaginatedHistoryState> {
  final Ref ref;
  final String date;

  PaginatedHistoryNotifier(this.ref, this.date)
      : super(PaginatedHistoryState(history: [], page: 1, hasMore: true, isLoading: false)) {
    loadNextPage();
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);
    final dio = ref.read(dioProvider);

    try {
      final response = await dio.get('/transactions/history/by-date', queryParameters: {
        'date': date,
        'page': state.page,
        'limit': 10,
      });

      final List data = response.data['data'] ?? [];
      final List<dynamic> newHistory = data;

      state = state.copyWith(
        history: [...state.history, ...newHistory],
        page: state.page + 1,
        hasMore: newHistory.length == 10,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, hasMore: false);
    }
  }

  Future<void> refresh() async {
    state = PaginatedHistoryState(history: [], page: 1, hasMore: true, isLoading: false);
    await loadNextPage();
  }
}

final paginatedHistoryProvider = StateNotifierProvider.family<PaginatedHistoryNotifier, PaginatedHistoryState, String>((ref, date) {
  return PaginatedHistoryNotifier(ref, date);
});

final historyProvider = FutureProvider.family<List<dynamic>, String>((ref, date) async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get('/transactions/history/by-date', queryParameters: {
      'date': date,
    });
    return response.data['data'];
  } catch (e) {
    return [];
  }
});

class _ReceiptDetailDialog extends ConsumerWidget {
  final Map<String, dynamic> tx;
  const _ReceiptDetailDialog({required this.tx});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    final int id = tx['id'];
    final String status = tx['status'];
    final double total = (tx['total'] as num).toDouble();
    final double discount = (tx['discount'] as num?)?.toDouble() ?? 0.0;
    final String dateStr = tx['created_at'];
    final String formattedDate = dateFormat.format(DateTime.parse(dateStr));
    final String? note = tx['note'];
    final String paymentType = tx['payment_type'] ?? 'CASH';
    final double? paymentAmount = tx['payment'] != null ? (tx['payment'] as num).toDouble() : null;
    final double? change = tx['change'] != null ? (tx['change'] as num).toDouble() : null;
    final List items = tx['items'] ?? [];

    final double itemsTotal = items.fold(0.0, (sum, it) => sum + ((it['price'] as num).toDouble() * (it['quantity'] as num).toInt()));

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Transaksi #$id', style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Waktu: $formattedDate'),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('Status: '),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: status == 'refunded' ? Colors.red[50] : Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: status == 'refunded' ? Colors.red : Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              const Text('DAFTAR ITEM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              ...items.map((it) {
                final itemObj = it['item'] ?? {};
                final String itemName = itemObj['name'] ?? '-';
                final int qty = it['quantity'] ?? 1;
                final double price = (it['price'] as num).toDouble();
                final double subtotal = (it['subtotal'] as num).toDouble();

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('$qty x ${currencyFormat.format(price)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text(currencyFormat.format(subtotal)),
                    ],
                  ),
                );
              }),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal'),
                  Text(currencyFormat.format(itemsTotal)),
                ],
              ),
              if (discount > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Diskon', style: TextStyle(color: Colors.red)),
                    Text('- ${currencyFormat.format(discount)}', style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(currencyFormat.format(total), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).primaryColor)),
                ],
              ),
              const Divider(height: 24),
              Text('Metode Pembayaran: ${paymentType.toUpperCase()}'),
              if (paymentAmount != null) ...[
                const SizedBox(height: 4),
                Text('Uang Diterima: ${currencyFormat.format(paymentAmount)}'),
              ],
              if (change != null && change > 0) ...[
                const SizedBox(height: 4),
                Text('Kembalian: ${currencyFormat.format(change)}'),
              ],
              if (note != null && note.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Catatan: $note', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
              ],
              if (status == 'completed') ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.undo),
                    label: const Text('REFUND TRANSAKSI'),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Refund Transaksi?'),
                          content: const Text('Apakah Anda yakin ingin melakukan refund transaksi ini? Aksi ini akan mengembalikan stok item dan tidak dapat dibatalkan.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text('Refund'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        try {
                          final dio = ref.read(dioProvider);
                          await dio.post('/transactions/$id/refund');
                          
                          if (context.mounted) {
                            Navigator.pop(context); // Close receipt dialog
                            showTopSnackBar(
                              context,
                              'Transaksi berhasil di-refund!',
                            );
                            // Refresh history list
                            ref.invalidate(paginatedHistoryProvider);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            showTopSnackBar(
                              context,
                              'Gagal refund: $e',
                              backgroundColor: Colors.red[700],
                            );
                          }
                        }
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
