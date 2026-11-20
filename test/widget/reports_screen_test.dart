import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:dompetku/core/utils/currency_formatter.dart';
import 'package:dompetku/data/models/category_expense_model.dart';
import 'package:dompetku/features/reports/controllers/reports_controller.dart';
import 'package:dompetku/features/reports/screens/reports_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  final dummyCategoryExpenses = [
    const CategoryExpenseModel(
      categoryId: 1,
      categoryName: 'Makanan & Minuman',
      totalAmount: 1200000,
      transactionCount: 5,
      percentage: 0.6,
    ),
    const CategoryExpenseModel(
      categoryId: 2,
      categoryName: 'Transportasi',
      totalAmount: 800000,
      transactionCount: 3,
      percentage: 0.4,
    ),
  ];

  final dummyReportData = ReportData(
    totalIncome: 5000000,
    totalExpense: 2000000,
    netCashFlow: 3000000,
    categoryExpenses: dummyCategoryExpenses,
    startDate: DateTime(2026, 11, 1),
    endDate: DateTime(2026, 11, 30),
    period: ReportPeriod.monthly,
  );

  final emptyReportData = ReportData(
    totalIncome: 0,
    totalExpense: 0,
    netCashFlow: 0,
    categoryExpenses: const [],
    startDate: DateTime(2026, 11, 1),
    endDate: DateTime(2026, 11, 30),
    period: ReportPeriod.monthly,
  );

  Widget createWidgetUnderTest({required ReportData data}) {
    return ProviderScope(
      overrides: [
        reportsDataProvider.overrideWith((ref) => Future.value(data)),
      ],
      child: const MaterialApp(home: ReportsScreen()),
    );
  }

  testWidgets('Menampilkan empty state jika belum ada pengeluaran', (
    tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest(data: emptyReportData));
    await tester.pumpAndSettle();

    expect(find.text('Belum Ada Pengeluaran'), findsOneWidget);
    expect(find.text('Tidak ada pengeluaran pada periode ini'), findsOneWidget);
    expect(find.text(CurrencyFormatter.format(0)), findsWidgets);
  });

  testWidgets(
    'Menampilkan ringkasan arus kas dan rincian kategori dengan benar',
    (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(data: dummyReportData));
      await tester.pumpAndSettle();

      // Verifikasi Pemilih Periode
      expect(find.text('Harian'), findsOneWidget);
      expect(find.text('Mingguan'), findsOneWidget);
      expect(find.text('Bulanan'), findsOneWidget);

      // Verifikasi Ringkasan Arus Kas
      expect(find.text('Pemasukan'), findsOneWidget);
      expect(find.text(CurrencyFormatter.format(5000000)), findsOneWidget);

      expect(find.text('Pengeluaran'), findsOneWidget);
      expect(find.text(CurrencyFormatter.format(2000000)), findsWidgets);

      expect(find.text('Selisih Kas Bersih:'), findsOneWidget);
      expect(
        find.text('+${CurrencyFormatter.format(3000000)}'),
        findsOneWidget,
      );

      // Verifikasi Rincian Kategori
      expect(find.text('Makanan & Minuman'), findsOneWidget);
      expect(find.textContaining('5 transaksi'), findsOneWidget);
      expect(find.text(CurrencyFormatter.format(1200000)), findsOneWidget);

      expect(find.text('Transportasi'), findsOneWidget);
      expect(find.textContaining('3 transaksi'), findsOneWidget);
      expect(find.text(CurrencyFormatter.format(800000)), findsOneWidget);
    },
  );
}
