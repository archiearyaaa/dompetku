import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/savings_goal_model.dart';
import '../../../data/models/savings_movement_model.dart';
import '../../../data/repositories/savings_repository.dart';
import '../../transactions/controllers/transaction_controller.dart';

/// Provider instance tunggal [SavingsRepository].
final savingsRepositoryProvider = Provider<SavingsRepository>((ref) {
  return SavingsRepository();
});

/// Provider daftar target tabungan aktif.
final savingsGoalsProvider = FutureProvider<List<SavingsGoalModel>>((
  ref,
) async {
  final repository = ref.watch(savingsRepositoryProvider);
  return await repository.getSavingsGoals(includeArchived: false);
});

/// Provider detail target tabungan tunggal berdasarkan ID.
final savingsGoalDetailProvider = FutureProvider.family<SavingsGoalModel?, int>(
  (ref, id) async {
    final repository = ref.watch(savingsRepositoryProvider);
    return await repository.getSavingsGoalById(id);
  },
);

/// Provider daftar mutasi tabungan berdasarkan target ID.
final savingsMovementsProvider =
    FutureProvider.family<List<SavingsMovementModel>, int>((ref, goalId) async {
      final repository = ref.watch(savingsRepositoryProvider);
      return await repository.getMovements(goalId);
    });

/// Provider total akumulasi uang di tabungan.
final totalSavingsProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(savingsRepositoryProvider);
  return await repository.getTotalSavings();
});

/// Controller untuk operasi manajemen target tabungan dan mutasi.
class SavingsActionController {
  final Ref _ref;

  SavingsActionController(this._ref);

  SavingsRepository get _repository => _ref.read(savingsRepositoryProvider);

  /// Menambahkan target tabungan baru.
  Future<int> addGoal(SavingsGoalModel goal) async {
    final id = await _repository.addSavingsGoal(goal);
    _ref.invalidate(savingsGoalsProvider);
    _ref.invalidate(totalSavingsProvider);
    return id;
  }

  /// Memperbarui data target tabungan.
  Future<void> updateGoal(SavingsGoalModel goal) async {
    await _repository.updateSavingsGoal(goal);
    if (goal.id != null) {
      _ref.invalidate(savingsGoalDetailProvider(goal.id!));
    }
    _ref.invalidate(savingsGoalsProvider);
    _ref.invalidate(totalSavingsProvider);
  }

  /// Mengarsipkan target tabungan.
  Future<void> archiveGoal(int id) async {
    await _repository.archiveSavingsGoal(id);
    _ref.invalidate(savingsGoalDetailProvider(id));
    _ref.invalidate(savingsGoalsProvider);
    _ref.invalidate(totalSavingsProvider);
  }

  /// Menghapus target tabungan secara permanen beserta riwayat mutasinya.
  Future<void> deleteGoal(int id) async {
    await _repository.deleteSavingsGoal(id);
    _ref.invalidate(savingsGoalDetailProvider(id));
    _ref.invalidate(savingsGoalsProvider);
    _ref.invalidate(totalSavingsProvider);
    _ref.invalidate(dashboardSummaryProvider);
  }

  /// Menambahkan mutasi tabungan (setor atau tarik).
  Future<int> addMovement(SavingsMovementModel movement) async {
    final id = await _repository.addMovement(movement);
    _ref.invalidate(savingsGoalDetailProvider(movement.goalId));
    _ref.invalidate(savingsMovementsProvider(movement.goalId));
    _ref.invalidate(savingsGoalsProvider);
    _ref.invalidate(totalSavingsProvider);
    _ref.invalidate(dashboardSummaryProvider);
    return id;
  }
}

/// Provider instance [SavingsActionController].
final savingsActionControllerProvider = Provider<SavingsActionController>((
  ref,
) {
  return SavingsActionController(ref);
});
