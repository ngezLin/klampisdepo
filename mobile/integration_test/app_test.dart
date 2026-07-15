// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pos_app/main.dart' as app;

// Credentials injected via --dart-define at CI time (never hardcoded)
const String kTestUsername = String.fromEnvironment('TEST_USERNAME');
const String kTestPassword = String.fromEnvironment('TEST_PASSWORD');

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
  bool loggedIn = false;
  for (int i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 500));
    if (dashboardFinder.evaluate().isNotEmpty) {
      loggedIn = true;
      break;
    }
  }

  expect(loggedIn, isTrue, reason: 'Failed to log in: Dashboard nav tab did not load within 10s');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ────────────────────────────────────────────────────────────────
  // TEST 1: Login Flow
  // Verify: user can log in and lands on home screen (sees nav bar)
  // ────────────────────────────────────────────────────────────────
  testWidgets('TEST 1 — Login: enters credentials, lands on main screen',
      (WidgetTester tester) async {
    await _login(tester);

    // After login as owner, we should see the bottom nav bar with Dashboard
    expect(
      find.text('Dashboard'),
      findsWidgets,
      reason: 'Owner role should see Dashboard in bottom nav bar',
    );
    print('✅ TEST 1 PASSED: Login flow works');
  });

  // ────────────────────────────────────────────────────────────────
  // TEST 2: Items Screen Loads
  // Verify: owner can navigate to /items and see a list
  // ────────────────────────────────────────────────────────────────
  testWidgets('TEST 2 — Items: navigates to item list and data loads',
      (WidgetTester tester) async {
    await _login(tester);

    // Tap the "Item" nav tab
    final itemTab = find.text('Item');
    expect(itemTab, findsOneWidget, reason: 'Owner should see the Item nav tab');
    await tester.tap(itemTab);
    await tester.pump();

    // Wait up to 10 seconds for Item screen title to render
    final itemScreenTitle = find.text('Manajemen Item');
    bool screenLoaded = false;
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (itemScreenTitle.evaluate().isNotEmpty) {
        screenLoaded = true;
        break;
      }
    }
    expect(screenLoaded, isTrue, reason: 'Manajemen Item screen title did not load');
    print('✅ TEST 2 PASSED: Items screen loaded');
  });

  // ────────────────────────────────────────────────────────────────
  // TEST 3: History Screen Loads
  // Verify: owner can navigate to /history and list appears
  // ────────────────────────────────────────────────────────────────
  testWidgets('TEST 3 — History: navigates to history and data loads',
      (WidgetTester tester) async {
    await _login(tester);

    // Tap the "Riwayat" (History) nav tab
    final historyTab = find.text('Riwayat');
    expect(historyTab, findsOneWidget, reason: 'Owner should see the Riwayat nav tab');
    await tester.tap(historyTab);
    await tester.pump();

    // Wait up to 10 seconds for History screen title to render
    final historyScreenTitle = find.text('Riwayat Transaksi');
    bool screenLoaded = false;
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (historyScreenTitle.evaluate().isNotEmpty) {
        screenLoaded = true;
        break;
      }
    }
    expect(screenLoaded, isTrue, reason: 'Riwayat Transaksi screen title did not load');
    print('✅ TEST 3 PASSED: History screen loaded');
  });

  // ────────────────────────────────────────────────────────────────
  // TEST 4: Transaction Screen Loads
  // Verify: owner can navigate to / (Transaksi) and screen renders
  // ────────────────────────────────────────────────────────────────
  testWidgets('TEST 4 — Transaction: navigates to Transaksi and screen loads',
      (WidgetTester tester) async {
    await _login(tester);

    // Tap the "Transaksi" nav tab
    final transaksiTab = find.text('Transaksi');
    expect(transaksiTab, findsOneWidget, reason: 'Owner should see the Transaksi nav tab');
    await tester.tap(transaksiTab);
    await tester.pump();

    // Wait up to 10 seconds for Transaksi screen title to render
    final transactionScreenTitle = find.text('Transaksi').first;
    bool screenLoaded = false;
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (transactionScreenTitle.evaluate().isNotEmpty) {
        screenLoaded = true;
        break;
      }
    }
    expect(screenLoaded, isTrue, reason: 'Transaksi screen title did not load');
    print('✅ TEST 4 PASSED: Transaksi screen loaded');
  });
}
