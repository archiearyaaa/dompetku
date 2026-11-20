import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:dompetku/core/utils/currency_formatter.dart';
import 'package:dompetku/data/models/debt_model.dart';
import 'package:dompetku/features/debts/screens/add_edit_debt_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets(
    'Menampilkan form catat utang/piutang baru dengan validasi input wajib',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AddEditDebtScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Catat Utang Baru'), findsOneWidget);
      expect(find.text('Simpan Catatan'), findsOneWidget);

      // Coba simpan tanpa mengisi nama & nominal
      await tester.tap(find.text('Simpan Catatan'));
      await tester.pumpAndSettle();

      expect(find.text('Nama pihak wajib diisi'), findsOneWidget);
      expect(find.text('Nominal pokok wajib diisi'), findsOneWidget);
    },
  );

  testWidgets('Menampilkan form edit dengan data yang sudah terisi', (
    tester,
  ) async {
    final existingDebt = DebtModel(
      id: 5,
      direction: 'receivable',
      personName: 'Dewi Lestari',
      principalAmount: 2500000,
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: AddEditDebtScreen(debt: existingDebt)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Piutang'), findsOneWidget);
    expect(find.text('Simpan Perubahan'), findsOneWidget);
    expect(find.text('Dewi Lestari'), findsOneWidget);
    expect(find.text(CurrencyFormatter.format(2500000)), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });
}
