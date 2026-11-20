import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:dompetku/data/models/category_model.dart';
import 'package:dompetku/data/models/transaction_model.dart';
import 'package:dompetku/features/transactions/controllers/transaction_controller.dart';
import 'package:dompetku/features/transactions/screens/add_edit_transaction_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  final dummyCategories = [
    CategoryModel(
      id: 1,
      name: 'Makanan & Minuman',
      type: 'expense',
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: 2,
      name: 'Gaji',
      type: 'income',
      createdAt: DateTime.now(),
    ),
  ];

  Widget buildScreen({
    String initialType = 'expense',
    TransactionModel? transaction,
  }) {
    return ProviderScope(
      overrides: [
        categoriesProvider.overrideWith((ref, type) async {
          return dummyCategories
              .where((c) => type == null || c.type == type)
              .toList();
        }),
      ],
      child: MaterialApp(
        home: AddEditTransactionScreen(
          initialType: initialType,
          transaction: transaction,
        ),
      ),
    );
  }

  testWidgets('Form menolak penyimpanan jika nominal kosong', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();
    await tester.pumpAndSettle();

    final saveButton = find.widgetWithText(ElevatedButton, 'Catat Transaksi');
    expect(saveButton, findsOneWidget);

    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Nominal wajib diisi'), findsOneWidget);
  });

  testWidgets('Form dapat berganti antara Pengeluaran dan Pemasukan', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildScreen(initialType: 'expense'));
    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pemasukan'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Nominal (Rp)'), findsOneWidget);
  });

  testWidgets('Form dapat memilih kategori dan mengisi catatan', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildScreen(initialType: 'expense'));
    await tester.pump();
    await tester.pumpAndSettle();

    // Masukkan nominal 50.000
    final nominalField = find.byType(TextFormField).first;
    await tester.enterText(nominalField, '50000');
    await tester.pumpAndSettle();

    // Pilih kategori
    final dropdown = find.byType(DropdownButtonFormField<int>);
    expect(dropdown, findsOneWidget);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    final categoryItem = find.text('Makanan & Minuman').last;
    await tester.tap(categoryItem);
    await tester.pumpAndSettle();

    // Masukkan catatan
    final noteField = find.byType(TextFormField).last;
    await tester.enterText(noteField, 'Bakso siang');
    await tester.pumpAndSettle();

    expect(find.text('Bakso siang'), findsOneWidget);
  });

  testWidgets('Mode ubah menampilkan tombol hapus dan dialog konfirmasi', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now();

    final tx = TransactionModel(
      id: 1,
      type: 'expense',
      amount: 75000,
      categoryId: 1,
      note: 'Beli Buku',
      occurredAt: now,
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(buildScreen(transaction: tx));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Ubah Transaksi'), findsOneWidget);
    expect(find.text('Simpan Perubahan'), findsOneWidget);

    final deleteButton = find.byTooltip('Hapus Transaksi');
    expect(deleteButton, findsOneWidget);

    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(find.text('Hapus Transaksi?'), findsOneWidget);
    expect(find.text('Batal'), findsOneWidget);
    expect(find.text('Hapus'), findsOneWidget);
  });
}
