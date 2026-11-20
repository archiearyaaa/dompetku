import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:dompetku/core/utils/currency_formatter.dart';
import 'package:dompetku/data/models/debt_model.dart';
import 'package:dompetku/data/models/debt_payment_model.dart';
import 'package:dompetku/features/debts/controllers/debt_controller.dart';
import 'package:dompetku/features/debts/screens/debt_detail_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  final testDebt = DebtModel(
    id: 100,
    direction: 'payable',
    personName: 'Pak Budi',
    principalAmount: 4000000,
    paidAmount: 1000000,
    dueDate: DateTime(2027, 10, 1),
    status: 'active',
    createdAt: DateTime.now(),
  );

  final testPayments = [
    DebtPaymentModel(
      id: 1,
      debtId: 100,
      amount: 1000000,
      occurredAt: DateTime(2026, 11, 1),
      note: 'Cicilan transfer',
    ),
  ];

  testWidgets(
    'Menampilkan ringkasan sisa utang dan riwayat pembayaran pada detail',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            debtDetailProvider(
              100,
            ).overrideWith((ref) => Future.value(testDebt)),
            debtPaymentsProvider(
              100,
            ).overrideWith((ref) => Future.value(testPayments)),
          ],
          child: const MaterialApp(home: DebtDetailScreen(debtId: 100)),
        ),
      );
      await tester.pumpAndSettle();

      // Verifikasi informasi header
      expect(find.text('Pak Budi'), findsOneWidget);
      expect(find.text('UTANG SAYA'), findsOneWidget);
      expect(find.text('25% Terbayar'), findsOneWidget);
      expect(find.text(CurrencyFormatter.format(4000000)), findsOneWidget);
      expect(find.text(CurrencyFormatter.format(3000000)), findsOneWidget);

      // Verifikasi tombol bayar
      expect(find.text('Catat Pembayaran Utang'), findsOneWidget);

      // Verifikasi riwayat pembayaran
      expect(find.text('Riwayat Pembayaran'), findsOneWidget);
      expect(find.text(CurrencyFormatter.format(1000000)), findsOneWidget);
      expect(find.textContaining('Cicilan transfer'), findsOneWidget);
    },
  );
}
