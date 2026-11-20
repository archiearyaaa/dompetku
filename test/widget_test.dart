import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:dompetku/app.dart';
import 'package:dompetku/core/constants/app_constants.dart';
import 'package:dompetku/features/debts/controllers/debt_controller.dart';
import 'package:dompetku/features/reports/controllers/reports_controller.dart';
import 'package:dompetku/features/savings/controllers/savings_controller.dart';
import 'package:dompetku/features/transactions/controllers/transaction_controller.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  const dummySummary = DashboardSummary(
    availableBalance: 0,
    monthIncome: 0,
    monthExpense: 0,
    recentTransactions: [],
  );

  final dummyReportData = ReportData(
    totalIncome: 0,
    totalExpense: 0,
    netCashFlow: 0,
    categoryExpenses: const [],
    startDate: DateTime(2026, 11, 1),
    endDate: DateTime(2026, 11, 30),
    period: ReportPeriod.monthly,
  );

  Widget createTestApp() {
    return ProviderScope(
      overrides: [
        dashboardSummaryProvider.overrideWith((ref) async => dummySummary),
        transactionsListProvider.overrideWith((ref) async => []),
        savingsGoalsProvider.overrideWith((ref) async => []),
        totalSavingsProvider.overrideWith((ref) async => 0),
        debtsSummaryProvider.overrideWith(
          (ref) async =>
              const DebtsSummary(totalPayable: 0, totalReceivable: 0),
        ),
        debtsListProvider.overrideWith((ref) async => []),
        reportsDataProvider.overrideWith((ref) async => dummyReportData),
      ],
      child: const DompetkuApp(),
    );
  }

  testWidgets('Aplikasi menampilkan AppBar dengan judul Dompetku', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestApp());
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text(AppConstants.appName), findsOneWidget);
  });

  testWidgets('BottomNavigationBar memiliki 5 tab menu', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestApp());
    await tester.pump();
    await tester.pumpAndSettle();

    final navBar = find.byType(BottomNavigationBar);
    expect(navBar, findsOneWidget);

    expect(
      find.descendant(of: navBar, matching: find.text('Dashboard')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: navBar, matching: find.text('Transaksi')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: navBar, matching: find.text('Tabungan')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: navBar, matching: find.text('Utang')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: navBar, matching: find.text('Laporan')),
      findsOneWidget,
    );
  });

  testWidgets('Navigasi antar tab bekerja dengan benar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestApp());
    await tester.pump();
    await tester.pumpAndSettle();

    final navBar = find.byType(BottomNavigationBar);

    // Tab default adalah Dashboard
    expect(find.text('Saldo Tersedia'), findsOneWidget);

    // Pindah ke tab Transaksi
    await tester.tap(
      find.descendant(of: navBar, matching: find.text('Transaksi')),
    );
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Belum Ada Transaksi'), findsOneWidget);

    // Pindah ke tab Tabungan
    await tester.tap(
      find.descendant(of: navBar, matching: find.text('Tabungan')),
    );
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Belum Ada Target Tabungan'), findsOneWidget);

    // Pindah ke tab Utang
    await tester.tap(find.descendant(of: navBar, matching: find.text('Utang')));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Belum Ada Catatan Utang / Piutang'), findsOneWidget);

    // Pindah ke tab Laporan
    await tester.tap(
      find.descendant(of: navBar, matching: find.text('Laporan')),
    );
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Laporan Keuangan'), findsOneWidget);
    expect(find.text('Belum Ada Pengeluaran'), findsOneWidget);

    // Kembali ke tab Dashboard
    await tester.tap(
      find.descendant(of: navBar, matching: find.text('Dashboard')),
    );
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Saldo Tersedia'), findsOneWidget);
  });

  testWidgets('Floating Action Button membuka modal tambah transaksi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestApp());
    await tester.pump();
    await tester.pumpAndSettle();

    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);

    await tester.tap(fab);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Catat Transaksi Baru'), findsOneWidget);
    expect(find.text('Gaji, bonus, investasi, atau lainnya'), findsOneWidget);
    expect(
      find.text('Makanan, belanja, tagihan, transportasi'),
      findsOneWidget,
    );
  });
}
