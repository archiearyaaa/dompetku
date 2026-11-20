import '../datasources/savings_datasource.dart';
import '../models/savings_goal_model.dart';
import '../models/savings_movement_model.dart';

/// Repository untuk mengelola target tabungan dan mutasi tabungan.
class SavingsRepository {
  final SavingsDatasource _datasource;

  SavingsRepository({SavingsDatasource? datasource})
    : _datasource = datasource ?? SavingsDatasource();

  /// Mengambil daftar target tabungan.
  Future<List<SavingsGoalModel>> getSavingsGoals({
    bool includeArchived = false,
  }) async {
    return await _datasource.getSavingsGoals(includeArchived: includeArchived);
  }

  /// Mengambil detail target tabungan berdasarkan ID.
  Future<SavingsGoalModel?> getSavingsGoalById(int id) async {
    return await _datasource.getSavingsGoalById(id);
  }

  /// Menambahkan target tabungan baru.
  Future<int> addSavingsGoal(SavingsGoalModel goal) async {
    return await _datasource.insertSavingsGoal(goal);
  }

  /// Memperbarui target tabungan.
  Future<int> updateSavingsGoal(SavingsGoalModel goal) async {
    return await _datasource.updateSavingsGoal(goal);
  }

  /// Mengarsipkan target tabungan.
  Future<int> archiveSavingsGoal(int id) async {
    return await _datasource.archiveSavingsGoal(id);
  }

  /// Menghapus target tabungan.
  Future<int> deleteSavingsGoal(int id) async {
    return await _datasource.deleteSavingsGoal(id);
  }

  /// Mengambil riwayat mutasi untuk target tertentu.
  Future<List<SavingsMovementModel>> getMovements(int goalId) async {
    return await _datasource.getMovements(goalId);
  }

  /// Menambahkan mutasi (setoran atau penarikan).
  Future<int> addMovement(SavingsMovementModel movement) async {
    return await _datasource.insertMovement(movement);
  }

  /// Mengambil total akumulasi tabungan saat ini.
  Future<int> getTotalSavings() async {
    return await _datasource.getTotalSavings();
  }
}
