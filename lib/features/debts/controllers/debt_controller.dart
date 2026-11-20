import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/debt_model.dart';
import '../../../data/models/debt_payment_model.dart';
import '../../../data/repositories/debt_repository.dart';
import '../../transactions/controllers/transaction_controller.dart';

/// Provider instance tunggal [DebtRepository].
final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  return DebtRepository();
});

/// Model data ringkasan total utang dan piutang aktif.
class DebtsSummary {
  final int totalPayable;
  final int totalReceivable;

  const DebtsSummary({
    required this.totalPayable,
    required this.totalReceivable,
  });
}

/// Provider ringkasan total utang dan piutang yang belum lunas.
final debtsSummaryProvider = FutureProvider<DebtsSummary>((ref) async {
  final repository = ref.watch(debtRepositoryProvider);
  final payable = await repository.getTotalPayable();
  final receivable = await repository.getTotalReceivable();

  return DebtsSummary(totalPayable: payable, totalReceivable: receivable);
});

/// Notifier filter arah utang/piutang ('payable', 'receivable', atau null untuk semua).
class DebtDirectionFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setFilter(String? direction) {
    state = direction;
  }
}

/// Provider filter arah utang/piutang.
final debtDirectionFilterProvider =
    NotifierProvider<DebtDirectionFilterNotifier, String?>(() {
      return DebtDirectionFilterNotifier();
    });

/// Provider daftar utang & piutang berdasarkan filter yang dipilih.
final debtsListProvider = FutureProvider<List<DebtModel>>((ref) async {
  final repository = ref.watch(debtRepositoryProvider);
  final direction = ref.watch(debtDirectionFilterProvider);

  return await repository.getDebts(direction: direction, includeSettled: true);
});

/// Provider detail utang/piutang berdasarkan ID.
final debtDetailProvider = FutureProvider.family<DebtModel?, int>((
  ref,
  id,
) async {
  final repository = ref.watch(debtRepositoryProvider);
  return await repository.getDebtById(id);
});

/// Provider riwayat pembayaran utang/piutang berdasarkan ID.
final debtPaymentsProvider = FutureProvider.family<List<DebtPaymentModel>, int>(
  (ref, debtId) async {
    final repository = ref.watch(debtRepositoryProvider);
    return await repository.getPayments(debtId);
  },
);

/// Controller untuk aksi Create, Update, Delete, dan Pelunasan/Pembayaran Utang & Piutang.
class DebtActionController {
  final Ref _ref;

  DebtActionController(this._ref);

  DebtRepository get _repository => _ref.read(debtRepositoryProvider);

  /// Menambahkan utang atau piutang baru.
  Future<int> addDebt(DebtModel debt) async {
    final id = await _repository.addDebt(debt);
    _ref.invalidate(debtsListProvider);
    _ref.invalidate(debtsSummaryProvider);
    _ref.invalidate(dashboardSummaryProvider);
    return id;
  }

  /// Memperbarui catatan utang atau piutang.
  Future<void> updateDebt(DebtModel debt) async {
    await _repository.updateDebt(debt);
    if (debt.id != null) {
      _ref.invalidate(debtDetailProvider(debt.id!));
    }
    _ref.invalidate(debtsListProvider);
    _ref.invalidate(debtsSummaryProvider);
    _ref.invalidate(dashboardSummaryProvider);
  }

  /// Menghapus catatan utang atau piutang secara permanen.
  Future<void> deleteDebt(int id) async {
    await _repository.deleteDebt(id);
    _ref.invalidate(debtDetailProvider(id));
    _ref.invalidate(debtsListProvider);
    _ref.invalidate(debtsSummaryProvider);
    _ref.invalidate(dashboardSummaryProvider);
  }

  /// Menambahkan mutasi pembayaran cicilan atau pelunasan.
  Future<int> addPayment(DebtPaymentModel payment) async {
    final id = await _repository.addPayment(payment);
    _ref.invalidate(debtDetailProvider(payment.debtId));
    _ref.invalidate(debtPaymentsProvider(payment.debtId));
    _ref.invalidate(debtsListProvider);
    _ref.invalidate(debtsSummaryProvider);
    _ref.invalidate(dashboardSummaryProvider);
    return id;
  }
}

/// Provider instance [DebtActionController].
final debtActionControllerProvider = Provider<DebtActionController>((ref) {
  return DebtActionController(ref);
});
