import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:dompetku/core/database/database_helper.dart';
import 'package:dompetku/core/utils/date_formatter.dart';
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

  test(
    'DateFormatter startOfWeek dan endOfWeek bekerja sesuai standar Senin-Minggu',
    () {
      // 20 November 2026 adalah hari Jumat (weekday 5)
      final friday = DateTime(2026, 11, 20, 14, 30);
      final monday = DateFormatter.startOfWeek(friday);
      final sunday = DateFormatter.endOfWeek(friday);

      expect(monday.year, 2026);
      expect(monday.month, 11);
      expect(monday.day, 16); // Senin 16 Nov
      expect(monday.hour, 0);
      expect(monday.minute, 0);

      expect(sunday.year, 2026);
      expect(sunday.month, 11);
      expect(sunday.day, 22); // Minggu 22 Nov
      expect(sunday.hour, 23);
      expect(sunday.minute, 59);
    },
  );

  test(
    'getExpenseByCategory mengagregasi dan mengurutkan pengeluaran per kategori dengan benar',
    () async {
      final expenseCategories = await categoryDatasource.getCategories(
        type: 'expense',
      );
      final incomeCategories = await categoryDatasource.getCategories(
        type: 'income',
      );

      final makananCat = expenseCategories.firstWhere(
        (c) => c.name == 'Makanan & Minuman',
      );
      final belanjaCat = expenseCategories.firstWhere(
        (c) => c.name == 'Belanja',
      );
      final transportasiCat = expenseCategories.firstWhere(
        (c) => c.name == 'Transportasi',
      );
      final gajiCat = incomeCategories.firstWhere((c) => c.name == 'Gaji');

      final now = DateTime(2026, 11, 15, 12, 0);

      // Pemasukan: Rp 5.000.000 (tidak boleh masuk ke pengeluaran kategori)
      await transactionDatasource.insertTransaction(
        TransactionModel(
          type: 'income',
          amount: 5000000,
          categoryId: gajiCat.id!,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Pengeluaran Belanja: Rp 300.000 (1 transaksi)
      await transactionDatasource.insertTransaction(
        TransactionModel(
          type: 'expense',
          amount: 3000000,
          categoryId: belanjaCat.id!,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Pengeluaran Makanan 1: Rp 1.500.000
      await transactionDatasource.insertTransaction(
        TransactionModel(
          type: 'expense',
          amount: 1500000,
          categoryId: makananCat.id!,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Pengeluaran Makanan 2: Rp 500.000 (Total Makanan: Rp 2.000.000, 2 transaksi)
      await transactionDatasource.insertTransaction(
        TransactionModel(
          type: 'expense',
          amount: 500000,
          categoryId: makananCat.id!,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Pengeluaran Transportasi: Rp 1.000.000 (1 transaksi)
      await transactionDatasource.insertTransaction(
        TransactionModel(
          type: 'expense',
          amount: 1000000,
          categoryId: transportasiCat.id!,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Total pengeluaran: 3.000.000 + 2.000.000 + 1.000.000 = 6.000.000
      final report = await transactionDatasource.getExpenseByCategory();

      expect(report.length, 3);

      // Urutan 1: Belanja (Rp 3.000.000, 50%, 1 transaksi)
      expect(report[0].categoryName, 'Belanja');
      expect(report[0].totalAmount, 3000000);
      expect(report[0].transactionCount, 1);
      expect(report[0].percentage, closeTo(0.5, 0.001));

      // Urutan 2: Makanan & Minuman (Rp 2.000.000, ~33.3%, 2 transaksi)
      expect(report[1].categoryName, 'Makanan & Minuman');
      expect(report[1].totalAmount, 2000000);
      expect(report[1].transactionCount, 2);
      expect(report[1].percentage, closeTo(0.333, 0.01));

      // Urutan 3: Transportasi (Rp 1.000.000, ~16.7%, 1 transaksi)
      expect(report[2].categoryName, 'Transportasi');
      expect(report[2].totalAmount, 1000000);
      expect(report[2].transactionCount, 1);
      expect(report[2].percentage, closeTo(0.167, 0.01));
    },
  );

  test(
    'getExpenseByCategory memfilter berdasarkan rentang tanggal dengan benar',
    () async {
      final expenseCategories = await categoryDatasource.getCategories(
        type: 'expense',
      );
      final makananCat = expenseCategories.firstWhere(
        (c) => c.name == 'Makanan & Minuman',
      );

      // Transaksi di bulan Oktober
      await transactionDatasource.insertTransaction(
        TransactionModel(
          type: 'expense',
          amount: 200000,
          categoryId: makananCat.id!,
          occurredAt: DateTime(2026, 10, 15),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // Transaksi di bulan November
      await transactionDatasource.insertTransaction(
        TransactionModel(
          type: 'expense',
          amount: 350000,
          categoryId: makananCat.id!,
          occurredAt: DateTime(2026, 11, 10),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final novReport = await transactionDatasource.getExpenseByCategory(
        startDate: DateTime(2026, 11, 1),
        endDate: DateTime(2026, 11, 30, 23, 59, 59),
      );

      expect(novReport.length, 1);
      expect(novReport.first.totalAmount, 350000);
    },
  );
}
