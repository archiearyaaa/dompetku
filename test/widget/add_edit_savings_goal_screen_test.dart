import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:dompetku/core/utils/currency_formatter.dart';
import 'package:dompetku/data/models/savings_goal_model.dart';
import 'package:dompetku/features/savings/screens/add_edit_savings_goal_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets(
    'Menampilkan form tambah target tabungan dengan validasi input wajib',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: AddEditSavingsGoalScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Target Tabungan Baru'), findsOneWidget);
      expect(find.text('Buat Target'), findsOneWidget);

      // Coba tekan tombol tanpa mengisi form
      await tester.tap(find.text('Buat Target'));
      await tester.pumpAndSettle();

      expect(find.text('Nama target wajib diisi'), findsOneWidget);
      expect(find.text('Target nominal wajib diisi'), findsOneWidget);
    },
  );

  testWidgets('Menampilkan mode edit dengan data target yang sudah terisi', (
    tester,
  ) async {
    final existingGoal = SavingsGoalModel(
      id: 99,
      name: 'Liburan ke Bali',
      targetAmount: 7500000,
      currentAmount: 2000000,
      targetDate: DateTime(2027, 6, 15),
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: AddEditSavingsGoalScreen(goal: existingGoal)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Target Tabungan'), findsOneWidget);
    expect(find.text('Simpan Perubahan'), findsOneWidget);
    expect(find.text('Liburan ke Bali'), findsOneWidget);
    expect(find.text(CurrencyFormatter.format(7500000)), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });
}
