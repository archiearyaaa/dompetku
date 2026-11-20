import 'package:sqflite/sqflite.dart';

import '../../core/database/database_helper.dart';
import '../models/category_expense_model.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

/// Datasource untuk operasi tabel `transactions` di SQLite.
class TransactionDatasource {
  final DatabaseHelper _dbHelper;

  TransactionDatasource({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();

  Future<Database> get _db async => await _dbHelper.database;

  /// Mengambil daftar transaksi dengan data kategori terkait (JOIN).
  Future<List<TransactionModel>> getTransactions({
    String? type,
    int? categoryId,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    final db = await _db;
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (type != null) {
      whereClauses.add('t.type = ?');
      whereArgs.add(type);
    }

    if (categoryId != null) {
      whereClauses.add('t.category_id = ?');
      whereArgs.add(categoryId);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClauses.add('(t.note LIKE ? OR c.name LIKE ?)');
      final term = '%${searchQuery.trim()}%';
      whereArgs.add(term);
      whereArgs.add(term);
    }

    if (startDate != null) {
      whereClauses.add('t.occurred_at >= ?');
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClauses.add('t.occurred_at <= ?');
      whereArgs.add(endDate.toIso8601String());
    }

    final whereString = whereClauses.isNotEmpty
        ? 'WHERE ${whereClauses.join(' AND ')}'
        : '';

    var query =
        '''
      SELECT 
        t.id, t.type, t.amount, t.category_id, t.note,
        t.occurred_at, t.created_at, t.updated_at,
        c.name AS cat_name, c.type AS cat_type, c.icon AS cat_icon,
        c.color AS cat_color, c.is_default AS cat_is_default,
        c.is_archived AS cat_is_archived, c.created_at AS cat_created_at
      FROM transactions t
      LEFT JOIN categories c ON t.category_id = c.id
      $whereString
      ORDER BY t.occurred_at DESC, t.id DESC
    ''';

    if (limit != null) {
      query += ' LIMIT $limit';
      if (offset != null) {
        query += ' OFFSET $offset';
      }
    }

    final results = await db.rawQuery(query, whereArgs);

    return results.map((map) {
      CategoryModel? category;
      if (map['cat_name'] != null) {
        category = CategoryModel(
          id: map['category_id'] as int,
          name: map['cat_name'] as String,
          type: map['cat_type'] as String,
          icon: map['cat_icon'] as String?,
          color: map['cat_color'] as String?,
          isDefault: (map['cat_is_default'] as int) == 1,
          isArchived: (map['cat_is_archived'] as int) == 1,
          createdAt: DateTime.parse(map['cat_created_at'] as String),
        );
      }

      return TransactionModel.fromMap(map, category: category);
    }).toList();
  }

  /// Mengambil transaksi tunggal berdasarkan [id].
  Future<TransactionModel?> getTransactionById(int id) async {
    final db = await _db;
    final results = await db.rawQuery(
      '''
      SELECT 
        t.id, t.type, t.amount, t.category_id, t.note,
        t.occurred_at, t.created_at, t.updated_at,
        c.name AS cat_name, c.type AS cat_type, c.icon AS cat_icon,
        c.color AS cat_color, c.is_default AS cat_is_default,
        c.is_archived AS cat_is_archived, c.created_at AS cat_created_at
      FROM transactions t
      LEFT JOIN categories c ON t.category_id = c.id
      WHERE t.id = ?
      LIMIT 1
    ''',
      [id],
    );

    if (results.isEmpty) return null;
    final map = results.first;

    CategoryModel? category;
    if (map['cat_name'] != null) {
      category = CategoryModel(
        id: map['category_id'] as int,
        name: map['cat_name'] as String,
        type: map['cat_type'] as String,
        icon: map['cat_icon'] as String?,
        color: map['cat_color'] as String?,
        isDefault: (map['cat_is_default'] as int) == 1,
        isArchived: (map['cat_is_archived'] as int) == 1,
        createdAt: DateTime.parse(map['cat_created_at'] as String),
      );
    }

    return TransactionModel.fromMap(map, category: category);
  }

  /// Menambahkan transaksi baru ke SQLite.
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await _db;
    return await db.insert('transactions', transaction.toMap());
  }

  /// Memperbarui transaksi yang ada.
  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await _db;
    if (transaction.id == null) {
      throw ArgumentError('Transaksi harus memiliki ID untuk diperbarui.');
    }

    final updatedData = transaction.toMap();
    updatedData['updated_at'] = DateTime.now().toIso8601String();

    return await db.update(
      'transactions',
      updatedData,
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  /// Menghapus transaksi berdasarkan [id].
  Future<int> deleteTransaction(int id) async {
    final db = await _db;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  /// Menghitung total pemasukan dalam rentang tanggal tertentu (atau semua).
  Future<int> getTotalIncome({DateTime? startDate, DateTime? endDate}) async {
    final db = await _db;
    final whereClauses = ["type = 'income'"];
    final whereArgs = <dynamic>[];

    if (startDate != null) {
      whereClauses.add('occurred_at >= ?');
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClauses.add('occurred_at <= ?');
      whereArgs.add(endDate.toIso8601String());
    }

    final whereString = whereClauses.join(' AND ');
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM transactions WHERE $whereString',
      whereArgs,
    );

    return result.first['total'] as int;
  }

  /// Menghitung total pengeluaran dalam rentang tanggal tertentu (atau semua).
  Future<int> getTotalExpense({DateTime? startDate, DateTime? endDate}) async {
    final db = await _db;
    final whereClauses = ["type = 'expense'"];
    final whereArgs = <dynamic>[];

    if (startDate != null) {
      whereClauses.add('occurred_at >= ?');
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClauses.add('occurred_at <= ?');
      whereArgs.add(endDate.toIso8601String());
    }

    final whereString = whereClauses.join(' AND ');
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM transactions WHERE $whereString',
      whereArgs,
    );

    return result.first['total'] as int;
  }

  /// Mengambil rincian pengeluaran yang dikelompokkan per kategori dalam rentang waktu.
  Future<List<CategoryExpenseModel>> getExpenseByCategory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _db;
    final whereClauses = ["t.type = 'expense'"];
    final whereArgs = <dynamic>[];

    if (startDate != null) {
      whereClauses.add('t.occurred_at >= ?');
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClauses.add('t.occurred_at <= ?');
      whereArgs.add(endDate.toIso8601String());
    }

    final whereString = whereClauses.join(' AND ');

    // 1. Ambil total pengeluaran pada rentang waktu ini untuk kalkulasi persentase
    final totalExpense = await getTotalExpense(
      startDate: startDate,
      endDate: endDate,
    );

    // 2. Query agregasi per kategori
    final query =
        '''
      SELECT 
        c.id AS category_id,
        c.name AS category_name,
        c.icon AS category_icon,
        c.color AS category_color,
        SUM(t.amount) AS total_amount,
        COUNT(t.id) AS transaction_count
      FROM transactions t
      JOIN categories c ON t.category_id = c.id
      WHERE $whereString
      GROUP BY c.id, c.name, c.icon, c.color
      ORDER BY total_amount DESC
    ''';

    final results = await db.rawQuery(query, whereArgs);

    return results.map((map) {
      return CategoryExpenseModel.fromMap(map, totalExpense: totalExpense);
    }).toList();
  }

  /// Menghitung Saldo Tersedia sesuai aturan bisnis PRD Section 8.
  ///
  /// Saldo Tersedia = Pemasukan Kas - Pengeluaran Kas
  ///                  - (Setoran Tabungan - Penarikan Tabungan)
  ///                  - (Pembayaran Utang) + (Penerimaan Utang - Piutang yang Diberikan) + (Pelunasan Piutang)
  Future<int> getAvailableBalance() async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT 
        (SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE type = 'income') -
        (SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE type = 'expense') -
        (
          (SELECT COALESCE(SUM(amount), 0) FROM savings_movements WHERE type = 'deposit') -
          (SELECT COALESCE(SUM(amount), 0) FROM savings_movements WHERE type = 'withdrawal')
        ) -
        (SELECT COALESCE(SUM(amount), 0) FROM debt_payments dp 
           JOIN debts d ON dp.debt_id = d.id WHERE d.direction = 'payable') +
        (SELECT COALESCE(SUM(amount), 0) FROM debt_payments dp 
           JOIN debts d ON dp.debt_id = d.id WHERE d.direction = 'receivable')
        AS balance
    ''');

    return result.first['balance'] as int;
  }
}
