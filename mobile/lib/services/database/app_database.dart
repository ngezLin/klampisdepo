import 'package:drift/drift.dart';
import 'connection/connection.dart' as impl;

part 'app_database.g.dart';

class Items extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text().withLength(max: 100)();
  TextColumn get description => text().nullable()();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  BoolColumn get isStockManaged => boolean().withDefault(const Constant(true))();
  RealColumn get buyPrice => real()();
  RealColumn get price => real()();
  TextColumn get imageUrl => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get serverId => integer().nullable()(); // ID from backend
  TextColumn get status => text()(); // draft, completed, refunded
  RealColumn get total => real()();
  RealColumn get discount => real().withDefault(const Constant(0))();
  RealColumn get paymentAmount => real().nullable()();
  TextColumn get paymentType => text().nullable()();
  TextColumn get transactionType => text().withDefault(const Constant('onsite'))();
  TextColumn get note => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))(); // synced, pending_sync, draft_local
  DateTimeColumn get createdAt => dateTime()();
}

class TransactionItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId => integer().references(Transactions, #id)();
  IntColumn get itemId => integer()();
  TextColumn get itemName => text()();
  IntColumn get quantity => integer()();
  RealColumn get price => real()();
  RealColumn get customPrice => real().nullable()();
  RealColumn get subtotal => real()();
}

@DriftDatabase(tables: [Items, Transactions, TransactionItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() {
  return impl.connect();
}
