import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../../core/network/dio_client.dart';
import 'package:drift/drift.dart';

import 'dart:convert';

/// Manages offline transaction queue and auto-syncs when connectivity resumes.
class OfflineSyncService {
  final Ref ref;
  final AppDatabase _db;
  StreamSubscription? _connectivitySubscription;

  OfflineSyncService(this.ref, this._db);

  /// Start monitoring network connectivity for auto-sync
  void startListening() {
    if (kIsWeb) return;
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection && !ref.read(isSyncingProvider)) {
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

    // Insert each item in the transaction and update stock
    for (final item in items) {
      final itemId = item['item_id'] as int;
      final quantity = item['quantity'] as int;

      await _db.into(_db.transactionItems).insert(
        TransactionItemsCompanion.insert(
          transactionId: txId,
          itemId: itemId,
          itemName: item['item_name'] as String,
          quantity: quantity,
          price: item['price'] as double,
          customPrice: Value(item['custom_price'] as double?),
          subtotal: item['subtotal'] as double,
        ),
      );

      // Decrement stock in local Items cache
      try {
        final existingItem = await (_db.select(_db.items)..where((t) => t.id.equals(itemId))).getSingleOrNull();
        if (existingItem != null && existingItem.isStockManaged) {
          final newStock = (existingItem.stock - quantity).clamp(0, 999999);
          await (_db.update(_db.items)..where((t) => t.id.equals(itemId))).write(
            ItemsCompanion(stock: Value(newStock)),
          );
        }
      } catch (e) {
        debugPrint('Failed to update local stock during offline checkout: $e');
      }
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

  /// Watch conflict transaction count as a stream
  Stream<int> watchConflictCount() {
    if (kIsWeb) return Stream.value(0);
    final query = _db.select(_db.transactions)
      ..where((t) => t.syncStatus.equals('conflict'));
    return query.watch().map((rows) => rows.length);
  }

  /// Sync all pending transactions to the backend
  Future<SyncResult> syncPendingTransactions() async {
    if (kIsWeb) return SyncResult(synced: 0, failed: 0);
    if (ref.read(isSyncingProvider)) return SyncResult(synced: 0, failed: 0);

    ref.read(isSyncingProvider.notifier).state = true;

    int synced = 0;
    int failed = 0;

    try {
      final dio = ref.read(dioProvider);

      // 1. Fetch latest items from server first to refresh the local cache and detect price changes
      try {
        final itemsResponse = await dio.get('/items/', queryParameters: {'page_size': 100});
        final List data = itemsResponse.data['data'] ?? [];
        final dbItems = data.map((e) => Item(
          id: e['id'] as int,
          name: e['name'] as String,
          description: e['description'] as String?,
          stock: e['stock'] as int? ?? 0,
          isStockManaged: e['is_stock_managed'] as bool? ?? true,
          buyPrice: (e['buy_price'] as num?)?.toDouble(),
          price: (e['price'] as num).toDouble(),
          imageUrl: e['image_url'] as String?,
          updatedAt: DateTime.now(),
        )).toList();
        await _db.upsertItems(dbItems);
      } catch (e) {
        debugPrint('Failed to refresh items cache during sync: $e');
      }

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

          // 2. Perform Conflict Check
          final List<Map<String, dynamic>> conflictsList = [];
          double updatedTotalBeforeDiscount = 0.0;

          for (final txItem in txItems) {
            final serverItem = await (_db.select(_db.items)..where((t) => t.id.equals(txItem.itemId))).getSingleOrNull();
            if (serverItem != null) {
              final checkoutPrice = txItem.price;
              final serverPrice = serverItem.price;

              if (checkoutPrice != serverPrice && txItem.customPrice == null) {
                conflictsList.add({
                  'item_id': txItem.itemId,
                  'item_name': txItem.itemName,
                  'checkout_price': checkoutPrice,
                  'server_price': serverPrice,
                  'quantity': txItem.quantity,
                });
              }
              final activePrice = txItem.customPrice ?? serverPrice;
              updatedTotalBeforeDiscount += txItem.quantity * activePrice;
            } else {
              updatedTotalBeforeDiscount += txItem.subtotal;
            }
          }

          if (conflictsList.isNotEmpty) {
            // Price conflict detected! Mark as conflict and skip sync
            await (_db.update(_db.transactions)
                  ..where((t) => t.id.equals(tx.id)))
                .write(TransactionsCompanion(
              syncStatus: const Value('conflict'),
              conflictDetails: Value(json.encode(conflictsList)),
            ));
            failed++;
            continue;
          }

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
          final serverData = response.data['transaction'] ?? response.data['data'] ?? response.data;
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
        }
      }
    } finally {
      ref.read(isSyncingProvider.notifier).state = false;
    }

    return SyncResult(synced: synced, failed: failed);
  }

  /// Resolve conflict by keeping offline price as custom price
  Future<void> resolveConflictKeepOffline(int txId) async {
    final txItems = await (_db.select(_db.transactionItems)
          ..where((ti) => ti.transactionId.equals(txId)))
        .get();

    for (final item in txItems) {
      if (item.customPrice == null) {
        await (_db.update(_db.transactionItems)..where((ti) => ti.id.equals(item.id)))
            .write(TransactionItemsCompanion(customPrice: Value(item.price)));
      }
    }

    await (_db.update(_db.transactions)..where((t) => t.id.equals(txId)))
        .write(const TransactionsCompanion(
      syncStatus: Value('pending_sync'),
      conflictDetails: Value(null),
    ));

    syncPendingTransactions();
  }

  /// Resolve conflict by updating to the new server price and recalculating
  Future<void> resolveConflictUseServerPrice(int txId) async {
    final txItems = await (_db.select(_db.transactionItems)
          ..where((ti) => ti.transactionId.equals(txId)))
        .get();

    double updatedTotalBeforeDiscount = 0.0;

    for (final txItem in txItems) {
      final serverItem = await (_db.select(_db.items)..where((t) => t.id.equals(txItem.itemId))).getSingleOrNull();
      if (serverItem != null) {
        final serverPrice = serverItem.price;
        final newSubtotal = txItem.quantity * serverPrice;

        await (_db.update(_db.transactionItems)..where((ti) => ti.id.equals(txItem.id)))
            .write(TransactionItemsCompanion(
          price: Value(serverPrice),
          subtotal: Value(newSubtotal),
        ));

        updatedTotalBeforeDiscount += newSubtotal;
      } else {
        updatedTotalBeforeDiscount += txItem.subtotal;
      }
    }

    final tx = await (_db.select(_db.transactions)..where((t) => t.id.equals(txId))).getSingle();
    final double newTotal = (updatedTotalBeforeDiscount - tx.discount).clamp(0.0, 99999999.0);

    double? newPaymentAmount = tx.paymentAmount;
    if (tx.paymentType == 'cash' && tx.paymentAmount != null) {
      if (tx.paymentAmount! < newTotal) {
        newPaymentAmount = newTotal;
      }
    } else {
      newPaymentAmount = newTotal;
    }

    await (_db.update(_db.transactions)..where((t) => t.id.equals(txId)))
        .write(TransactionsCompanion(
      total: Value(newTotal),
      paymentAmount: Value(newPaymentAmount),
      syncStatus: const Value('pending_sync'),
      conflictDetails: const Value(null),
    ));

    syncPendingTransactions();
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

final isSyncingProvider = StateProvider<bool>((ref) => false);

final pendingSyncCountProvider = StreamProvider<int>((ref) {
  final syncService = ref.watch(offlineSyncServiceProvider);
  return syncService.watchPendingCount();
});

final conflictCountProvider = StreamProvider<int>((ref) {
  final syncService = ref.watch(offlineSyncServiceProvider);
  return syncService.watchConflictCount();
});

enum AppSyncStatus { synced, pendingSync, syncing, conflict }

final syncStatusStateProvider = Provider<AppSyncStatus>((ref) {
  final pendingCountAsync = ref.watch(pendingSyncCountProvider);
  final conflictCountAsync = ref.watch(conflictCountProvider);
  final isSyncing = ref.watch(isSyncingProvider);

  if (isSyncing) {
    return AppSyncStatus.syncing;
  }

  final conflicts = conflictCountAsync.valueOrNull ?? 0;
  if (conflicts > 0) {
    return AppSyncStatus.conflict;
  }

  final pending = pendingCountAsync.valueOrNull ?? 0;
  if (pending > 0) {
    return AppSyncStatus.pendingSync;
  }

  return AppSyncStatus.synced;
});
