import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../../core/network/dio_client.dart';
import 'package:drift/drift.dart';

/// Manages offline transaction queue and auto-syncs when connectivity resumes.
class OfflineSyncService {
  final Ref ref;
  final AppDatabase _db;
  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

  OfflineSyncService(this.ref, this._db);

  /// Start monitoring network connectivity for auto-sync
  void startListening() {
    if (kIsWeb) return;
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      // results is List<ConnectivityResult>
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection && !_isSyncing) {
        syncPendingTransactions();
      }
    });
  }

  void stopListening() {
    if (kIsWeb) return;
    _connectivitySubscription?.cancel();
  }

  /// Save a transaction locally when offline
  Future<int> saveOfflineTransaction({
    required String status,
    required double total,
    required double discount,
    required double paymentAmount,
    required String paymentType,
    required String transactionType,
    String? note,
    required List<Map<String, dynamic>> items,
  }) async {
    if (kIsWeb) return 0;
    // Insert the transaction record
    final txId = await _db.into(_db.transactions).insert(
      TransactionsCompanion.insert(
        status: status,
        total: total,
        discount: Value(discount),
        paymentAmount: Value(paymentAmount),
        paymentType: Value(paymentType),
        transactionType: Value(transactionType),
        note: Value(note),
        syncStatus: const Value('pending_sync'),
        createdAt: DateTime.now(),
      ),
    );

    // Insert each item in the transaction
    for (final item in items) {
      await _db.into(_db.transactionItems).insert(
        TransactionItemsCompanion.insert(
          transactionId: txId,
          itemId: item['item_id'] as int,
          itemName: item['item_name'] as String,
          quantity: item['quantity'] as int,
          price: item['price'] as double,
          customPrice: Value(item['custom_price'] as double?),
          subtotal: item['subtotal'] as double,
        ),
      );
    }

    return txId;
  }

  /// Get count of pending transactions
  Future<int> getPendingCount() async {
    if (kIsWeb) return 0;
    final query = _db.select(_db.transactions)
      ..where((t) => t.syncStatus.equals('pending_sync'));
    final results = await query.get();
    return results.length;
  }

  /// Watch pending transaction count as a stream
  Stream<int> watchPendingCount() {
    if (kIsWeb) return Stream.value(0);
    final query = _db.select(_db.transactions)
      ..where((t) => t.syncStatus.equals('pending_sync'));
    return query.watch().map((rows) => rows.length);
  }

  /// Sync all pending transactions to the backend
  Future<SyncResult> syncPendingTransactions() async {
    if (kIsWeb) return SyncResult(synced: 0, failed: 0);
    if (_isSyncing) return SyncResult(synced: 0, failed: 0);
    _isSyncing = true;

    int synced = 0;
    int failed = 0;

    try {
      final dio = ref.read(dioProvider);

      // Get all pending transactions
      final query = _db.select(_db.transactions)
        ..where((t) => t.syncStatus.equals('pending_sync'));
      final pendingTxs = await query.get();

      for (final tx in pendingTxs) {
        try {
          // Get items for this transaction
          final itemsQuery = _db.select(_db.transactionItems)
            ..where((ti) => ti.transactionId.equals(tx.id));
          final txItems = await itemsQuery.get();

          // Build API payload
          final payload = {
            'status': tx.status,
            'payment': tx.paymentAmount,
            'payment_type': tx.paymentType,
            'note': tx.note,
            'transaction_type': tx.transactionType,
            'discount': tx.discount,
            'items': txItems.map((item) => {
              'item_id': item.itemId,
              'quantity': item.quantity,
              'custom_price': item.customPrice,
            }).toList(),
          };

          // Post to backend
          final response = await dio.post('/transactions/', data: payload);

          // Mark as synced and store server ID
          final serverData = response.data['data'] ?? response.data;
          final serverId = serverData is Map ? serverData['id'] as int? : null;

          await (_db.update(_db.transactions)
            ..where((t) => t.id.equals(tx.id)))
            .write(TransactionsCompanion(
              syncStatus: const Value('synced'),
              serverId: Value(serverId),
            ));

          synced++;
        } catch (e) {
          failed++;
          // Leave as pending_sync for next retry
        }
      }
    } finally {
      _isSyncing = false;
    }

    return SyncResult(synced: synced, failed: failed);
  }
}

class SyncResult {
  final int synced;
  final int failed;
  SyncResult({required this.synced, required this.failed});
}

// ─── Providers ─────────────────────────────────────────

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final service = OfflineSyncService(ref, db);
  service.startListening();
  ref.onDispose(() => service.stopListening());
  return service;
});

final pendingSyncCountProvider = StreamProvider<int>((ref) {
  final syncService = ref.watch(offlineSyncServiceProvider);
  return syncService.watchPendingCount();
});
