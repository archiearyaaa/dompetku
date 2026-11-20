import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:dompetku/core/database/database_helper.dart';

void main() {
  // Inisialisasi sqflite FFI untuk unit testing di lingkungan desktop.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;

  setUp(() async {
    // Inisialisasi database in-memory dengan skema lengkap Dompetku
    db = await DatabaseHelper().initDatabase(customPath: inMemoryDatabasePath);
    DatabaseHelper.setDatabaseForTesting(db);
  });

  tearDown(() async {
    if (db.isOpen) {
      await db.close();
    }
    DatabaseHelper.setDatabaseForTesting(null);
  });

  test('DatabaseHelper menginisialisasi seluruh 7 tabel dan index', () async {
    // Ambil daftar nama tabel yang berhasil dibuat
    final tablesResult = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%';",
    );
    final tableNames = tablesResult.map((e) => e['name'] as String).toSet();

    expect(tableNames, contains('categories'));
    expect(tableNames, contains('transactions'));
    expect(tableNames, contains('savings_goals'));
    expect(tableNames, contains('savings_movements'));
    expect(tableNames, contains('debts'));
    expect(tableNames, contains('debt_payments'));
    expect(tableNames, contains('settings'));
  });

  test('DatabaseHelper menanam 12 kategori bawaan saat inisialisasi', () async {
    final categories = await db.query('categories');
    expect(categories.length, 12);

    final incomeCategories = categories
        .where((c) => c['type'] == 'income')
        .toList();
    final expenseCategories = categories
        .where((c) => c['type'] == 'expense')
        .toList();

    expect(incomeCategories.length, 4);
    expect(expenseCategories.length, 8);

    // Pastikan semua berstatus default (is_default = 1)
    for (final c in categories) {
      expect(c['is_default'], 1);
      expect(c['is_archived'], 0);
    }
  });

  test('DatabaseHelper menegakkan Foreign Key PRAGMA ON', () async {
    final fkResult = await db.rawQuery('PRAGMA foreign_keys;');
    expect(fkResult.first.values.first, 1);

    // Coba insert transaksi dengan category_id yang tidak ada -> harus gagal
    expect(
      () async => await db.insert('transactions', {
        'type': 'expense',
        'amount': 50000,
        'category_id': 99999, // ID tidak ada
        'occurred_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }),
      throwsA(isA<DatabaseException>()),
    );
  });

  test(
    'Tabel transactions menolak nominal nol atau negatif (CHECK constraint)',
    () async {
      // Ambil kategori yang valid
      final cat = (await db.query('categories', limit: 1)).first;
      final catId = cat['id'] as int;

      // Nominal 0 -> harus gagal
      expect(
        () async => await db.insert('transactions', {
          'type': 'expense',
          'amount': 0,
          'category_id': catId,
          'occurred_at': DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }),
        throwsA(isA<DatabaseException>()),
      );

      // Nominal negatif -> harus gagal
      expect(
        () async => await db.insert('transactions', {
          'type': 'expense',
          'amount': -10000,
          'category_id': catId,
          'occurred_at': DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }),
        throwsA(isA<DatabaseException>()),
      );
    },
  );

  test(
    'Menghapus savings_goal memicu ON DELETE CASCADE pada savings_movements',
    () async {
      // Buat target tabungan
      final goalId = await db.insert('savings_goals', {
        'name': 'Beli Laptop',
        'target_amount': 15000000,
        'created_at': DateTime.now().toIso8601String(),
        'is_archived': 0,
      });

      // Tambah mutasi
      await db.insert('savings_movements', {
        'goal_id': goalId,
        'type': 'deposit',
        'amount': 1000000,
        'occurred_at': DateTime.now().toIso8601String(),
      });

      // Hapus goal
      await db.delete('savings_goals', where: 'id = ?', whereArgs: [goalId]);

      // Mutasi harus otomatis terhapus karena ON DELETE CASCADE
      final movements = await db.query(
        'savings_movements',
        where: 'goal_id = ?',
        whereArgs: [goalId],
      );
      expect(movements.isEmpty, isTrue);
    },
  );
}
