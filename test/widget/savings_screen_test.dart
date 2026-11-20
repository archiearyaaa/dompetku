import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:dompetku/core/utils/currency_formatter.dart';
import 'package:dompetku/data/models/savings_goal_model.dart';
import 'package:dompetku/features/savings/controllers/savings_controller.dart';
import 'package:dompetku/features/savings/screens/savings_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  final dummyGoal1 = SavingsGoalModel(
    id: 1,
    name: 'Dana Darurat',
    targetAmount: 10000000,
    currentAmount: 5000000,
    targetDate: DateTime(2027, 12, 31),
    isArchived: false,
    createdAt: DateTime.now(),
  );

  final dummyGoal2 = SavingsGoalModel(
    id: 2,
    name: 'Beli Laptop',
    targetAmount: 15000000,
    currentAmount: 15000000,
    isArchived: false,
    createdAt: DateTime.now(),
  );

  Widget createWidgetUnderTest({
    List<SavingsGoalModel> goals = const [],
    int totalSavings = 0,
  }) {
    return ProviderScope(
      overrides: [
        savingsGoalsProvider.overrideWith((ref) => Future.value(goals)),
        totalSavingsProvider.overrideWith((ref) => Future.value(totalSavings)),
      ],
      child: const MaterialApp(home: SavingsScreen()),
    );
  }

  testWidgets('Menampilkan empty state jika belum ada target tabungan', (
    tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest(goals: [], totalSavings: 0));
    await tester.pumpAndSettle();

    expect(find.text('Belum Ada Target Tabungan'), findsOneWidget);
    expect(find.text('Buat Target Tabungan'), findsOneWidget);
    expect(find.text(CurrencyFormatter.format(0)), findsOneWidget);
  });

  testWidgets(
    'Menampilkan daftar kartu target tabungan dan total tabungan dengan benar',
    (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          goals: [dummyGoal1, dummyGoal2],
          totalSavings: 20000000,
        ),
      );
      await tester.pumpAndSettle();

      // Verifikasi total tabungan di kartu atas
      expect(find.text(CurrencyFormatter.format(20000000)), findsOneWidget);

      // Verifikasi kartu target tabungan
      expect(find.text('Dana Darurat'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(
        find.text(
          '${CurrencyFormatter.format(5000000)} / ${CurrencyFormatter.format(10000000)}',
        ),
        findsOneWidget,
      );

      // Verifikasi kartu kedua yang sudah tercapai
      expect(find.text('Beli Laptop'), findsOneWidget);
      expect(find.text('Tercapai 🎉'), findsOneWidget);
    },
  );
}
