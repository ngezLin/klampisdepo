import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/item_provider.dart';
import '../../transaction/models/transaction_models.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/notification_helper.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/ui/item_image.dart';

class ItemListScreen extends ConsumerStatefulWidget {
  const ItemListScreen({super.key});

  @override
  ConsumerState<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends ConsumerState<ItemListScreen> {
  final _searchController = TextEditingController();
  final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final searchQuery = ref.read(itemManagementSearchQueryProvider);
      ref.read(paginatedItemsProvider(searchQuery).notifier).loadNextPage();
    }
  }

  void _showTopSnackBar(String message, {bool isError = false}) {
    showTopSnackBar(
      context,
      message,
      backgroundColor: isError ? Colors.red[700] : const Color(0xFF00AA5B),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(itemManagementSearchQueryProvider);
    final paginatedState = ref.watch(paginatedItemsProvider(searchQuery));
    final auth = ref.watch(authProvider);
    final showExport = auth.role == 'owner' || auth.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Item'),
        actions: [
          if (showExport)
            IconButton(
              icon: const Icon(Icons.download_outlined),
              tooltip: 'Ekspor CSV',
              onPressed: () => _exportInventoryCsv(context, ref),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Cari item...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    ref.read(itemManagementSearchQueryProvider.notifier).state = val;
                  }
                });
              },
            ),
          ),
          Expanded(
            child: paginatedState.items.isEmpty && paginatedState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : paginatedState.items.isEmpty
                    ? const Center(child: Text('Tidak ada item ditemukan.'))
                    : RefreshIndicator(
                        onRefresh: () async {
                          await ref.read(paginatedItemsProvider(searchQuery).notifier).refresh();
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: paginatedState.items.length + (paginatedState.isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= paginatedState.items.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            final item = paginatedState.items[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: ItemImage(
                                      imageUrl: item.imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                subtitle: Text(
                                  'Stok: ${item.stock} • ${_currencyFormat.format(item.price)}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 20),
                                      onPressed: () => _openItemForm(context, ref, initialItem: item),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                      onPressed: () => _deleteItem(context, ref, item),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openItemForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openItemForm(BuildContext context, WidgetRef ref, {ItemModel? initialItem}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ItemFormSheet(initialItem: initialItem),
    );
  }

  void _deleteItem(BuildContext context, WidgetRef ref, ItemModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Item?'),
        content: Text('Hapus "${item.name}"? Data item akan hilang.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        final dio = ref.read(dioProvider);
        await dio.delete('/items/${item.id}');
        if (context.mounted) {
          _showTopSnackBar('Item berhasil dihapus!');
          ref.invalidate(paginatedItemsProvider);
        }
      } catch (e) {
        if (context.mounted) {
          _showTopSnackBar('Gagal menghapus: $e', isError: true);
        }
      }
    }
  }

  Future<void> _exportInventoryCsv(BuildContext context, WidgetRef ref) async {
    try {
      _showTopSnackBar('Mengunduh data inventoris...');
      final dio = ref.read(dioProvider);
      final response = await dio.get('/items/export/csv');
      
      final String csvData = response.data.toString();
      
      final Directory? dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      if (dir == null) {
        if (context.mounted) {
          _showTopSnackBar('Gagal mengakses penyimpanan perangkat.', isError: true);
        }
        return;
      }
      
      final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String filePath = '${dir.path}/KlampisDepo_Inventory_$timestamp.csv';
      final File file = File(filePath);
      await file.writeAsString(csvData);

      // Trigger standard share dialog to let the user save or send the CSV file
      await SharePlus.instance.share(ShareParams(files: [XFile(filePath)], subject: 'Ekspor Inventoris KlampisDepo'));

      if (context.mounted) {
        _showTopSnackBar('✅ Inventoris berhasil diekspor!');
      }
    } catch (e) {
      if (context.mounted) {
        _showTopSnackBar('Gagal mengekspor inventoris: $e', isError: true);
      }
    }
  }
}

// ─── Mobile-Friendly Bottom Sheet Form with Image Upload ─────────

class _ItemFormSheet extends ConsumerStatefulWidget {
  final ItemModel? initialItem;
  const _ItemFormSheet({this.initialItem});

  @override
  ConsumerState<_ItemFormSheet> createState() => _ItemFormSheetState();
}

class _ItemFormSheetState extends ConsumerState<_ItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _stockController;
  late TextEditingController _priceController;
  late TextEditingController _buyPriceController;
  late TextEditingController _imageUrlController;
  late bool _isStockManaged;
  bool _isLoading = false;
  bool _isUploading = false;
  List<dynamic> _stockChanges = [];
  bool _isLoadingStockChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialItem?.name ?? '');
    _descriptionController = TextEditingController(text: widget.initialItem?.description ?? '');
    _stockController = TextEditingController(text: widget.initialItem?.stock.toString() ?? '0');
    _priceController = TextEditingController(text: widget.initialItem?.price.toStringAsFixed(0) ?? '0');
    _buyPriceController = TextEditingController(text: widget.initialItem?.buyPrice?.toStringAsFixed(0) ?? '0');
    _imageUrlController = TextEditingController(text: widget.initialItem?.imageUrl ?? '');
    _isStockManaged = widget.initialItem?.isStockManaged ?? true;
    
    if (widget.initialItem != null) {
      _loadStockChanges(widget.initialItem!.id);
    }
  }

  Future<void> _loadStockChanges(int itemId) async {
    setState(() => _isLoadingStockChanges = true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/items/$itemId/manual-changes');
      if (mounted) {
        setState(() {
          _stockChanges = (response.data['data'] ?? []) as List<dynamic>;
          _isLoadingStockChanges = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStockChanges = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    _buyPriceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  String? get _previewUrl {
    final url = _imageUrlController.text.trim();
    if (url.isEmpty) return null;
    return url;
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 50,
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
          _imageUrlController.text = response.data['url'];
          _isUploading = false;
        });
        if (mounted) {
          showTopSnackBar(context, 'Gambar berhasil diunggah!');
        }
      } else {
        throw Exception('Format respon tidak sesuai');
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        showTopSnackBar(
          context,
          'Gagal mengunggah gambar: $e',
          backgroundColor: Colors.red[700],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialItem != null;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Item' : 'Tambah Item',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Form body
          Flexible(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                shrinkWrap: true,
                children: [
                  // ─── Image Section ────────────────
                  GestureDetector(
                    onTap: _showImageOptions,
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _previewUrl != null ? const Color(0xFF00AA5B) : Colors.grey[300]!,
                          style: _previewUrl != null ? BorderStyle.solid : BorderStyle.none,
                        ),
                      ),
                      child: _isUploading
                          ? const Center(child: CircularProgressIndicator())
                          : _previewUrl != null
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(11),
                                      child: ItemImage(
                                        imageUrl: _imageUrlController.text.trim(),
                                        fit: BoxFit.cover,
                                        errorWidget: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () => setState(() => _imageUrlController.clear()),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            'Tap untuk ganti foto',
                                            style: TextStyle(color: Colors.white, fontSize: 11),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo_outlined, size: 36, color: Colors.grey[400]),
                                    const SizedBox(height: 8),
                                    Text('Tambah Foto Item', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                                    Text('Kamera, Galeri, atau URL • Maks 2MB', style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ─── Name ─────────────────────────
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nama Item', prefixIcon: Icon(Icons.label_outline)),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  // ─── Description ───────────────────
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Deskripsi', prefixIcon: Icon(Icons.info_outline)),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  // ─── Price Row ─────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _buyPriceController,
                          decoration: const InputDecoration(labelText: 'Harga Beli', prefixText: 'Rp '),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Wajib';
                            if (double.tryParse(v) == null) return 'Angka';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(labelText: 'Harga Jual', prefixText: 'Rp '),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Wajib';
                            if (double.tryParse(v) == null) return 'Angka';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // ─── Stock ────────────────────────
                  TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(labelText: 'Stok', prefixIcon: Icon(Icons.inventory_outlined)),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Wajib';
                      if (int.tryParse(v) == null) return 'Angka';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  // ─── Stock Toggle ──────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Kelola Stok?', style: TextStyle(fontWeight: FontWeight.w500)),
                        Switch(
                          value: _isStockManaged,
                          activeThumbColor: const Color(0xFF00AA5B),
                          onChanged: (val) => setState(() => _isStockManaged = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (isEditing) ...[
                    const Divider(height: 32),
                    const Row(
                      children: [
                        Icon(Icons.history, size: 18, color: Colors.grey),
                        SizedBox(width: 6),
                        Text(
                          'Riwayat Penyesuaian Stok',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _isLoadingStockChanges
                        ? const Center(child: CircularProgressIndicator())
                        : _stockChanges.isEmpty
                            ? const Text('Belum ada riwayat penyesuaian stok manual.', style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic))
                            : Container(
                                constraints: const BoxConstraints(maxHeight: 180),
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: _stockChanges.length,
                                  separatorBuilder: (_, __) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final log = _stockChanges[index] as Map<String, dynamic>;
                                    final String source = log['source'] ?? 'manual';
                                    final int difference = (log['difference'] as num?)?.toInt() ?? 0;
                                    final String? note = log['note'];
                                    final String createdAtStr = log['created_at'] ?? '';
                                    final String formattedDate = createdAtStr.isNotEmpty
                                        ? DateFormat('dd/MM/yy HH:mm').format(_parseDateTime(createdAtStr))
                                        : '-';

                                    final isPos = difference > 0;
                                    final Color diffColor = isPos ? Colors.green : Colors.red;
                                    final String diffStr = isPos ? '+$difference' : '$difference';

                                    return ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                      title: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Sumber: ${source.toUpperCase()}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                          Text(
                                            diffStr,
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: diffColor),
                                          ),
                                        ],
                                      ),
                                      subtitle: Text(
                                        'Tanggal: $formattedDate\nKeterangan: ${note ?? "-"}',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    );
                                  },
                                ),
                              ),
                    const SizedBox(height: 16),
                  ],
                  // ─── Submit Button ─────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading || _isUploading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(isEditing ? 'Simpan Perubahan' : 'Tambah Item'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Ambil Foto via Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Masukkan URL Gambar'),
              onTap: () {
                Navigator.pop(context);
                _showUrlInputDialog();
              },
            ),
            if (_imageUrlController.text.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Hapus Gambar', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _imageUrlController.clear());
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showUrlInputDialog() async {
    final urlController = TextEditingController(text: _imageUrlController.text);
    final url = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('URL Gambar'),
        content: TextField(
          controller: urlController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'https://example.com/image.jpg',
            labelText: 'URL',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final val = urlController.text.trim();
              if (val.isEmpty) {
                Navigator.pop(context, '');
                return;
              }
              if (val.length > 255) {
                showTopSnackBar(
                  context,
                  '⚠️ URL gambar terlalu panjang (maksimal 255 karakter). Silakan gunakan gambar yang diunggah dari kamera/galeri.',
                  backgroundColor: Colors.amber[800],
                );
                return;
              }
              if (val.startsWith('data:image/') || val.contains(';base64,')) {
                showTopSnackBar(
                  context,
                  '⚠️ Input tidak boleh berupa kode Base64. Harap masukkan URL link gambar yang valid.',
                  backgroundColor: Colors.amber[800],
                );
                return;
              }
              Navigator.pop(context, val);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (url != null) {
      setState(() => _imageUrlController.text = url);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final payload = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      'stock': int.parse(_stockController.text),
      'buy_price': double.parse(_buyPriceController.text),
      'price': double.parse(_priceController.text),
      'is_stock_managed': _isStockManaged,
      'image_url': _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
    };

    final isEditing = widget.initialItem != null;

    try {
      final dio = ref.read(dioProvider);
      if (isEditing) {
        await dio.put('/items/${widget.initialItem!.id}', data: payload);
      } else {
        await dio.post('/items/', data: payload);
      }

      if (mounted) {
        Navigator.pop(context);
        showTopSnackBar(context, isEditing ? 'Item berhasil diubah!' : 'Item berhasil ditambahkan!');
        ref.invalidate(paginatedItemsProvider);
      }
    } catch (e) {
      if (mounted) {
        showTopSnackBar(context, 'Gagal menyimpan: $e', backgroundColor: Colors.red[700]);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
