import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../providers/po_bill_provider.dart';
import '../models/po_bill.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/notification_helper.dart';
import '../../../core/ui/item_image.dart';

class POBillsScreen extends ConsumerStatefulWidget {
  const POBillsScreen({super.key});

  @override
  ConsumerState<POBillsScreen> createState() => _POBillsScreenState();
}

class _POBillsScreenState extends ConsumerState<POBillsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final status = _tabController.index == 0 ? 'pending' : 'paid';
      ref.read(poBillsProvider.notifier).setStatusFilter(status);
    });
    
    // Initial load for pending bills
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(poBillsProvider.notifier).setStatusFilter('pending');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Helper to calculate countdown status
  Map<String, dynamic> _getCountdownInfo(DateTime dueDate, String status) {
    if (status == 'paid') {
      return {
        'text': 'Lunas',
        'color': const Color(0xFF6B7280),
        'bgColor': const Color(0xFFF3F4F6),
      };
    }

    final now = DateTime.now();
    // Normalize date parts to compare days only
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = due.difference(today).inDays;

    if (difference < 0) {
      return {
        'text': 'Terlambat ${-difference} hari',
        'color': const Color(0xFFDC2626),
        'bgColor': const Color(0xFFFEF2F2),
      };
    } else if (difference == 0) {
      return {
        'text': 'Jatuh tempo hari ini!',
        'color': const Color(0xFFD97706),
        'bgColor': const Color(0xFFFEF3C7),
      };
    } else if (difference == 1) {
      return {
        'text': 'Jatuh tempo besok!',
        'color': const Color(0xFFD97706),
        'bgColor': const Color(0xFFFEF3C7),
      };
    } else if (difference <= 7) {
      return {
        'text': '$difference hari lagi',
        'color': const Color(0xFFB45309),
        'bgColor': const Color(0xFFFFFBEB),
      };
    } else {
      return {
        'text': '$difference hari lagi',
        'color': const Color(0xFF047857),
        'bgColor': const Color(0xFFECFDF5),
      };
    }
  }

  void _showImageLightbox(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black,
              ),
              clipBehavior: Clip.antiAlias,
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: ItemImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.7,
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _openFormBottomSheet([POBillModel? initialBill]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _POBillFormSheet(
        initialBill: initialBill,
        onSaved: () {
          ref.read(poBillsProvider.notifier).loadBills();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(poBillsProvider);
    final notifier = ref.read(poBillsProvider.notifier);
    final filteredList = notifier.filteredBills;

    // Calculate Summary Metrics
    double totalUnpaid = 0;
    int overdueCount = 0;
    int dueSoonCount = 0;

    for (final b in state.bills) {
      if (b.status == 'pending') {
        totalUnpaid += b.amount;
        final difference = DateTime(b.dueDate.year, b.dueDate.month, b.dueDate.day)
            .difference(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))
            .inDays;
        if (difference < 0) {
          overdueCount++;
        } else if (difference <= 7) {
          dueSoonCount++;
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Tagihan Pembelian (PO)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => notifier.loadBills(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF00AA5B),
              labelColor: const Color(0xFF00AA5B),
              unselectedLabelColor: const Color(0xFF6B7280),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(text: 'Belum Lunas'),
                Tab(text: 'Lunas'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ─── Metrics Dashboard Header ───
          if (state.statusFilter == 'pending')
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Belum Dibayar', style: TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            _currencyFormat.format(totalUnpaid),
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: overdueCount > 0 ? const Color(0xFFFEF2F2) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: overdueCount > 0 ? const Color(0xFFFCA5A5) : const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Terlambat', style: TextStyle(color: overdueCount > 0 ? const Color(0xFF991B1B) : const Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            '$overdueCount Bills',
                            style: TextStyle(
                              color: overdueCount > 0 ? const Color(0xFFDC2626) : const Color(0xFF111827),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: dueSoonCount > 0 ? const Color(0xFFFFFBEB) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: dueSoonCount > 0 ? const Color(0xFFFDE68A) : const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Segera Hadir', style: TextStyle(color: dueSoonCount > 0 ? const Color(0xFF92400E) : const Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            '$dueSoonCount Bills',
                            style: TextStyle(
                              color: dueSoonCount > 0 ? const Color(0xFFD97706) : const Color(0xFF111827),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ─── Search Bar ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => ref.read(poBillsProvider.notifier).setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Cari invoice atau distributor...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF9CA3AF)),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(poBillsProvider.notifier).setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00AA5B), width: 1.5),
                ),
              ),
            ),
          ),

          // ─── Invoice List ───
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00AA5B))))
                : filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              state.searchQuery.isNotEmpty
                                  ? 'Tagihan tidak ditemukan'
                                  : 'Belum ada data tagihan',
                              style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final bill = filteredList[index];
                          final countdown = _getCountdownInfo(bill.dueDate, bill.status);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.01),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header: Vendor & Countdown Badge
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          bill.vendorName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF111827),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: countdown['bgColor'],
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          countdown['text'],
                                          style: TextStyle(
                                            color: countdown['color'],
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // Invoice Number
                                  Text(
                                    'Inv: ${bill.invoiceNumber}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  const Divider(height: 24, color: Color(0xFFF3F4F6)),

                                  // Middle: Dates & Amount
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Jatuh Tempo', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 10)),
                                          const SizedBox(height: 2),
                                          Text(
                                            _dateFormat.format(bill.dueDate),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF374151),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          const Text('Jumlah Tagihan', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 10)),
                                          const SizedBox(height: 2),
                                          Text(
                                            _currencyFormat.format(bill.amount),
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF111827),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  if (bill.notes.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF9FAFB),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        bill.notes,
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563), fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                  ],

                                  // Footer actions & Receipt image thumbnail
                                  const Divider(height: 24, color: Color(0xFFF3F4F6)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Receipt Preview
                                      bill.receiptImage.isNotEmpty
                                          ? GestureDetector(
                                              onTap: () => _showImageLightbox(bill.receiptImage),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFE5F7EE),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: const Color(0xFFC2F0D5)),
                                                ),
                                                child: const Row(
                                                  children: [
                                                    Icon(Icons.image_outlined, size: 14, color: Color(0xFF00AA5B)),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'Lihat Nota',
                                                      style: TextStyle(
                                                        color: Color(0xFF00AA5B),
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : const Text(
                                              'Tidak ada foto nota',
                                              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11, fontStyle: FontStyle.italic),
                                            ),

                                      // Edit / Actions Row
                                      Row(
                                        children: [
                                          if (bill.status == 'pending') ...[
                                            TextButton.icon(
                                              onPressed: () async {
                                                final success = await ref
                                                    .read(poBillsProvider.notifier)
                                                    .markBillAsPaid(bill.id!);
                                                if (success && mounted) {
                                                  showTopSnackBar(this.context, 'Tagihan ditandai LUNAS!');
                                                }
                                              },
                                              icon: const Icon(Icons.check_circle_outline, size: 16),
                                              label: const Text('Tandai Lunas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                              style: TextButton.styleFrom(
                                                foregroundColor: const Color(0xFF00AA5B),
                                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                          ],
                                          PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert, size: 20, color: Color(0xFF6B7280)),
                                            padding: EdgeInsets.zero,
                                            onSelected: (val) async {
                                              if (val == 'edit') {
                                                _openFormBottomSheet(bill);
                                              } else if (val == 'delete') {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text('Hapus Tagihan?'),
                                                    content: const Text('Apakah Anda yakin ingin menghapus tagihan PO ini? Tindakan ini tidak dapat dibatalkan.'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.of(context).pop(false),
                                                        child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                                                      ),
                                                      TextButton(
                                                        onPressed: () => Navigator.of(context).pop(true),
                                                        child: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirm == true) {
                                                  final success = await ref
                                                      .read(poBillsProvider.notifier)
                                                      .deleteBill(bill.id!);
                                                  if (success && mounted) {
                                                    showTopSnackBar(this.context, 'Tagihan berhasil dihapus!');
                                                  }
                                                }
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                                                    SizedBox(width: 8),
                                                    Text('Ubah Detail', style: TextStyle(fontSize: 13)),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                                    SizedBox(width: 8),
                                                    Text('Hapus Tagihan', style: TextStyle(fontSize: 13, color: Colors.red)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openFormBottomSheet(),
        backgroundColor: const Color(0xFF00AA5B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ─── Sub-widget: Form Bottom Sheet ───
class _POBillFormSheet extends ConsumerStatefulWidget {
  final POBillModel? initialBill;
  final VoidCallback onSaved;

  const _POBillFormSheet({this.initialBill, required this.onSaved});

  @override
  ConsumerState<_POBillFormSheet> createState() => _POBillFormSheetState();
}

class _POBillFormSheetState extends ConsumerState<_POBillFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _invoiceController;
  late TextEditingController _vendorController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late TextEditingController _customTermController;

  DateTime _receivedDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  String _receiptImageUrl = '';
  bool _isUploading = false;
  int _selectedTermDays = 30;

  @override
  void initState() {
    super.initState();
    _invoiceController = TextEditingController(text: widget.initialBill?.invoiceNumber ?? '');
    _vendorController = TextEditingController(text: widget.initialBill?.vendorName ?? '');
    _amountController = TextEditingController(
      text: widget.initialBill != null ? widget.initialBill!.amount.toStringAsFixed(0) : '',
    );
    _notesController = TextEditingController(text: widget.initialBill?.notes ?? '');

    if (widget.initialBill != null) {
      _receivedDate = widget.initialBill!.receivedDate;
      _dueDate = widget.initialBill!.dueDate;
      _receiptImageUrl = widget.initialBill!.receiptImage;
      
      // Attempt to calculate selected term days to highlight buttons
      final diff = _dueDate.difference(_receivedDate).inDays;
      _selectedTermDays = diff;
      if (diff == 30 || diff == 45 || diff == 60) {
        _customTermController = TextEditingController();
      } else {
        _customTermController = TextEditingController(text: diff.toString());
      }
    } else {
      _customTermController = TextEditingController();
      _updateDueDate(30);
    }
  }

  @override
  void dispose() {
    _invoiceController.dispose();
    _vendorController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _customTermController.dispose();
    super.dispose();
  }

  void _updateDueDate(int days) {
    setState(() {
      _selectedTermDays = days;
      _dueDate = _receivedDate.add(Duration(days: days));
      if (days == 30 || days == 45 || days == 60) {
        _customTermController.clear();
      } else {
        _customTermController.text = days.toString();
      }
    });
  }

  Future<void> _pickAndUploadReceipt(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 75,
      );
      if (file == null) return;

      setState(() => _isUploading = true);

      final bytes = await file.readAsBytes();
      final fileName = file.name;

      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(bytes, filename: fileName),
      });

      final dio = ref.read(dioProvider);
      final response = await dio.post('/upload/image', data: formData);

      if (response.data != null && response.data['url'] != null) {
        setState(() {
          _receiptImageUrl = response.data['url'];
          _isUploading = false;
        });
        if (mounted) {
          showTopSnackBar(context, 'Nota berhasil diunggah!');
        }
      } else {
        throw Exception('Format respon tidak sesuai');
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        showTopSnackBar(
          context,
          'Gagal mengunggah foto nota: $e',
          backgroundColor: Colors.red[700],
        );
      }
    }
  }

  Future<void> _selectReceivedDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _receivedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF00AA5B),
            onPrimary: Colors.white,
            onSurface: Color(0xFF111827),
          ),
        ),
        child: child!,
      ),
    );
    if (selected != null) {
      setState(() {
        _receivedDate = selected;
        // Keep terms calculated based on new received date
        if (_selectedTermDays > 0) {
          _dueDate = _receivedDate.add(Duration(days: _selectedTermDays));
        } else if (_dueDate.isBefore(_receivedDate)) {
          _dueDate = _receivedDate.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectDueDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate.isBefore(_receivedDate) ? _receivedDate.add(const Duration(days: 1)) : _dueDate,
      firstDate: _receivedDate,
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        key: const Key('due_date_theme'),
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF00AA5B),
            onPrimary: Colors.white,
            onSurface: Color(0xFF111827),
          ),
        ),
        child: child!,
      ),
    );
    if (selected != null) {
      setState(() {
        _dueDate = selected;
        final diff = _dueDate.difference(_receivedDate).inDays;
        _selectedTermDays = diff;
        if (diff == 30 || diff == 45 || diff == 60) {
          _customTermController.clear();
        } else {
          _customTermController.text = diff.toString();
        }
      });
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    final double amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      showTopSnackBar(context, 'Jumlah tagihan harus lebih dari 0', backgroundColor: Colors.red[700]);
      return;
    }

    final bill = POBillModel(
      id: widget.initialBill?.id,
      invoiceNumber: _invoiceController.text.trim(),
      vendorName: _vendorController.text.trim(),
      amount: amount,
      receivedDate: _receivedDate,
      dueDate: _dueDate,
      status: widget.initialBill?.status ?? 'pending',
      receiptImage: _receiptImageUrl,
      notes: _notesController.text.trim(),
    );

    bool success;
    if (widget.initialBill != null) {
      success = await ref.read(poBillsProvider.notifier).updateBill(widget.initialBill!.id!, bill);
    } else {
      success = await ref.read(poBillsProvider.notifier).createBill(bill);
    }

    if (success) {
      if (mounted) {
        showTopSnackBar(
          context,
          widget.initialBill != null ? 'Tagihan berhasil diperbarui!' : 'Tagihan baru berhasil dibuat!',
        );
        widget.onSaved();
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        showTopSnackBar(context, 'Gagal menyimpan tagihan PO.', backgroundColor: Colors.red[700]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isEditing = widget.initialBill != null;

    return Container(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Container(
        constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.85),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Ubah Tagihan PO' : 'Tambah Tagihan PO',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 16, color: Color(0xFFE5E7EB)),

                // Distributor Name
                const Text('Nama Distributor *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF374151))),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _vendorController,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Nama distributor wajib diisi' : null,
                  decoration: InputDecoration(
                    hintText: 'Contoh: PT. Sumber Jaya',
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF00AA5B), width: 1.5)),
                  ),
                ),
                const SizedBox(height: 16),

                // Invoice Number & Amount Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('No. Invoice (Kosongkan untuk auto)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF374151))),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _invoiceController,
                            validator: null,
                            decoration: InputDecoration(
                              hintText: 'E.g. INV/2026/001',
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF00AA5B), width: 1.5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Jumlah Tagihan (Rp) *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF374151))),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Jumlah wajib diisi' : null,
                            decoration: InputDecoration(
                              hintText: 'E.g. 5000000',
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF00AA5B), width: 1.5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Received Date & Due Date Picker
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tanggal Diterima', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF374151))),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _selectReceivedDate,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(_receivedDate),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                                  ),
                                  const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF6B7280)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tanggal Jatuh Tempo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF374151))),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _selectDueDate,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(_dueDate),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                                  ),
                                  const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF6B7280)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Quick Terms Selector
                const Text('Term Pembayaran', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildTermChip(30, '+30 Hari'),
                    const SizedBox(width: 6),
                    _buildTermChip(45, '+45 Hari'),
                    const SizedBox(width: 6),
                    _buildTermChip(60, '+60 Hari'),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: TextFormField(
                          controller: _customTermController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            hintText: 'Custom Hari',
                            hintStyle: const TextStyle(fontSize: 11),
                            prefixText: '+ ',
                            suffixText: ' Hari',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: Color(0xFF00AA5B)),
                            ),
                          ),
                          onChanged: (val) {
                            final trimmed = val.trim();
                            if (trimmed.isEmpty) {
                              if (_selectedTermDays != 30 &&
                                  _selectedTermDays != 45 &&
                                  _selectedTermDays != 60) {
                                setState(() {
                                  _selectedTermDays = 0;
                                  _dueDate = _receivedDate;
                                });
                              }
                              return;
                            }
                            final days = int.tryParse(trimmed);
                            if (days != null && days >= 0) {
                              if (days != _selectedTermDays) {
                                setState(() {
                                  _selectedTermDays = days;
                                  _dueDate = _receivedDate.add(Duration(days: days));
                                });
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Upload Receipt section
                const Text('Foto Nota / Kwitansi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF374151))),
                const SizedBox(height: 8),
                _isUploading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00AA5B))),
                        ),
                      )
                    : _receiptImageUrl.isNotEmpty
                        ? Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              children: [
                                ItemImage(
                                  imageUrl: _receiptImageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black54,
                                    radius: 16,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete, size: 14, color: Colors.white),
                                      onPressed: () => setState(() => _receiptImageUrl = ''),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _pickAndUploadReceipt(ImageSource.camera),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFFE5E7EB)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Column(
                                      children: [
                                        Icon(Icons.camera_alt_outlined, color: Color(0xFF6B7280)),
                                        SizedBox(height: 4),
                                        Text('Kamera', style: TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _pickAndUploadReceipt(ImageSource.gallery),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFFE5E7EB)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Column(
                                      children: [
                                        Icon(Icons.image_outlined, color: Color(0xFF6B7280)),
                                        SizedBox(height: 4),
                                        Text('Galeri', style: TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                const SizedBox(height: 16),

                // Notes
                const Text('Catatan / Keterangan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF374151))),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'E.g. Nota pembelian filter air dari supplier pusat',
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF00AA5B), width: 1.5)),
                  ),
                ),
                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _saveForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00AA5B),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      isEditing ? 'Perbarui Tagihan' : 'Simpan Tagihan',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermChip(int days, String label) {
    final isSelected = _selectedTermDays == days;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _updateDueDate(days);
        }
      },
      selectedColor: const Color(0xFFE5F7EE),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF00AA5B) : const Color(0xFF4B5563),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(0xFF00AA5B) : const Color(0xFFD1D5DB),
        ),
      ),
    );
  }
}
