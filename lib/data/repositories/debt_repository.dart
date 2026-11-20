import '../datasources/debt_datasource.dart';
import '../models/debt_model.dart';
import '../models/debt_payment_model.dart';

/// Repository untuk mengelola utang dan piutang.
class DebtRepository {
  final DebtDatasource _datasource;

  DebtRepository({DebtDatasource? datasource})
    : _datasource = datasource ?? DebtDatasource();

  /// Mengambil daftar utang / piutang.
  Future<List<DebtModel>> getDebts({
    String? direction,
    bool includeSettled = true,
  }) async {
    return await _datasource.getDebts(
      direction: direction,
      includeSettled: includeSettled,
    );
  }

  /// Mengambil detail utang / piutang berdasarkan ID.
  Future<DebtModel?> getDebtById(int id) async {
    return await _datasource.getDebtById(id);
  }

  /// Menambahkan catatan utang atau piutang baru.
  Future<int> addDebt(DebtModel debt) async {
    return await _datasource.insertDebt(debt);
  }

  /// Memperbarui catatan utang atau piutang.
  Future<int> updateDebt(DebtModel debt) async {
    return await _datasource.updateDebt(debt);
  }

  /// Menghapus catatan utang atau piutang.
  Future<int> deleteDebt(int id) async {
    return await _datasource.deleteDebt(id);
  }

  /// Mengambil riwayat cicilan/pembayaran utang atau piutang.
  Future<List<DebtPaymentModel>> getPayments(int debtId) async {
    return await _datasource.getPayments(debtId);
  }

  /// Menambahkan pembayaran atau pelunasan.
  Future<int> addPayment(DebtPaymentModel payment) async {
    return await _datasource.insertPayment(payment);
  }

  /// Mengambil total sisa utang yang belum lunas (direction: 'payable').
  Future<int> getTotalPayable() async {
    return await _datasource.getTotalRemaining(direction: 'payable');
  }

  /// Mengambil total sisa piutang yang belum diterima (direction: 'receivable').
  Future<int> getTotalReceivable() async {
    return await _datasource.getTotalRemaining(direction: 'receivable');
  }
}
