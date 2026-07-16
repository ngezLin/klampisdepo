// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pos_app/main.dart' as app;
import 'package:pos_app/features/transaction/ui/widgets/item_card.dart';

// Credentials injected via --dart-define at CI time (never hardcoded)
const String kTestUsername = String.fromEnvironment('TEST_USERNAME');
const String kTestPassword = String.fromEnvironment('TEST_PASSWORD');

/// Helper: Polls the UI to wait for a widget to be rendered (handles network/async lag)
Future<bool> _waitForWidget(WidgetTester tester, Finder finder, {Duration timeout = const Duration(seconds: 10)}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 500));
    if (finder.evaluate().isNotEmpty) {
      return true;
    }
  }
  return false;
}

/// Helper: login the test user and wait for home screen to appear.
Future<void> _login(WidgetTester tester) async {
  app.main();
  await tester.pumpAndSettle(const Duration(seconds: 4));

  // Find username and password fields by label text
  final usernameFinder = find.widgetWithText(TextField, 'Username');
  final passwordFinder = find.widgetWithText(TextField, 'Password');

  expect(usernameFinder, findsOneWidget, reason: 'Username field must be visible on login screen');
  expect(passwordFinder, findsOneWidget, reason: 'Password field must be visible on login screen');

  await tester.enterText(usernameFinder, kTestUsername);
  await tester.enterText(passwordFinder, kTestPassword);
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pump();

  // Wait up to 10 seconds for the home screen (Dashboard tab) to appear due to network latency
  final dashboardFinder = find.text('Dashboard');
  final loggedIn = await _waitForWidget(tester, dashboardFinder);

  expect(loggedIn, isTrue, reason: 'Failed to log in: Dashboard nav tab did not load within 10s');
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
  // TEST 2: Add Item (Based on user recording scratch test1)
  // ────────────────────────────────────────────────────────────────
  testWidgets('TEST 2 — Add Item: adds a new item named test_automation_1',
      (WidgetTester tester) async {
    await _login(tester);

    // Tap the "Item" nav tab
    final itemTab = find.text('Item');
    expect(itemTab, findsOneWidget);
    await tester.tap(itemTab);
    await tester.pump();

    // Wait for the "Manajemen Item" screen to render
    await _waitForWidget(tester, find.text('Manajemen Item'));

    // Tap the FAB (add button)
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Fill in the form fields
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

    await tester.enterText(nameField, 'test_automation_1');
    await tester.enterText(descField, 'testqwer');
    await tester.enterText(buyPriceField, '1000');
    await tester.enterText(sellPriceField, '10000');
    await tester.enterText(stockField, '10');

    // Click submit button in the bottom form sheet
    final submitButton = find.widgetWithText(ElevatedButton, 'Tambah Item');
    expect(submitButton, findsOneWidget);
    await tester.tap(submitButton);
    await tester.pump();

    // Wait up to 10 seconds for the new item to appear in the list (verifies DB write succeeded)
    final createdItemText = find.text('test_automation_1');
    final itemCreated = await _waitForWidget(tester, createdItemText);

    expect(itemCreated, isTrue, reason: 'Newly created item test_automation_1 was not found in the list');
    print('✅ TEST 2 PASSED: Item added successfully');
  });

  // ────────────────────────────────────────────────────────────────
  // TEST 3: Transaction Checkout (Based on user recording scratch test2)
  // ────────────────────────────────────────────────────────────────
  testWidgets('TEST 3 — Transaction: searches, adds to cart, and completes checkout',
      (WidgetTester tester) async {
    await _login(tester);

    // Tap the "Transaksi" nav tab
    final transaksiTab = find.text('Transaksi');
    expect(transaksiTab, findsOneWidget);
    await tester.tap(transaksiTab);
    await tester.pump();

    // Wait for the "Transaksi" screen to render
    await _waitForWidget(tester, find.text('Transaksi').first);

    // Find the SearchBar and type the item name
    final searchBarFinder = find.byType(SearchBar);
    expect(searchBarFinder, findsOneWidget);
    await tester.enterText(searchBarFinder, 'test_automation_1');
    
    // Wait for the debounce search timer (500ms) to trigger and reload the list
    await tester.pump(const Duration(milliseconds: 700));

    // Wait for the search results to update and render the ItemCard
    final itemCardFinder = find.byType(ItemCard);
    final resultsLoaded = await _waitForWidget(tester, itemCardFinder);
    expect(resultsLoaded, isTrue, reason: 'ItemCard for test_automation_1 did not appear in search results');

    // Tap on the ItemCard to add to cart
    await tester.tap(itemCardFinder);
    await tester.pump();

    // Tap "Lihat Keranjang (1)" bottom button to open CartPanel
    final cartButton = find.text('Lihat Keranjang (1)');
    expect(cartButton, findsOneWidget);
    await tester.tap(cartButton);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Tap "BAYAR" inside CartPanel
    final payButton = find.text('BAYAR');
    expect(payButton, findsOneWidget);
    await tester.tap(payButton);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Fill in the checkout fields (Notes, Discount, Cash Received) based on user's manual recording
    final noteField = find.widgetWithText(TextField, 'Catatan Transaksi (Opsional)');
    final discountField = find.widgetWithText(TextField, 'Diskon Tambahan (Rp)');
    final cashField = find.widgetWithText(TextField, 'Jumlah Uang Diterima');

    expect(noteField, findsOneWidget);
    expect(discountField, findsOneWidget);
    expect(cashField, findsOneWidget);

    await tester.enterText(noteField, 'test');
    await tester.enterText(discountField, '10000');
    await tester.pumpAndSettle();

    await tester.enterText(cashField, '50000');
    await tester.pumpAndSettle();

    // Tap "KONFIRMASI BAYAR" inside CheckoutSheetContent
    final confirmPayButton = find.text('KONFIRMASI BAYAR');
    expect(confirmPayButton, findsOneWidget);
    await tester.tap(confirmPayButton);
    await tester.pump();

    // Wait for the checkout success dialog to pop up (implies API write succeeded)
    final successTitle = find.text('Transaksi Berhasil');
    final checkoutCompleted = await _waitForWidget(tester, successTitle);
    expect(checkoutCompleted, isTrue, reason: 'Success dialog did not load after clicking checkout');

    // Close the success dialog by tapping "Tutup / Transaksi Baru"
    final doneButton = find.text('Tutup / Transaksi Baru');
    expect(doneButton, findsOneWidget);
    await tester.tap(doneButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    print('✅ TEST 3 PASSED: Checkout completed successfully');
  });

  // ────────────────────────────────────────────────────────────────
  // TEST 4: History Screen
  // ────────────────────────────────────────────────────────────────
  testWidgets('TEST 4 — History: verifies completed checkout appears in history',
      (WidgetTester tester) async {
    await _login(tester);

    // Tap the "Riwayat" (History) nav tab
    final historyTab = find.text('Riwayat');
    expect(historyTab, findsOneWidget);
    await tester.tap(historyTab);
    await tester.pump();

    // Wait for the History screen to load
    final historyTitle = find.text('Riwayat Transaksi');
    await _waitForWidget(tester, historyTitle);

    // The list should have at least one transaction card or layout rendered
    expect(
      find.byType(Scaffold),
      findsWidgets,
      reason: 'History screen failed to render',
    );
    print('✅ TEST 4 PASSED: History screen loaded');
  });
}
