import 'package:sqflite/sqflite.dart';

import '../../core/database/database_helper.dart';
import '../models/category_model.dart';

/// Datasource untuk operasi tabel `categories` di SQLite.
class CategoryDatasource {
  final DatabaseHelper _dbHelper;

  CategoryDatasource({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();

  Future<Database> get _db async => await _dbHelper.database;

  /// Mengambil daftar kategori berdasarkan jenis ('income' | 'expense')
  /// atau semua jika [type] bernilai `null`.
  Future<List<CategoryModel>> getCategories({
    String? type,
    bool includeArchived = false,
  }) async {
    final db = await _db;
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (type != null) {
      whereClauses.add('type = ?');
      whereArgs.add(type);
    }

    if (!includeArchived) {
      whereClauses.add('is_archived = 0');
    }

    final whereString = whereClauses.isNotEmpty
        ? whereClauses.join(' AND ')
        : null;

    final results = await db.query(
      'categories',
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'is_default DESC, name ASC',
    );

    return results.map((map) => CategoryModel.fromMap(map)).toList();
  }

  /// Mengambil kategori tunggal berdasarkan [id].
  Future<CategoryModel?> getCategoryById(int id) async {
    final db = await _db;
    final results = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return CategoryModel.fromMap(results.first);
  }

  /// Menambahkan kategori baru buatan pengguna.
  Future<int> insertCategory(CategoryModel category) async {
    final db = await _db;
    return await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Memperbarui kategori yang ada.
  Future<int> updateCategory(CategoryModel category) async {
    final db = await _db;
    if (category.id == null) {
      throw ArgumentError('Kategori harus memiliki ID untuk diperbarui.');
    }

    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Mengarsipkan kategori agar tidak dapat dipilih lagi,
  /// tetapi riwayat transaksi tetap terjaga.
  Future<int> archiveCategory(int id) async {
    final db = await _db;
    return await db.update(
      'categories',
      {'is_archived': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Membatalkan pengarsipan kategori sehingga aktif kembali.
  Future<int> unarchiveCategory(int id) async {
    final db = await _db;
    return await db.update(
      'categories',
      {'is_archived': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Memeriksa apakah kategori sedang digunakan oleh satu atau lebih transaksi.
  Future<bool> isCategoryInUse(int id) async {
    final db = await _db;
    final results = await db.rawQuery(
      'SELECT COUNT(*) as count FROM transactions WHERE category_id = ?',
      [id],
    );
    final count = Sqflite.firstIntValue(results) ?? 0;
    return count > 0;
  }

  /// Menghapus kategori permanen (hanya diizinkan jika belum digunakan dalam transaksi).
  Future<int> deleteCategory(int id) async {
    final db = await _db;
    final inUse = await isCategoryInUse(id);
    if (inUse) {
      throw StateError(
        'Kategori sedang digunakan dalam transaksi dan tidak dapat dihapus permanen. Gunakan fitur arsip.',
      );
    }

    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
