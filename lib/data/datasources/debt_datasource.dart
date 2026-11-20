import 'package:sqflite/sqflite.dart';

import '../../core/database/database_helper.dart';
import '../models/debt_model.dart';
import '../models/debt_payment_model.dart';

/// Datasource untuk operasi tabel `debts` dan `debt_payments` di SQLite.
class DebtDatasource {
  final DatabaseHelper _dbHelper;

  DebtDatasource({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();

  Future<Database> get _db async => await _dbHelper.database;

  /// Mengambil daftar utang / piutang beserta akumulasi pembayaran (`paid_amount`).
  ///
  /// [direction]: 'payable', 'receivable', atau null (semua).
  /// [includeSettled]: apakah menyertakan yang sudah lunas.
  Future<List<DebtModel>> getDebts({
    String? direction,
    bool includeSettled = true,
  }) async {
    final db = await _db;
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (direction != null) {
      whereClauses.add('d.direction = ?');
      whereArgs.add(direction);
    }

    if (!includeSettled) {
      whereClauses.add("d.status != 'settled'");
    }

    final whereString = whereClauses.isNotEmpty
        ? 'WHERE ${whereClauses.join(' AND ')}'
        : '';

    final query =
        '''
      SELECT 
        d.id, d.direction, d.person_name, d.principal_amount, 
        d.due_date, d.note, d.created_at, d.status,
        COALESCE((SELECT SUM(amount) FROM debt_payments WHERE debt_id = d.id), 0) AS paid_amount
      FROM debts d
      $whereString
      ORDER BY 
        CASE WHEN d.status = 'settled' THEN 1 ELSE 0 END ASC,
        d.created_at DESC
    ''';

    final results = await db.rawQuery(query, whereArgs);

    return results.map((map) {
      final paid = (map['paid_amount'] as num?)?.toInt() ?? 0;
      return DebtModel.fromMap(map, paidAmount: paid);
    }).toList();
  }

  /// Mengambil detail utang / piutang berdasarkan [id].
  Future<DebtModel?> getDebtById(int id) async {
    final db = await _db;
    final query = '''
      SELECT 
        d.id, d.direction, d.person_name, d.principal_amount, 
        d.due_date, d.note, d.created_at, d.status,
        COALESCE((SELECT SUM(amount) FROM debt_payments WHERE debt_id = d.id), 0) AS paid_amount
      FROM debts d
      WHERE d.id = ?
      LIMIT 1
    ''';

    final results = await db.rawQuery(query, [id]);
    if (results.isEmpty) return null;

    final map = results.first;
    final paid = (map['paid_amount'] as num?)?.toInt() ?? 0;
    return DebtModel.fromMap(map, paidAmount: paid);
  }

  /// Menambahkan pencatatan utang atau piutang baru.
  Future<int> insertDebt(DebtModel debt) async {
    final db = await _db;
    return await db.insert('debts', debt.toMap());
  }

  /// Memperbarui data utang atau piutang yang ada.
  Future<int> updateDebt(DebtModel debt) async {
    final db = await _db;
    if (debt.id == null) {
      throw ArgumentError('Utang/piutang harus memiliki ID untuk diperbarui.');
    }

    return await db.update(
      'debts',
      debt.toMap(),
      where: 'id = ?',
      whereArgs: [debt.id],
    );
  }

  /// Menghapus catatan utang atau piutang secara permanen.
  /// Riwayat pembayaran terkait otomatis terhapus (ON DELETE CASCADE).
  Future<int> deleteDebt(int id) async {
    final db = await _db;
    return await db.delete('debts', where: 'id = ?', whereArgs: [id]);
  }

  /// Mengambil daftar riwayat cicilan/pembayaran untuk utang/piutang tertentu.
  Future<List<DebtPaymentModel>> getPayments(int debtId) async {
    final db = await _db;
    final results = await db.query(
      'debt_payments',
      where: 'debt_id = ?',
      whereArgs: [debtId],
      orderBy: 'occurred_at DESC, id DESC',
    );

    return results.map((map) => DebtPaymentModel.fromMap(map)).toList();
  }

  /// Menambahkan pembayaran cicilan atau pelunasan utang/piutang.
  ///
  /// Dilakukan secara atomik dalam transaksi SQLite:
  /// - Menghitung sisa nominal yang belum terbayar.
  /// - Menolak jika nominal pembayaran melebihi sisa kewajiban.
  /// - Jika pembayaran mencukupi sisa, otomatis memperbarui status menjadi 'settled'.
  Future<int> insertPayment(DebtPaymentModel payment) async {
    final db = await _db;

    return await db.transaction<int>((txn) async {
      // 1. Ambil info pokok dan total pembayaran yang sudah ada
      final debtResults = await txn.rawQuery(
        '''
        SELECT 
          d.principal_amount,
          COALESCE((SELECT SUM(amount) FROM debt_payments WHERE debt_id = d.id), 0) AS total_paid
        FROM debts d
        WHERE d.id = ?
      ''',
        [payment.debtId],
      );

      if (debtResults.isEmpty) {
        throw ArgumentError('Catatan utang/piutang tidak ditemukan.');
      }

      final principal = debtResults.first['principal_amount'] as int;
      final currentPaid =
          (debtResults.first['total_paid'] as num?)?.toInt() ?? 0;
      final remaining = principal - currentPaid;

      // 2. Validasi nominal pembayaran tidak boleh melebihi sisa tagihan
      if (payment.amount > remaining) {
        throw ArgumentError(
          'Nominal pembayaran ($payment.amount) melebihi sisa tagihan ($remaining).',
        );
      }

      // 3. Simpan mutasi pembayaran
      final paymentId = await txn.insert('debt_payments', payment.toMap());

      // 4. Jika pembayaran ini melunasi seluruh sisa, ubah status menjadi 'settled'
      if (payment.amount == remaining) {
        await txn.update(
          'debts',
          {'status': 'settled'},
          where: 'id = ?',
          whereArgs: [payment.debtId],
        );
      }

      return paymentId;
    });
  }

  /// Menghitung total sisa utang atau piutang yang belum dilunasi.
  ///
  /// [direction]: 'payable' (Utang) atau 'receivable' (Piutang).
  Future<int> getTotalRemaining({required String direction}) async {
    final db = await _db;
    final result = await db.rawQuery(
      '''
      SELECT COALESCE(
        SUM(
          d.principal_amount - 
          COALESCE((SELECT SUM(dp.amount) FROM debt_payments dp WHERE dp.debt_id = d.id), 0)
        ), 0
      ) AS total_remaining
      FROM debts d
      WHERE d.direction = ? AND d.status != 'settled'
    ''',
      [direction],
    );

    return (result.first['total_remaining'] as num?)?.toInt() ?? 0;
  }
}
