import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/notification_helper.dart';
import '../../../services/printer/printer_service.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
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
                                    Text(_dateFormat.format(_parseDateTime(tx['created_at']))),
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
    final dynamic dateVal = tx['created_at'];
    final String formattedDate = dateFormat.format(_parseDateTime(dateVal));
    final String? note = tx['note'];
    final String paymentType = tx['payment_type'] ?? 'CASH';
    final double? paymentAmount = tx['payment'] != null ? (tx['payment'] as num).toDouble() : null;
    final double? change = tx['change'] != null ? (tx['change'] as num).toDouble() : null;
    final List items = tx['items'] ?? [];

    final double itemsTotal = items.fold(0.0, (sum, it) => sum + ((it['price'] as num).toDouble() * (it['quantity'] as num).toInt()));

    final GlobalKey receiptKey = GlobalKey();
    final printer = ref.watch(printerServiceProvider);

    return Stack(
      children: [
        AlertDialog(
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
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.print),
                        label: const Text('CETAK STRUK (REPRINT)'),
                        onPressed: () async {
                          final printer = ref.read(printerServiceProvider);
                          if (printer.isConnected) {
                            final success = await printer.printReceipt(tx);
                            if (context.mounted) {
                              showTopSnackBar(
                                context,
                                success ? 'Struk berhasil dicetak!' : 'Gagal mencetak: ${printer.lastError}',
                                backgroundColor: success ? null : Colors.red[700],
                              );
                            }
                          } else {
                            showTopSnackBar(
                              context,
                              '⚠️ Printer belum terhubung! Silakan hubungkan printer di menu Transaksi.',
                              backgroundColor: Colors.amber[800],
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text('BAGIKAN STRUK (DIGITAL)'),
                        onPressed: () async {
                          try {
                            RenderRepaintBoundary boundary = receiptKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                            ui.Image image = await boundary.toImage(pixelRatio: 3.0);
                            ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                            ui.PlatformDispatcher.instance.views.first; // Warm up ui metrics if needed
                            Uint8List pngBytes = byteData!.buffer.asUint8List();

                            final tempDir = await getTemporaryDirectory();
                            final file = await File('${tempDir.path}/struk_$id.png').create();
                            await file.writeAsBytes(pngBytes);

                            await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], subject: 'Struk Belanja #$id'));
                          } catch (e) {
                            debugPrint('Error sharing receipt image: $e');
                            if (context.mounted) {
                              await ref.read(printerServiceProvider).shareReceipt(tx);
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
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
        ),
        Positioned(
          left: -9999,
          child: RepaintBoundary(
            key: receiptKey,
            child: Container(
              width: 320,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Material(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        printer.storeName.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    if (printer.formatConfig.showAddress && printer.storeAddress != null)
                      Center(
                        child: Text(
                          printer.storeAddress!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, color: Colors.black, fontFamily: 'monospace'),
                        ),
                      ),
                    if (printer.formatConfig.showPhone && printer.storePhone != null)
                      Center(
                        child: Text(
                          printer.storePhone!,
                          style: const TextStyle(fontSize: 11, color: Colors.black, fontFamily: 'monospace'),
                        ),
                      ),
                    const SizedBox(height: 8),
                    const Text(
                      '================================',
                      style: TextStyle(color: Colors.black, fontSize: 11, fontFamily: 'monospace'),
                    ),
                    Text(
                      'Waktu: $formattedDate',
                      style: const TextStyle(fontSize: 11, color: Colors.black, fontFamily: 'monospace'),
                    ),
                    Text(
                      'No. Transaksi: #$id',
                      style: const TextStyle(fontSize: 11, color: Colors.black, fontFamily: 'monospace'),
                    ),
                    const Text(
                      '--------------------------------',
                      style: TextStyle(color: Colors.black, fontSize: 11, fontFamily: 'monospace'),
                    ),
                    const Text(
                      'DAFTAR ITEM',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black, fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 4),
                    ...items.map((it) {
                      final itemObj = it['item'] ?? {};
                      final String itemName = itemObj['name'] ?? '-';
                      final int qty = it['quantity'] ?? 1;
                      final double price = (it['price'] as num).toDouble();
                      final double subtotal = (it['subtotal'] as num).toDouble();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            itemName,
                            style: const TextStyle(fontSize: 11, color: Colors.black, fontFamily: 'monospace'),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '  $qty x ${currencyFormat.format(price)}',
                                style: const TextStyle(fontSize: 11, color: Colors.black, fontFamily: 'monospace'),
                              ),
                              Text(
                                currencyFormat.format(subtotal),
                                style: const TextStyle(fontSize: 11, color: Colors.black, fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                    const Text(
                      '--------------------------------',
                      style: TextStyle(color: Colors.black, fontSize: 11, fontFamily: 'monospace'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Subtotal',
                          style: TextStyle(fontSize: 11, color: Colors.black, fontFamily: 'monospace'),
                        ),
                        Text(
                          currencyFormat.format(itemsTotal),
                          style: const TextStyle(fontSize: 11, color: Colors.black, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                    if (discount > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Diskon',
                            style: TextStyle(fontSize: 11, color: Colors.black, fontFamily: 'monospace'),
                          ),
                          Text(
                            '- ${currencyFormat.format(discount)}',
                            style: const TextStyle(fontSize: 11, color: Colors.black, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    const Text(
                      '--------------------------------',
                      style: TextStyle(color: Colors.black, fontSize: 11, fontFamily: 'monospace'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black, fontFamily: 'monospace'),
                        ),
                        Text(
                          currencyFormat.format(total),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                    const Text(
                      '================================',
                      style: TextStyle(color: Colors.black, fontSize: 11, fontFamily: 'monospace'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bayar (${paymentType.toUpperCase()})',
                          style: const TextStyle(fontSize: 11, color: Colors.black, fontFamily: 'monospace'),
                        ),
                        if (paymentAmount != null)
                          Text(
                            currencyFormat.format(paymentAmount),
                            style: const TextStyle(fontSize: 11, color: Colors.black, fontFamily: 'monospace'),
                          ),
                      ],
                    ),
                    if (change != null && change > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kembalian',
                            style: TextStyle(fontSize: 11, color: Colors.black, fontFamily: 'monospace'),
                          ),
                          Text(
                            currencyFormat.format(change),
                            style: const TextStyle(fontSize: 11, color: Colors.black, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    if (note != null && note.isNotEmpty) ...[
                      const Text(
                        '--------------------------------',
                        style: TextStyle(color: Colors.black, fontSize: 11, fontFamily: 'monospace'),
                      ),
                      Text(
                        'Catatan: $note',
                        style: const TextStyle(fontSize: 11, color: Colors.black, fontFamily: 'monospace'),
                      ),
                    ],
                    const Text(
                      '================================',
                      style: TextStyle(color: Colors.black, fontSize: 11, fontFamily: 'monospace'),
                    ),
                    if (printer.formatConfig.showFooter && printer.formatConfig.customFooterMessage.isNotEmpty)
                      ...printer.formatConfig.customFooterMessage.split('\n').map((line) => Center(
                        child: Text(
                          line,
                          style: const TextStyle(fontSize: 11, color: Colors.black, fontFamily: 'monospace'),
                        ),
                      )),
                  ],
                ),
              ),
            ),
          ),
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
