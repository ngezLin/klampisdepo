import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

final logsProvider = FutureProvider.family.autoDispose<String, String>((ref, type) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/health/logs', queryParameters: {'type': type});
  return response.data['logs'] as String? ?? 'Tidak ada log ditemukan.';
});

class LogsScreen extends ConsumerStatefulWidget {
  const LogsScreen({super.key});

  @override
  ConsumerState<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends ConsumerState<LogsScreen> {
  String _selectedLogType = 'api'; // 'api' or 'mysql'
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(logsProvider(_selectedLogType));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Server Logs'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(logsProvider(_selectedLogType)),
            tooltip: 'Refresh Log',
          ),
          logsAsync.when(
            data: (logs) => IconButton(
              icon: const Icon(Icons.copy_rounded),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: logs));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Log berhasil disalin ke clipboard!')),
                );
              },
              tooltip: 'Salin Semua Log',
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // ─── Log Type Selector Tab ───────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('API Logs (Systemd)')),
                    selected: _selectedLogType == 'api',
                    selectedColor: const Color(0xFFE5F7EE),
                    backgroundColor: const Color(0xFFF3F4F6),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _selectedLogType == 'api' ? const Color(0xFF00AA5B) : Colors.black87,
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedLogType = 'api';
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('MySQL Error Logs')),
                    selected: _selectedLogType == 'mysql',
                    selectedColor: const Color(0xFFEFF6FF),
                    backgroundColor: const Color(0xFFF3F4F6),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _selectedLogType == 'mysql' ? const Color(0xFF3B82F6) : Colors.black87,
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedLogType = 'mysql';
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // ─── Search Bar ──────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari dalam log...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                fillColor: Colors.white,
                filled: true,
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
            ),
          ),

          // ─── Log Viewer ──────────────────────────
          Expanded(
            child: logsAsync.when(
              data: (logs) {
                // Filter logs based on search query
                List<String> logLines = logs.split('\n');
                if (_searchQuery.isNotEmpty) {
                  logLines = logLines
                      .where((line) => line.toLowerCase().contains(_searchQuery.toLowerCase()))
                      .toList();
                }

                if (logLines.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada entri log yang cocok.'),
                  );
                }

                // Scroll to bottom once logs are loaded
                if (_searchQuery.isEmpty) {
                  _scrollToBottom();
                }

                return Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A), // Dark slate
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SelectableText(
                            logLines.join('\n'),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: Color(0xFFE2E8F0), // Off white
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 24,
                      bottom: 24,
                      child: FloatingActionButton.small(
                        backgroundColor: Colors.blueGrey[800],
                        foregroundColor: Colors.white,
                        onPressed: _scrollToBottom,
                        child: const Icon(Icons.arrow_downward_rounded),
                      ),
                    )
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF00AA5B)),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text(
                        'Gagal memuat log server',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        err.toString(),
                        style: const TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
