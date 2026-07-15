import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../providers/transaction_provider.dart';
import '../../item/providers/item_provider.dart';
import '../../../services/sync/offline_sync_service.dart';
import '../../../core/theme/notification_helper.dart';
import 'widgets/item_card.dart';
import 'widgets/cart_panel.dart';
import 'widgets/drafts_dialog.dart';
import 'widgets/printer_setup_dialog.dart';
import 'widgets/conflict_resolution_dialog.dart';

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchScrollFocusNodeDispose();
    super.dispose();
  }

  void _searchScrollFocusNodeDispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final searchQuery = ref.read(transactionSearchQueryProvider);
      ref.read(paginatedItemsProvider(searchQuery).notifier).loadNextPage();
    }
  }

  void _handleBarcodeScan(String val) {
    if (val.trim().isEmpty) return;
    final searchQuery = ref.read(transactionSearchQueryProvider);
    final paginatedState = ref.read(paginatedItemsProvider(searchQuery));

    if (paginatedState.items.length == 1) {
      final matchedItem = paginatedState.items.first;
      ref.read(transactionProvider.notifier).addToCart(matchedItem);
      showTopSnackBar(
        context,
        '📥 "${matchedItem.name}" ditambahkan!',
      );
      _searchController.clear();
      ref.read(transactionSearchQueryProvider.notifier).state = '';
      _searchFocusNode.requestFocus();
    } else {
      _searchFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(transactionSearchQueryProvider);
    final paginatedState = ref.watch(paginatedItemsProvider(searchQuery));
    final transaksi = ref.watch(transactionProvider);
    final isTablet = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        actions: [
          // Persistent sync status indicator
          Consumer(
            builder: (context, ref, _) {
              final syncStatus = ref.watch(syncStatusStateProvider);
              final pendingCount = ref.watch(pendingSyncCountProvider).valueOrNull ?? 0;
              final conflictCount = ref.watch(conflictCountProvider).valueOrNull ?? 0;

              switch (syncStatus) {
                case AppSyncStatus.synced:
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Tooltip(
                      message: 'Synced ✅',
                      child: Icon(Icons.cloud_done, color: Colors.green),
                    ),
                  );
                case AppSyncStatus.syncing:
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
                    ),
                  );
                case AppSyncStatus.pendingSync:
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: IconButton(
                      icon: Badge(
                        label: Text('$pendingCount'),
                        backgroundColor: Colors.orange,
                        child: const Icon(Icons.cloud_upload_outlined, color: Colors.orange),
                      ),
                      tooltip: 'Pending sync ⏳ (Ketuk untuk sync sekarang)',
                      onPressed: () async {
                        final result = await ref.read(transactionProvider.notifier).syncNow();
                        if (context.mounted) {
                          showTopSnackBar(
                            context,
                            'Sync selesai: ${result.synced} berhasil, ${result.failed} gagal',
                          );
                        }
                      },
                    ),
                  );
                case AppSyncStatus.conflict:
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: IconButton(
                      icon: Badge(
                        label: Text('$conflictCount'),
                        backgroundColor: Colors.red,
                        child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                      ),
                      tooltip: 'Konflik harga terdeteksi! ⚠️ (Ketuk untuk selesaikan)',
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const ConflictResolutionDialog(),
                        );
                      },
                    ),
                  );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const PrinterSetupDialog(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.folder_open_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const DraftsDialog(),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Item Selection Area
          Expanded(
            flex: isTablet ? 6 : 1,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SearchBar(
                    focusNode: _searchFocusNode,
                    controller: _searchController,
                    hintText: 'Cari item...',
                    leading: const Icon(Icons.search),
                    onChanged: (val) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        if (mounted) {
                          ref.read(transactionSearchQueryProvider.notifier).state = val;
                        }
                      });
                    },
                    onSubmitted: (val) {
                      _handleBarcodeScan(val);
                    },
                  ),
                ),
                Expanded(
                  child: paginatedState.items.isEmpty && paginatedState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : paginatedState.items.isEmpty
                          ? const Center(child: Text('Tidak ada item ditemukan.'))
                          : GridView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(12),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isTablet ? 4 : 2,
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: paginatedState.items.length + (paginatedState.isLoading ? 2 : 0),
                              itemBuilder: (context, index) {
                                if (index >= paginatedState.items.length) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                return ItemCard(
                                  item: paginatedState.items[index],
                                  onTap: () => ref.read(transactionProvider.notifier).addToCart(paginatedState.items[index]),
                                );
                              },
                            ),
                ),
                if (!isTablet && transaksi.cart.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) => SizedBox(
                            height: MediaQuery.of(context).size.height * 0.80,
                            child: const CartPanel(),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                'Lihat Keranjang (${transaksi.cart.length})',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          Text(
                            _currencyFormat.format(transaksi.finalTotal),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Cart Area (Visible only on Tablet)
          if (isTablet)
            Container(
              width: 350,
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Colors.grey[200]!)),
                color: Colors.white,
              ),
              child: const CartPanel(),
            ),
        ],
      ),
      bottomSheet: null,
    );
  }
}
