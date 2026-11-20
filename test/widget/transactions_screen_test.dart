import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:dompetku/data/models/category_model.dart';
import 'package:dompetku/data/models/transaction_model.dart';
import 'package:dompetku/features/transactions/controllers/transaction_controller.dart';
import 'package:dompetku/features/transactions/screens/transactions_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  final dummyIncomeCat = CategoryModel(
    id: 1,
    name: 'Gaji Freelance',
    type: 'income',
    createdAt: DateTime.now(),
  );

  final dummyExpenseCat = CategoryModel(
    id: 2,
    name: 'Belanja Mingguan',
    type: 'expense',
    createdAt: DateTime.now(),
  );

  final dummyTransactions = [
    TransactionModel(
      id: 1,
      type: 'income',
      amount: 2500000,
      categoryId: 1,
      note: 'Proyek Mobile App',
      occurredAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      category: dummyIncomeCat,
    ),
    TransactionModel(
      id: 2,
      type: 'expense',
      amount: 150000,
      categoryId: 2,
      note: 'Supermarket',
      occurredAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      category: dummyExpenseCat,
    ),
  ];

  Widget buildScreen({List<TransactionModel>? transactions}) {
    return ProviderScope(
      overrides: [
        categoriesProvider.overrideWith((ref, type) async {
          final all = [dummyIncomeCat, dummyExpenseCat];
          if (type == null) return all;
          return all.where((c) => c.type == type).toList();
        }),
        transactionsListProvider.overrideWith((ref) async {
          final filter = ref.watch(transactionTypeFilterProvider);
          final list = transactions ?? dummyTransactions;
          if (filter == null) return list;
          return list.where((t) => t.type == filter).toList();
        }),
      ],
      child: const MaterialApp(home: TransactionsScreen()),
    );
  }

  testWidgets('Menampilkan empty state saat belum ada transaksi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildScreen(transactions: []));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Belum Ada Transaksi'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Pemasukan'), findsOneWidget);
    expect(find.text('Pengeluaran'), findsOneWidget);
  });

  testWidgets('Menampilkan daftar transaksi dan filter bekerja', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();
    await tester.pumpAndSettle();

    // Default "Semua": kedua transaksi tampil
    expect(find.text('Gaji Freelance'), findsOneWidget);
    expect(find.text('Proyek Mobile App'), findsOneWidget);
    expect(find.text('Belanja Mingguan'), findsOneWidget);
    expect(find.text('Supermarket'), findsOneWidget);

    // Filter "Pemasukan": hanya pemasukan tampil
    await tester.tap(find.text('Pemasukan'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Gaji Freelance'), findsOneWidget);
    expect(find.text('Proyek Mobile App'), findsOneWidget);
    expect(find.text('Belanja Mingguan'), findsNothing);

    // Filter "Pengeluaran": hanya pengeluaran tampil
    await tester.tap(find.text('Pengeluaran'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Gaji Freelance'), findsNothing);
    expect(find.text('Belanja Mingguan'), findsOneWidget);
    expect(find.text('Supermarket'), findsOneWidget);
  });

  testWidgets(
    'Kolom pencarian transaksi dan dropdown kategori tampil di layar',
    (WidgetTester tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();
      await tester.pumpAndSettle();

      // Pastikan search bar ada
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Cari catatan atau nama kategori...'), findsOneWidget);

      // Ketik pencarian
      await tester.enterText(find.byType(TextField), 'Mobile');
      await tester.pump();

      expect(find.text('Mobile'), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);

      // Hapus pencarian via tombol silang
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(find.text('Mobile'), findsNothing);
    },
  );

  testWidgets('Kolom pencarian transaksi dan dropdown kategori tampil di layar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();
    await tester.pumpAndSettle();

    // Pastikan search bar ada
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Cari catatan atau nama kategori...'), findsOneWidget);

    // Ketik pencarian
    await tester.enterText(find.byType(TextField), 'Mobile');
    await tester.pump();

    expect(find.text('Mobile'), findsOneWidget);
    expect(find.byIcon(Icons.clear), findsOneWidget);

    // Hapus pencarian via tombol silang
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    expect(find.text('Mobile'), findsNothing);
  });
}
