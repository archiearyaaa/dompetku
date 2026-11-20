import 'package:sqflite/sqflite.dart';

import '../../core/database/database_helper.dart';
import '../models/savings_goal_model.dart';
import '../models/savings_movement_model.dart';

/// Datasource untuk operasi tabel `savings_goals` dan `savings_movements` di SQLite.
class SavingsDatasource {
  final DatabaseHelper _dbHelper;

  SavingsDatasource({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();

  Future<Database> get _db async => await _dbHelper.database;

  /// Mengambil semua target tabungan beserta saldo terkumpul aktual (`current_amount`).
  Future<List<SavingsGoalModel>> getSavingsGoals({
    bool includeArchived = false,
  }) async {
    final db = await _db;
    final whereString = includeArchived ? null : 'g.is_archived = 0';

    final query =
        '''
      SELECT 
        g.id, g.name, g.target_amount, g.target_date, g.created_at, g.is_archived,
        COALESCE(
          (SELECT SUM(CASE WHEN sm.type = 'deposit' THEN sm.amount ELSE -sm.amount END)
           FROM savings_movements sm WHERE sm.goal_id = g.id), 0
        ) AS current_amount
      FROM savings_goals g
      ${whereString != null ? 'WHERE $whereString' : ''}
      ORDER BY g.is_archived ASC, g.created_at DESC
    ''';

    final results = await db.rawQuery(query);

    return results.map((map) {
      final current = (map['current_amount'] as num?)?.toInt() ?? 0;
      return SavingsGoalModel.fromMap(map, currentAmount: current);
    }).toList();
  }

  /// Mengambil target tabungan tunggal berdasarkan [id].
  Future<SavingsGoalModel?> getSavingsGoalById(int id) async {
    final db = await _db;
    final results = await db.rawQuery(
      '''
      SELECT 
        g.id, g.name, g.target_amount, g.target_date, g.created_at, g.is_archived,
        COALESCE(
          (SELECT SUM(CASE WHEN sm.type = 'deposit' THEN sm.amount ELSE -sm.amount END)
           FROM savings_movements sm WHERE sm.goal_id = g.id), 0
        ) AS current_amount
      FROM savings_goals g
      WHERE g.id = ?
      LIMIT 1
    ''',
      [id],
    );

    if (results.isEmpty) return null;
    final map = results.first;
    final current = (map['current_amount'] as num?)?.toInt() ?? 0;
    return SavingsGoalModel.fromMap(map, currentAmount: current);
  }

  /// Menambahkan target tabungan baru.
  Future<int> insertSavingsGoal(SavingsGoalModel goal) async {
    final db = await _db;
    return await db.insert('savings_goals', goal.toMap());
  }

  /// Memperbarui target tabungan yang ada.
  Future<int> updateSavingsGoal(SavingsGoalModel goal) async {
    final db = await _db;
    if (goal.id == null) {
      throw ArgumentError(
        'Target tabungan harus memiliki ID untuk diperbarui.',
      );
    }

    return await db.update(
      'savings_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  /// Mengarsipkan target tabungan.
  Future<int> archiveSavingsGoal(int id) async {
    final db = await _db;
    return await db.update(
      'savings_goals',
      {'is_archived': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Menghapus target tabungan secara permanen.
  /// Mutasi terkait otomatis terhapus karena foreign key CASCADE.
  Future<int> deleteSavingsGoal(int id) async {
    final db = await _db;
    return await db.delete('savings_goals', where: 'id = ?', whereArgs: [id]);
  }

  /// Mengambil seluruh riwayat mutasi pada suatu target tabungan.
  Future<List<SavingsMovementModel>> getMovements(int goalId) async {
    final db = await _db;
    final results = await db.query(
      'savings_movements',
      where: 'goal_id = ?',
      whereArgs: [goalId],
      orderBy: 'occurred_at DESC, id DESC',
    );

    return results.map((map) => SavingsMovementModel.fromMap(map)).toList();
  }

  /// Menambahkan mutasi tabungan (setoran atau penarikan).
  ///
  /// Dilakukan di dalam transaksi SQLite atomik dan memvalidasi
  /// bahwa penarikan tidak melebihi saldo tabungan saat ini.
  Future<int> insertMovement(SavingsMovementModel movement) async {
    final db = await _db;

    return await db.transaction<int>((txn) async {
      // Jika penarikan, cek apakah saldo mencukupi
      if (movement.isWithdrawal) {
        final balanceResult = await txn.rawQuery(
          '''
          SELECT COALESCE(
            SUM(CASE WHEN type = 'deposit' THEN amount ELSE -amount END), 0
          ) AS balance
          FROM savings_movements
          WHERE goal_id = ?
        ''',
          [movement.goalId],
        );

        final currentBalance =
            (balanceResult.first['balance'] as num?)?.toInt() ?? 0;
        if (movement.amount > currentBalance) {
          throw ArgumentError(
            'Saldo tabungan tidak mencukupi untuk melakukan penarikan.',
          );
        }
      }

      return await txn.insert('savings_movements', movement.toMap());
    });
  }

  /// Menghitung total seluruh tabungan aktif (total setoran - total penarikan).
  Future<int> getTotalSavings() async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT COALESCE(
        SUM(CASE WHEN sm.type = 'deposit' THEN sm.amount ELSE -sm.amount END), 0
      ) AS total_savings
      FROM savings_movements sm
      JOIN savings_goals g ON sm.goal_id = g.id
      WHERE g.is_archived = 0
    ''');

    return (result.first['total_savings'] as num?)?.toInt() ?? 0;
  }
}
