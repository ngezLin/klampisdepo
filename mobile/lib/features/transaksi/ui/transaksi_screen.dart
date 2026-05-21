import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/transaksi_provider.dart';
import '../models/transaction_models.dart';
import '../../item/providers/item_provider.dart';
import '../../../services/sync/offline_sync_service.dart';
import '../../../services/printer/printer_service.dart';
import '../../riwayat/ui/riwayat_screen.dart';
import '../../../core/theme/notification_helper.dart';

class TransaksiScreen extends ConsumerStatefulWidget {
  const TransaksiScreen({super.key});

  @override
  ConsumerState<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends ConsumerState<TransaksiScreen> {
  final _searchController = TextEditingController();
  final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final searchQuery = ref.read(transaksiSearchQueryProvider);
      ref.read(paginatedItemsProvider(searchQuery).notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(transaksiSearchQueryProvider);
    final paginatedState = ref.watch(paginatedItemsProvider(searchQuery));
    final transaksi = ref.watch(transaksiProvider);
    final isTablet = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        actions: [
          // Pending sync badge
          Consumer(
            builder: (context, ref, _) {
              final pendingCount = ref.watch(pendingSyncCountProvider);
              return pendingCount.when(
                data: (count) {
                  if (count == 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: IconButton(
                      icon: Badge(
                        label: Text('$count'),
                        backgroundColor: Colors.orange,
                        child: const Icon(Icons.cloud_off_outlined),
                      ),
                      tooltip: '$count transaksi menunggu sync',
                      onPressed: () async {
                        final result = await ref.read(transaksiProvider.notifier).syncNow();
                        if (context.mounted) {
                          showTopSnackBar(
                            context,
                            'Sync selesai: ${result.synced} berhasil, ${result.failed} gagal',
                          );
                        }
                      },
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const _PrinterSetupDialog(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.folder_open_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const _DraftsDialog(),
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
                    controller: _searchController,
                    hintText: 'Cari item...',
                    leading: const Icon(Icons.search),
                    onChanged: (val) {
                      ref.read(transaksiSearchQueryProvider.notifier).state = val;
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
                                return _ItemCard(
                                  item: paginatedState.items[index],
                                  onTap: () => ref.read(transaksiProvider.notifier).addToCart(paginatedState.items[index]),
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
                            child: const _CartPanel(),
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
              child: const _CartPanel(),
            ),
        ],
      ),
      bottomSheet: null,
    );
  }
}

class _ItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onTap;

  const _ItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final isOutOfStock = item.isStockManaged && (item.stock <= 0);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (isOutOfStock) {
            showTopSnackBar(
              context,
              '⚠️ Stok "${item.name}" sedang habis! Silakan restock terlebih dahulu.',
              backgroundColor: Colors.red[700],
            );
          } else {
            onTap();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (item.imageUrl != null)
                    CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey[100]),
                      errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
                    )
                  else
                    Container(
                      color: Colors.grey[100],
                      child: const Icon(Icons.inventory_2, color: Colors.grey),
                    ),
                  if (item.isStockManaged)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOutOfStock 
                              ? Colors.red.withOpacity(0.9)
                              : (item.stock < 5 ? Colors.amber[700] : const Color(0xFF00AA5B)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isOutOfStock 
                              ? 'Habis' 
                              : (item.stock < 5 ? '${item.stock} Tipis' : '${item.stock} Stok'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (isOutOfStock)
                    Container(
                      color: Colors.black45,
                      child: const Center(
                        child: Text(
                          'HABIS',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(item.price),
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartPanel extends ConsumerWidget {
  const _CartPanel();

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
        ref.read(transaksiProvider.notifier).setCustomPrice(item.item.id, null);
      } else {
        ref.read(transaksiProvider.notifier).setCustomPrice(item.item.id, newPrice);
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
      ref.read(transaksiProvider.notifier).setDiscount(newDiscount);
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
      ref.read(transaksiProvider.notifier).setNote(newNote);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaksi = ref.watch(transaksiProvider);
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
                  ref.read(transaksiProvider.notifier).reset();
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
              return ListTile(
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
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => ref.read(transaksiProvider.notifier).updateQuantity(item.item.id, -1),
                    ),
                    Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => ref.read(transaksiProvider.notifier).updateQuantity(item.item.id, 1),
                    ),
                  ],
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
                      DropdownMenuItem(value: 'onsite', child: Text('Onsite (Makan di Sini)', style: TextStyle(fontSize: 14))),
                      DropdownMenuItem(value: 'deliver', child: Text('Deliver (Kirim)', style: TextStyle(fontSize: 14))),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(transaksiProvider.notifier).setTransactionType(val);
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
                        ref.read(transaksiProvider.notifier).saveDraft();
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
                          builder: (context) => const _CheckoutSheetContent(),
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

class _CheckoutSheetContent extends ConsumerStatefulWidget {
  const _CheckoutSheetContent();

  @override
  ConsumerState<_CheckoutSheetContent> createState() => _CheckoutSheetContentState();
}

class _CheckoutSheetContentState extends ConsumerState<_CheckoutSheetContent> {
  late TextEditingController _paymentAmountController;
  late TextEditingController _discountController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(transaksiProvider);
    _paymentAmountController = TextEditingController(text: state.finalTotal.toStringAsFixed(0));
    _discountController = TextEditingController(text: state.discount > 0 ? state.discount.toStringAsFixed(0) : '');
    _noteController = TextEditingController(text: state.note ?? '');

    // Set initial values in notifier
    Future.microtask(() {
      ref.read(transaksiProvider.notifier).setPaymentAmount(state.finalTotal);
      ref.read(transaksiProvider.notifier).setPaymentType('cash');
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
    final state = ref.watch(transaksiProvider);
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
                      ref.read(transaksiProvider.notifier).setPaymentType(type);
                      if (type != 'cash') {
                        ref.read(transaksiProvider.notifier).setPaymentAmount(state.finalTotal);
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
                ref.read(transaksiProvider.notifier).setNote(val);
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
                ref.read(transaksiProvider.notifier).setDiscount(discount);
                
                // If payment type is not cash, update paymentAmount to finalTotal automatically
                if (state.paymentType != 'cash') {
                  final newTotal = state.totalBeforeDiscount - discount;
                  ref.read(transaksiProvider.notifier).setPaymentAmount(newTotal);
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
                  ref.read(transaksiProvider.notifier).setPaymentAmount(amt);
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
                        ref.read(transaksiProvider.notifier).setPaymentAmount(state.finalTotal);
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
                        ref.read(transaksiProvider.notifier).setPaymentAmount(50000);
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
                        ref.read(transaksiProvider.notifier).setPaymentAmount(100000);
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
                      final notifier = ref.read(transaksiProvider.notifier);
                      final success = await notifier.checkout();
                      if (success && context.mounted) {
                        // Invalidate history provider so it displays this new transaction automatically
                        ref.invalidate(historyProvider);
                        // Check if checkout was saved offline
                        final wasOffline = ref.read(transaksiProvider).lastCheckoutWasOffline;
                        Navigator.pop(context);
                        showTopSnackBar(
                          context,
                          wasOffline
                              ? '📴 Transaksi disimpan offline. Akan otomatis sync saat koneksi kembali.'
                              : '✅ Transaksi Berhasil Disimpan!',
                          backgroundColor: wasOffline ? Colors.orange[700] : null,
                          duration: Duration(seconds: wasOffline ? 4 : 2),
                        );
                      } else if (context.mounted) {
                        showTopSnackBar(
                          context,
                          'Gagal checkout transaksi.',
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
}

class _DraftsDialog extends ConsumerWidget {
  const _DraftsDialog();

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
                final int id = draft['id'] as int;
                final double total = (draft['total'] as num).toDouble();
                final String dateStr = draft['created_at'] as String;
                final String formattedDate = dateFormat.format(DateTime.parse(dateStr));
                final String? note = draft['note'] as String?;
                final itemsList = draft['items'] as List<dynamic>;

                return ListTile(
                  title: Text('Draft #$id', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$formattedDate\n${itemsList.length} item | ${note ?? "Tanpa catatan"}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currencyFormat.format(total),
                        style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
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
                            await ref.read(transaksiProvider.notifier).deleteDraft(id);
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    ref.read(transaksiProvider.notifier).loadDraft(draft);
                    Navigator.pop(context);
                    showTopSnackBar(
                      context,
                      'Draft #$id berhasil dimuat!',
                    );
                  },
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

class _PrinterSetupDialog extends ConsumerStatefulWidget {
  const _PrinterSetupDialog();

  @override
  ConsumerState<_PrinterSetupDialog> createState() => _PrinterSetupDialogState();
}

class _PrinterSetupDialogState extends ConsumerState<_PrinterSetupDialog> {
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


