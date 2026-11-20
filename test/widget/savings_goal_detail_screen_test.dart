import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:dompetku/core/utils/currency_formatter.dart';
import 'package:dompetku/data/models/savings_goal_model.dart';
import 'package:dompetku/data/models/savings_movement_model.dart';
import 'package:dompetku/features/savings/controllers/savings_controller.dart';
import 'package:dompetku/features/savings/screens/savings_goal_detail_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  final testGoal = SavingsGoalModel(
    id: 10,
    name: 'Dana Darurat 2026',
    targetAmount: 12000000,
    currentAmount: 4000000,
    targetDate: DateTime(2026, 12, 31),
    isArchived: false,
    createdAt: DateTime.now(),
  );

  final testMovements = [
    SavingsMovementModel(
      id: 1,
      goalId: 10,
      amount: 3000000,
      type: 'deposit',
      note: 'Bonus tahunan',
      occurredAt: DateTime(2026, 1, 15),
    ),
    SavingsMovementModel(
      id: 2,
      goalId: 10,
      amount: 1000000,
      type: 'deposit',
      note: 'Gaji Januari',
      occurredAt: DateTime(2026, 1, 25),
    ),
  ];

  testWidgets(
    'Menampilkan informasi progres dan riwayat mutasi pada halaman detail',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            savingsGoalDetailProvider(
              10,
            ).overrideWith((ref) => Future.value(testGoal)),
            savingsMovementsProvider(
              10,
            ).overrideWith((ref) => Future.value(testMovements)),
          ],
          child: const MaterialApp(home: SavingsGoalDetailScreen(goalId: 10)),
        ),
      );
      await tester.pumpAndSettle();

      // Verifikasi informasi header dan progres
      expect(find.text('Dana Darurat 2026'), findsWidgets);
      expect(find.text(CurrencyFormatter.format(4000000)), findsOneWidget);
      expect(find.text(CurrencyFormatter.format(12000000)), findsOneWidget);
      expect(
        find.text('Sisa: ${CurrencyFormatter.format(8000000)}'),
        findsOneWidget,
      );

      // Verifikasi tombol aksi cepat
      expect(find.text('Setor'), findsOneWidget);
      expect(find.text('Tarik'), findsOneWidget);

      // Verifikasi riwayat mutasi
      expect(find.text('Riwayat Mutasi'), findsOneWidget);
      expect(find.text('Setoran Tabungan'), findsNWidgets(2));
      expect(
        find.text('+ ${CurrencyFormatter.format(3000000)}'),
        findsOneWidget,
      );
      expect(
        find.text('+ ${CurrencyFormatter.format(1000000)}'),
        findsOneWidget,
      );
    },
  );
}
