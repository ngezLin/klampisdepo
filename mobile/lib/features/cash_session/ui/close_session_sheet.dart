import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/cash_session_provider.dart';
import '../../../core/theme/notification_helper.dart';

class CloseSessionSheet extends ConsumerStatefulWidget {
  const CloseSessionSheet({super.key});

  @override
  ConsumerState<CloseSessionSheet> createState() => _CloseSessionSheetState();
}

class _CloseSessionSheetState extends ConsumerState<CloseSessionSheet> {
  final _cashController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  bool _isSubmitting = false;

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(cashSessionProvider);
    final activeSession = sessionState.activeSession;
    
    if (activeSession == null) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(child: Text('Tidak ada laci kasir aktif.')),
      );
    }

    final double openingCash = (activeSession['opening_cash'] as num?)?.toDouble() ?? 0.0;
    final String openedAtStr = activeSession['opened_at'] ?? '';
    final String formattedOpen = openedAtStr.isNotEmpty 
        ? DateFormat('dd/MM HH:mm').format(_parseDateTime(openedAtStr)) 
        : '-';

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tutup Shift Kasir',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),
              
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    _infoRow('Waktu Buka', formattedOpen),
                    const SizedBox(height: 8),
                    _infoRow('Modal Awal', _currencyFormat.format(openingCash)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Hitung Uang Laci Fisik (Rp)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              
              TextFormField(
                controller: _cashController,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  hintText: '0',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF00AA5B), width: 2),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Harap masukkan jumlah uang fisik';
                  }
                  if (double.tryParse(val) == null) {
                    return 'Jumlah harus berupa angka';
                  }
                  if (double.parse(val) < 0) {
                    return 'Jumlah tidak boleh kurang dari 0';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting 
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'TUTUP SHIFT SEKARANG',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    final closingCash = double.parse(_cashController.text.trim());
    
    final closedSession = await ref.read(cashSessionProvider.notifier).closeSession(closingCash);
    
    setState(() => _isSubmitting = false);
    
    if (!mounted) return;
    
    if (closedSession != null) {
      Navigator.pop(context); // Close sheet
      
      // Show Summary result Dialog
      _showSummaryDialog(closedSession);
    } else {
      final error = ref.read(cashSessionProvider).error ?? 'Gagal menutup shift.';
      showTopSnackBar(context, error, backgroundColor: Colors.red[700]);
    }
  }

  void _showSummaryDialog(Map<String, dynamic> result) {
    final double exp = (result['expected_cash'] as num?)?.toDouble() ?? 0.0;
    final double actual = (result['closing_cash'] as num?)?.toDouble() ?? 0.0;
    final double diff = (result['difference'] as num?)?.toDouble() ?? 0.0;
    final double cashIn = (result['total_cash_in'] as num?)?.toDouble() ?? 0.0;
    final double change = (result['total_change'] as num?)?.toDouble() ?? 0.0;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF00AA5B)),
            SizedBox(width: 8),
            Text('Shift Berhasil Ditutup', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Rangkuman transaksi tunai shift ini:'),
            const SizedBox(height: 16),
            _summaryRow('Total Tunai Masuk', _currencyFormat.format(cashIn)),
            _summaryRow('Total Kembalian', _currencyFormat.format(change)),
            const Divider(),
            _summaryRow('Uang Laci Ekspektasi', _currencyFormat.format(exp), isBold: true),
            _summaryRow('Uang Laci Fisik', _currencyFormat.format(actual), isBold: true),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Selisih Kas', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  _currencyFormat.format(diff),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: diff == 0 ? Colors.green : (diff > 0 ? Colors.blue : Colors.red),
                  ),
                ),
              ],
            ),
            if (diff != 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: diff > 0 ? Colors.blue[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  diff > 0 
                      ? '*Terdapat selisih lebih uang di laci.' 
                      : '*Terdapat selisih kurang uang di laci.',
                  style: TextStyle(
                    fontSize: 11,
                    color: diff > 0 ? Colors.blue[800] : Colors.red[800],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.invalidate(cashSessionHistoryProvider);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
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
