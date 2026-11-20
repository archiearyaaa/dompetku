import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:dompetku/features/dashboard/screens/dashboard_screen.dart';
import 'package:dompetku/features/dashboard/widgets/balance_card.dart';
import 'package:dompetku/features/dashboard/widgets/quick_actions.dart';
import 'package:dompetku/features/dashboard/widgets/summary_cards.dart';
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

  Widget buildDashboard({
    VoidCallback? onNavigateToTransactions,
    VoidCallback? onNavigateToSavings,
    VoidCallback? onNavigateToDebts,
    VoidCallback? onAddIncome,
    VoidCallback? onAddExpense,
  }) {
    return ProviderScope(
      overrides: [
        dashboardSummaryProvider.overrideWith((ref) async => dummySummary),
      ],
      child: MaterialApp(
        home: DashboardScreen(
          onNavigateToTransactions: onNavigateToTransactions,
          onNavigateToSavings: onNavigateToSavings,
          onNavigateToDebts: onNavigateToDebts,
          onAddIncome: onAddIncome,
          onAddExpense: onAddExpense,
        ),
      ),
    );
  }

  testWidgets('Dashboard menampilkan kartu saldo, aksi cepat, dan ringkasan', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildDashboard());
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(BalanceCard), findsOneWidget);
    expect(find.byType(QuickActions), findsOneWidget);
    expect(find.byType(SummaryCards), findsOneWidget);
    expect(find.text('Transaksi Terbaru'), findsOneWidget);
    expect(find.text('Lihat Semua'), findsOneWidget);
  });

  testWidgets('Tombol pengaturan di AppBar membuka halaman Pengaturan', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildDashboard());
    await tester.pump();
    await tester.pumpAndSettle();

    final settingsButton = find.byTooltip('Pengaturan');
    expect(settingsButton, findsOneWidget);

    await tester.tap(settingsButton);
    await tester.pumpAndSettle();

    expect(find.text('Tentang Dompetku'), findsOneWidget);
    expect(
      find.text('SQLite Offline-First (Lokal di perangkat)'),
      findsOneWidget,
    );
  });

  testWidgets('Tombol Lihat Semua memicu callback onNavigateToTransactions', (
    WidgetTester tester,
  ) async {
    bool tapped = false;
    await tester.pumpWidget(
      buildDashboard(
        onNavigateToTransactions: () {
          tapped = true;
        },
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lihat Semua'));
    expect(tapped, isTrue);
  });
}
