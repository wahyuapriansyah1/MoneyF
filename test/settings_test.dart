import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyf/state/finance_state.dart';
import 'package:moneyf/main.dart';
import 'package:moneyf/screens/settings_screen.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'test_token',
      'auth_user_email': 'test@example.com',
      'auth_user_name': 'Test User',
    });
  });

  testWidgets('SettingsScreen renders without crash', (WidgetTester tester) async {
    final financeState = FinanceState();
    await tester.pumpWidget(
      FinanceProvider(
        financeState: financeState,
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pengaturan'), findsWidgets);
    expect(find.text('Akun & Pengaturan'), findsOneWidget);
    expect(find.text('Keluar'), findsWidgets);
  });

  testWidgets('MainTabScreen switch to SettingsScreen tab renders properly', (WidgetTester tester) async {
    final financeState = FinanceState();
    await tester.pumpWidget(
      FinanceProvider(
        financeState: financeState,
        child: const MaterialApp(
          home: MainTabScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Tap the 'Pengaturan' tab in the bottom nav bar
    await tester.tap(find.text('Pengaturan').first);
    await tester.pumpAndSettle();

    expect(find.text('Akun & Pengaturan'), findsOneWidget);
    expect(find.text('Keluar'), findsWidgets);
    expect(find.text('Informasi Akun'), findsOneWidget);
  });

  testWidgets('All tabs in MainTabScreen render their content properly', (WidgetTester tester) async {
    final financeState = FinanceState();
    await tester.pumpWidget(
      FinanceProvider(
        financeState: financeState,
        child: const MaterialApp(
          home: MainTabScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Tab 0: HomeScreen
    print('Testing Tab 0: HomeScreen');
    expect(find.text('Total Uang Bersih'), findsOneWidget);

    // Tab 1: AnalyticsScreen
    print('Testing Tab 1: AnalyticsScreen');
    await tester.tap(find.text('Analisis'));
    await tester.pumpAndSettle();
    expect(find.text('Arus Kas Keuangan'), findsOneWidget);

    // Tab 2: DebtScreen
    print('Testing Tab 2: DebtScreen');
    await tester.tap(find.text('Utang'));
    await tester.pumpAndSettle();
    expect(find.text('Utang & Piutang'), findsOneWidget);
  });
}
