// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pos_app/main.dart' as app;
import 'package:pos_app/features/transaction/ui/widgets/item_card.dart';

// Credentials injected via --dart-define at CI time (never hardcoded)
const String kTestUsername = String.fromEnvironment('TEST_USERNAME');
const String kTestPassword = String.fromEnvironment('TEST_PASSWORD');

// Unique test item name used across all tests
const String kTestItemName = 'ci_test_automation_item';

/// Helper: Polls the UI to wait for a widget matching [finder] to appear.
Future<bool> _waitForWidget(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 500));
    if (finder.evaluate().isNotEmpty) {
      return true;
    }
  }
  return false;
}

/// Helper: Login the test user and wait for the home screen to appear.
Future<void> _login(WidgetTester tester) async {
  app.main();
  await tester.pumpAndSettle(const Duration(seconds: 4));

  // Check if session is already active / restored from previous test in sequence
  if (find.text('Dashboard').evaluate().isNotEmpty ||
      find.byType(NavigationBar).evaluate().isNotEmpty) {
    print('ℹ️ Session restored/active: already on MainLayout.');
    return;
  }

  // Find username and password fields
  final usernameFinder = find.widgetWithText(TextField, 'Username');
  final passwordFinder = find.widgetWithText(TextField, 'Password');

  expect(usernameFinder, findsOneWidget, reason: 'Username field must be visible on login screen');
  expect(passwordFinder, findsOneWidget, reason: 'Password field must be visible on login screen');

  await tester.enterText(usernameFinder, kTestUsername);
  await tester.enterText(passwordFinder, kTestPassword);
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pump();

  // Wait for the home screen (Dashboard tab) to appear
  final dashboardFinder = find.text('Dashboard');
  final loggedIn = await _waitForWidget(tester, dashboardFinder);

  expect(loggedIn, isTrue, reason: 'Failed to log in: Dashboard nav tab did not load within 15s');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ────────────────────────────────────────────────────────────────
  // TEST 1: Login Flow
  // ────────────────────────────────────────────────────────────────
  testWidgets('TEST 1 — Login: enters credentials, lands on main screen',
      (WidgetTester tester) async {
    await _login(tester);
    print('✅ TEST 1 PASSED: Login flow works');
  });

  // ────────────────────────────────────────────────────────────────
  // TEST 2: Add Item
  // Creates a test item that will be used in subsequent tests.
  // ────────────────────────────────────────────────────────────────
  testWidgets('TEST 2 — Add Item: creates $kTestItemName',
      (WidgetTester tester) async {
    await _login(tester);

    // Navigate to Item tab
    final itemTab = find.text('Item');
    expect(itemTab, findsWidgets);
    await tester.tap(itemTab.first);
    await tester.pump();

    // Wait for the Item management screen to render
    await _waitForWidget(tester, find.text('Manajemen Item'));

    // Tap the FAB to open the add item form
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Fill in the item form
    final nameField = find.widgetWithText(TextFormField, 'Nama Item');
    final descField = find.widgetWithText(TextFormField, 'Deskripsi');
    final buyPriceField = find.widgetWithText(TextFormField, 'Harga Beli');
    final sellPriceField = find.widgetWithText(TextFormField, 'Harga Jual');
    final stockField = find.widgetWithText(TextFormField, 'Stok');

    expect(nameField, findsOneWidget);
    expect(descField, findsOneWidget);
    expect(buyPriceField, findsOneWidget);
    expect(sellPriceField, findsOneWidget);
    expect(stockField, findsOneWidget);

    await tester.enterText(nameField, kTestItemName);
    await tester.enterText(descField, 'CI automation test item');
    await tester.enterText(buyPriceField, '5000');
    await tester.enterText(sellPriceField, '10000');
    await tester.enterText(stockField, '100');

    // Submit the form
    final submitButton = find.widgetWithText(ElevatedButton, 'Tambah Item');
    expect(submitButton, findsOneWidget);
    await tester.tap(submitButton);
    await tester.pump();

    // Verify item appears in the list
    final createdItem = find.text(kTestItemName);
    final itemCreated = await _waitForWidget(tester, createdItem);
    expect(itemCreated, isTrue, reason: 'Item $kTestItemName was not found in the list after creation');

    print('✅ TEST 2 PASSED: Item added successfully');
  });

  // ────────────────────────────────────────────────────────────────
  // TEST 3: Transaction Checkout + Verify Print Button
  // Uses the item from TEST 2, verifies the 'Cetak' button exists
  // in the success dialog.
  // ────────────────────────────────────────────────────────────────
  testWidgets('TEST 3 — Transaction: checkout and verify Cetak button',
      (WidgetTester tester) async {
    await _login(tester);

    // Navigate to Transaksi tab
    final transaksiTab = find.text('Transaksi');
    expect(transaksiTab, findsWidgets);
    await tester.tap(transaksiTab.first);
    await tester.pump();

    // Wait for the Transaksi screen to render
    await _waitForWidget(tester, find.text('Transaksi').first);

    // Search for the test item
    final searchBar = find.byType(SearchBar);
    expect(searchBar, findsOneWidget);
    await tester.enterText(searchBar, kTestItemName);

    // Wait for debounce search timer (500ms) + results to load
    await tester.pump(const Duration(milliseconds: 700));

    // Wait for the ItemCard to appear in search results
    final itemCard = find.byType(ItemCard);
    final resultsLoaded = await _waitForWidget(tester, itemCard);
    expect(resultsLoaded, isTrue, reason: 'ItemCard for $kTestItemName did not appear in search results');

    // Tap the item to add to cart
    await tester.tap(itemCard.first);
    await tester.pump();

    // Open the cart if on mobile (on tablet/1600x1024 web screen, CartPanel is already open on the right)
    final cartButton = find.textContaining('Lihat Keranjang');
    if (cartButton.evaluate().isNotEmpty) {
      await tester.tap(cartButton.first);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    // Tap BAYAR to open checkout
    final payButton = find.text('BAYAR');
    expect(payButton, findsWidgets, reason: 'BAYAR button not found inside CartPanel');
    await tester.tap(payButton.first);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Fill cash amount
    final cashField = find.widgetWithText(TextField, 'Jumlah Uang Diterima');
    expect(cashField, findsWidgets);
    await tester.enterText(cashField.first, '50000');
    await tester.pumpAndSettle();

    // Confirm payment
    final confirmButton = find.text('KONFIRMASI BAYAR');
    expect(confirmButton, findsWidgets);
    await tester.tap(confirmButton.first);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Handle "Buka Shift Kasir" dialog if the cashier shift has not been opened yet in this CI session
    final openShiftDialog = find.textContaining('Buka Shift');
    if (openShiftDialog.evaluate().isNotEmpty) {
      print('Buka Shift Kasir dialog detected, entering starting cash modal...');
      final modalAwalField = find.byType(TextFormField);
      if (modalAwalField.evaluate().isNotEmpty) {
        await tester.enterText(modalAwalField.first, '100000');
        await tester.pumpAndSettle();
      }
      final bukaShiftBtn = find.widgetWithText(ElevatedButton, 'Buka Shift');
      if (bukaShiftBtn.evaluate().isNotEmpty) {
        await tester.tap(bukaShiftBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      } else {
        final anyBukaBtn = find.textContaining('Buka Shift');
        if (anyBukaBtn.evaluate().isNotEmpty) {
          await tester.tap(anyBukaBtn.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }
    }

    // Wait for the success dialog
    final successTitle = find.text('Transaksi Berhasil');
    final checkoutDone = await _waitForWidget(tester, successTitle);
    expect(checkoutDone, isTrue, reason: 'Success dialog did not appear after checkout');

    // ✅ VERIFY PRINT BUTTON ('Cetak') EXISTS
    final printButton = find.text('Cetak');
    expect(printButton, findsWidgets, reason: 'Cetak (print) button not found in success dialog');

    // Close the success dialog
    final closeButton = find.text('Tutup / Transaksi Baru');
    expect(closeButton, findsWidgets);
    await tester.tap(closeButton.first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    print('✅ TEST 3 PASSED: Transaction checkout completed, Cetak button verified');
  });

  // ────────────────────────────────────────────────────────────────
  // TEST 4: Refund
  // Navigates to history, opens the transaction from TEST 3,
  // and performs a refund.
  // ────────────────────────────────────────────────────────────────
  testWidgets('TEST 4 — Refund: refunds the transaction from TEST 3',
      (WidgetTester tester) async {
    await _login(tester);

    // Navigate to History tab
    final historyTab = find.text('Riwayat');
    expect(historyTab, findsWidgets);
    await tester.tap(historyTab.first);
    await tester.pump();

    // Wait for the history screen to load
    final historyTitle = find.text('Riwayat Transaksi');
    await _waitForWidget(tester, historyTitle);

    // Wait for transaction cards to load
    final transactionCards = find.byType(Card);
    final cardsLoaded = await _waitForWidget(tester, transactionCards);
    expect(cardsLoaded, isTrue, reason: 'No transaction cards found in history');

    // Tap the first (most recent) transaction card
    await tester.tap(transactionCards.first);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Find and tap the REFUND button in the receipt detail dialog
    final refundButton = find.text('REFUND TRANSAKSI');
    final refundVisible = await _waitForWidget(tester, refundButton);
    expect(refundVisible, isTrue, reason: 'REFUND TRANSAKSI button not found in receipt detail');
    await tester.tap(refundButton.first);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Confirm the refund in the confirmation dialog
    final confirmRefund = find.widgetWithText(TextButton, 'Refund');
    expect(confirmRefund, findsWidgets);
    await tester.tap(confirmRefund.first);
    await tester.pump();

    // Wait for the refund API call to complete and dialogs to close
    // On success: both dialogs pop, snackbar appears
    final refundSuccess = find.text('Transaksi berhasil di-refund!');
    final refundDone = await _waitForWidget(tester, refundSuccess, timeout: const Duration(seconds: 10));
    expect(refundDone, isTrue, reason: 'Refund success message did not appear');

    await tester.pumpAndSettle(const Duration(seconds: 2));

    print('✅ TEST 4 PASSED: Transaction refunded successfully');
  });

  // ────────────────────────────────────────────────────────────────
  // TEST 5: Delete Item
  // Cleans up the test item created in TEST 2.
  // ────────────────────────────────────────────────────────────────
  testWidgets('TEST 5 — Delete Item: deletes $kTestItemName',
      (WidgetTester tester) async {
    await _login(tester);

    // Navigate to Item tab
    final itemTab = find.text('Item');
    expect(itemTab, findsWidgets);
    await tester.tap(itemTab.first);
    await tester.pump();

    // Wait for the Item management screen to render
    await _waitForWidget(tester, find.text('Manajemen Item'));

    // Use the search field to filter to only the test item
    final searchField = find.byType(TextField);
    expect(searchField, findsWidgets);
    await tester.enterText(searchField.first, kTestItemName);
    await tester.pump(const Duration(milliseconds: 700));

    // Wait for the filtered list to load
    final testItemText = find.text(kTestItemName);
    final itemFound = await _waitForWidget(tester, testItemText);
    expect(itemFound, isTrue, reason: 'Test item $kTestItemName not found in filtered item list');

    // Tap the delete icon (should be only one since the list is filtered)
    final deleteIcon = find.byIcon(Icons.delete_outline);
    expect(deleteIcon, findsWidgets);
    await tester.tap(deleteIcon.first);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Confirm deletion in the dialog
    final confirmDelete = find.widgetWithText(TextButton, 'Hapus');
    expect(confirmDelete, findsWidgets);
    await tester.tap(confirmDelete.first);
    await tester.pump();

    // Wait for the delete API call to complete
    final deleteSuccess = find.text('Item berhasil dihapus!');
    final deleteDone = await _waitForWidget(tester, deleteSuccess, timeout: const Duration(seconds: 10));
    expect(deleteDone, isTrue, reason: 'Delete success message did not appear');

    await tester.pumpAndSettle(const Duration(seconds: 2));

    print('✅ TEST 5 PASSED: Test item deleted successfully');
  });
}
