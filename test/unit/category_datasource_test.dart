import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:dompetku/core/database/database_helper.dart';
import 'package:dompetku/data/datasources/category_datasource.dart';
import 'package:dompetku/data/datasources/transaction_datasource.dart';
import 'package:dompetku/data/models/category_model.dart';
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

  test('Tambah kategori kustom baru berhasil tersimpan dan diambil', () async {
    final now = DateTime.now();
    final customCat = CategoryModel(
      name: 'Hobi & Game',
      type: 'expense',
      icon: 'sports_esports',
      color: '#7B1FA2',
      isDefault: false,
      isArchived: false,
      createdAt: now,
    );

    final newId = await categoryDatasource.insertCategory(customCat);
    expect(newId, greaterThan(0));

    final fetched = await categoryDatasource.getCategoryById(newId);
    expect(fetched, isNotNull);
    expect(fetched!.name, 'Hobi & Game');
    expect(fetched.type, 'expense');
    expect(fetched.icon, 'sports_esports');
    expect(fetched.color, '#7B1FA2');
    expect(fetched.isDefault, isFalse);
    expect(fetched.isArchived, isFalse);
  });

  test('Perbarui data kategori berhasil mengubah atribut kategori', () async {
    final now = DateTime.now();
    final newId = await categoryDatasource.insertCategory(
      CategoryModel(
        name: 'Investasi Saham',
        type: 'income',
        icon: 'trending_up',
        color: '#2E7D32',
        createdAt: now,
      ),
    );

    final original = await categoryDatasource.getCategoryById(newId);
    expect(original, isNotNull);

    await categoryDatasource.updateCategory(
      original!.copyWith(name: 'Investasi & Dividen', color: '#00897B'),
    );

    final updated = await categoryDatasource.getCategoryById(newId);
    expect(updated!.name, 'Investasi & Dividen');
    expect(updated.color, '#00897B');
  });

  test('Arsipkan dan batalkan arsip kategori bekerja dengan benar', () async {
    final now = DateTime.now();
    final newId = await categoryDatasource.insertCategory(
      CategoryModel(name: 'Kategori Uji', type: 'expense', createdAt: now),
    );

    // Kategori belum diarsipkan
    var activeList = await categoryDatasource.getCategories(type: 'expense');
    expect(activeList.any((c) => c.id == newId), isTrue);

    // Arsipkan
    await categoryDatasource.archiveCategory(newId);
    activeList = await categoryDatasource.getCategories(type: 'expense');
    expect(activeList.any((c) => c.id == newId), isFalse);

    // Dengan includeArchived: true, tetap muncul
    final allList = await categoryDatasource.getCategories(
      type: 'expense',
      includeArchived: true,
    );
    expect(allList.any((c) => c.id == newId), isTrue);
    expect(allList.firstWhere((c) => c.id == newId).isArchived, isTrue);

    // Buka arsip (unarchive)
    await categoryDatasource.unarchiveCategory(newId);
    activeList = await categoryDatasource.getCategories(type: 'expense');
    expect(activeList.any((c) => c.id == newId), isTrue);
  });

  test(
    'isCategoryInUse dan deleteCategory menjaga integritas data transaksi',
    () async {
      final now = DateTime.now();
      final newCatId = await categoryDatasource.insertCategory(
        CategoryModel(name: 'Kategori Langka', type: 'expense', createdAt: now),
      );

      // 1. Kategori baru belum dipakai transaksi
      expect(await categoryDatasource.isCategoryInUse(newCatId), isFalse);

      // Bisa dihapus permanen
      final deletedCount = await categoryDatasource.deleteCategory(newCatId);
      expect(deletedCount, 1);
      expect(await categoryDatasource.getCategoryById(newCatId), isNull);

      // 2. Buat kategori lagi dan kaitkan dengan transaksi
      final usedCatId = await categoryDatasource.insertCategory(
        CategoryModel(
          name: 'Kategori Terpakai',
          type: 'expense',
          createdAt: now,
        ),
      );

      await transactionDatasource.insertTransaction(
        TransactionModel(
          type: 'expense',
          amount: 25000,
          categoryId: usedCatId,
          note: 'Beli ATK',
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Kategori terdeteksi in-use
      expect(await categoryDatasource.isCategoryInUse(usedCatId), isTrue);

      // Menghapus kategori yang sedang dipakai harus melempar StateError
      expect(
        () => categoryDatasource.deleteCategory(usedCatId),
        throwsStateError,
      );
    },
  );
}
