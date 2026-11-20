import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:dompetku/core/utils/currency_formatter.dart';
import 'package:dompetku/data/models/debt_model.dart';
import 'package:dompetku/features/debts/controllers/debt_controller.dart';
import 'package:dompetku/features/debts/screens/debts_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  final dummyDebt1 = DebtModel(
    id: 1,
    direction: 'payable',
    personName: 'Bank BCA',
    principalAmount: 5000000,
    paidAmount: 2000000,
    dueDate: DateTime(2027, 12, 31),
    status: 'active',
    createdAt: DateTime.now(),
  );

  final dummyDebt2 = DebtModel(
    id: 2,
    direction: 'receivable',
    personName: 'Rudi Hartono',
    principalAmount: 1500000,
    paidAmount: 1500000,
    status: 'settled',
    createdAt: DateTime.now(),
  );

  Widget createWidgetUnderTest({
    List<DebtModel> debts = const [],
    DebtsSummary summary = const DebtsSummary(
      totalPayable: 0,
      totalReceivable: 0,
    ),
  }) {
    return ProviderScope(
      overrides: [
        debtsSummaryProvider.overrideWith((ref) => Future.value(summary)),
        debtsListProvider.overrideWith((ref) => Future.value(debts)),
      ],
      child: const MaterialApp(home: DebtsScreen()),
    );
  }

  testWidgets('Menampilkan empty state jika belum ada catatan utang/piutang', (
    tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Belum Ada Catatan Utang / Piutang'), findsOneWidget);
    expect(find.text('Catat Utang / Piutang'), findsOneWidget);
  });

  testWidgets(
    'Menampilkan ringkasan dan daftar kartu utang/piutang dengan benar',
    (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          debts: [dummyDebt1, dummyDebt2],
          summary: const DebtsSummary(
            totalPayable: 3000000,
            totalReceivable: 0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verifikasi Ringkasan di atas
      expect(find.text('Total Utang'), findsOneWidget);
      expect(find.text(CurrencyFormatter.format(3000000)), findsWidgets);
      expect(find.text('Total Piutang'), findsOneWidget);
      expect(find.text(CurrencyFormatter.format(0)), findsOneWidget);

      // Verifikasi Kartu 1 (Utang aktif)
      expect(find.text('Bank BCA'), findsOneWidget);
      expect(find.text('Utang'), findsOneWidget);
      expect(
        find.text('Sisa: ${CurrencyFormatter.format(3000000)}'),
        findsOneWidget,
      );

      // Verifikasi Kartu 2 (Piutang lunas)
      expect(find.text('Rudi Hartono'), findsOneWidget);
      expect(find.text('Piutang'), findsOneWidget);
      expect(find.text('Lunas 🎉'), findsOneWidget);
    },
  );
}
