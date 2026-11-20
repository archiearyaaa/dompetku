import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:dompetku/core/database/database_helper.dart';
import 'package:dompetku/data/datasources/category_datasource.dart';
import 'package:dompetku/data/datasources/transaction_datasource.dart';
import 'package:dompetku/data/models/transaction_model.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late CategoryDatasource categoryDatasource;
  late TransactionDatasource transactionDatasource;

  setUp(() async {
    db = await DatabaseHelper().initDatabase(customPath: inMemoryDatabasePath);
    DatabaseHelper.setDatabaseForTesting(db);

    categoryDatasource = CategoryDatasource();
    transactionDatasource = TransactionDatasource();
  });

  tearDown(() async {
    if (db.isOpen) {
      await db.close();
    }
    DatabaseHelper.setDatabaseForTesting(null);
  });

  test('Kategori bawaan dapat diambil dengan benar', () async {
    final incomeCats = await categoryDatasource.getCategories(type: 'income');
    final expenseCats = await categoryDatasource.getCategories(type: 'expense');

    expect(incomeCats.length, 4);
    expect(expenseCats.length, 8);
    expect(incomeCats.any((c) => c.name == 'Gaji'), isTrue);
    expect(expenseCats.any((c) => c.name == 'Makanan & Minuman'), isTrue);
  });

  test(
    'Menambah transaksi pemasukan dan pengeluaran berhasil tersimpan',
    () async {
      final incomeCats = await categoryDatasource.getCategories(type: 'income');
      final expenseCats = await categoryDatasource.getCategories(
        type: 'expense',
      );

      final gajiCatId = incomeCats.firstWhere((c) => c.name == 'Gaji').id!;
      final makanCatId = expenseCats
          .firstWhere((c) => c.name == 'Makanan & Minuman')
          .id!;

      final now = DateTime.now();

      // 1. Catat Pemasukan Gaji Rp5.000.000
      final tx1 = TransactionModel(
        type: 'income',
        amount: 5000000,
        categoryId: gajiCatId,
        note: 'Gaji Bulanan',
        occurredAt: now,
        createdAt: now,
        updatedAt: now,
      );
      final id1 = await transactionDatasource.insertTransaction(tx1);
      expect(id1, greaterThan(0));

      // 2. Catat Pengeluaran Makan Siang Rp50.000
      final tx2 = TransactionModel(
        type: 'expense',
        amount: 50000,
        categoryId: makanCatId,
        note: 'Makan Siang',
        occurredAt: now,
        createdAt: now,
        updatedAt: now,
      );
      final id2 = await transactionDatasource.insertTransaction(tx2);
      expect(id2, greaterThan(0));

      // Verifikasi daftar transaksi beserta kategori terkait (JOIN)
      final allTransactions = await transactionDatasource.getTransactions();
      expect(allTransactions.length, 2);

      final incomeTx = allTransactions.firstWhere((t) => t.id == id1);
      expect(incomeTx.type, 'income');
      expect(incomeTx.amount, 5000000);
      expect(incomeTx.category?.name, 'Gaji');

      final expenseTx = allTransactions.firstWhere((t) => t.id == id2);
      expect(expenseTx.type, 'expense');
      expect(expenseTx.amount, 50000);
      expect(expenseTx.category?.name, 'Makanan & Minuman');

      // Verifikasi kalkulasi agregat keuangan
      final totalIncome = await transactionDatasource.getTotalIncome();
      final totalExpense = await transactionDatasource.getTotalExpense();
      final balance = await transactionDatasource.getAvailableBalance();

      expect(totalIncome, 5000000);
      expect(totalExpense, 50000);
      expect(balance, 4950000);
    },
  );

  test('Filter transaksi berdasarkan jenis bekerja dengan tepat', () async {
    final incomeCats = await categoryDatasource.getCategories(type: 'income');
    final expenseCats = await categoryDatasource.getCategories(type: 'expense');

    final now = DateTime.now();

    await transactionDatasource.insertTransaction(
      TransactionModel(
        type: 'income',
        amount: 1000000,
        categoryId: incomeCats.first.id!,
        occurredAt: now,
        createdAt: now,
        updatedAt: now,
      ),
    );

    await transactionDatasource.insertTransaction(
      TransactionModel(
        type: 'expense',
        amount: 200000,
        categoryId: expenseCats.first.id!,
        occurredAt: now,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final onlyIncome = await transactionDatasource.getTransactions(
      type: 'income',
    );
    final onlyExpense = await transactionDatasource.getTransactions(
      type: 'expense',
    );

    expect(onlyIncome.length, 1);
    expect(onlyIncome.first.type, 'income');

    expect(onlyExpense.length, 1);
    expect(onlyExpense.first.type, 'expense');
  });

  test(
    'Memperbarui dan menghapus transaksi memperbarui saldo secara otomatis',
    () async {
      final incomeCats = await categoryDatasource.getCategories(type: 'income');
      final now = DateTime.now();

      final txId = await transactionDatasource.insertTransaction(
        TransactionModel(
          type: 'income',
          amount: 1000000,
          categoryId: incomeCats.first.id!,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      expect(await transactionDatasource.getAvailableBalance(), 1000000);

      // Update nominal transaksi dari 1.000.000 menjadi 1.500.000
      final existing = await transactionDatasource.getTransactionById(txId);
      expect(existing, isNotNull);

      await transactionDatasource.updateTransaction(
        existing!.copyWith(amount: 1500000),
      );

      expect(await transactionDatasource.getAvailableBalance(), 1500000);

      // Hapus transaksi -> Saldo kembali 0
      await transactionDatasource.deleteTransaction(txId);
      expect(await transactionDatasource.getAvailableBalance(), 0);

      final deleted = await transactionDatasource.getTransactionById(txId);
      expect(deleted, isNull);
    },
  );

  test(
    'Pencarian transaksi berdasarkan catatan dan nama kategori bekerja akurat',
    () async {
      final incomeCats = await categoryDatasource.getCategories(type: 'income');
      final expenseCats = await categoryDatasource.getCategories(
        type: 'expense',
      );

      final gajiCat = incomeCats.firstWhere((c) => c.name == 'Gaji');
      final makanCat = expenseCats.firstWhere(
        (c) => c.name == 'Makanan & Minuman',
      );
      final now = DateTime.now();

      await transactionDatasource.insertTransaction(
        TransactionModel(
          type: 'income',
          amount: 5000000,
          categoryId: gajiCat.id!,
          note: 'Bonus Kinerja Tahunan',
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await transactionDatasource.insertTransaction(
        TransactionModel(
          type: 'expense',
          amount: 45000,
          categoryId: makanCat.id!,
          note: 'Beli Kopi Kenangan',
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Cari berdasarkan kata pada catatan 'Kopi'
      final searchKopi = await transactionDatasource.getTransactions(
        searchQuery: 'Kopi',
      );
      expect(searchKopi.length, 1);
      expect(searchKopi.first.note, 'Beli Kopi Kenangan');

      // Cari berdasarkan nama kategori 'Makanan'
      final searchCat = await transactionDatasource.getTransactions(
        searchQuery: 'Makanan',
      );
      expect(searchCat.length, 1);
      expect(searchCat.first.category?.name, 'Makanan & Minuman');

      // Filter berdasarkan ID kategori Gaji
      final filterCat = await transactionDatasource.getTransactions(
        categoryId: gajiCat.id!,
      );
      expect(filterCat.length, 1);
      expect(filterCat.first.amount, 5000000);

      // Pencarian kata yang tidak ada mengembalikan list kosong
      final notFound = await transactionDatasource.getTransactions(
        searchQuery: 'Tiket Pesawat Liburan',
      );
      expect(notFound.isEmpty, isTrue);
    },
  );
}
