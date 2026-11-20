import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/transaction_repository.dart';

/// Provider instance tunggal [CategoryRepository].
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

/// Provider instance tunggal [TransactionRepository].
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

/// Provider daftar kategori berdasarkan jenis ('income' | 'expense' | null).
final categoriesProvider = FutureProvider.family<List<CategoryModel>, String?>((
  ref,
  type,
) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.getCategories(type: type);
});

/// Notifier untuk filter jenis transaksi aktif ('income', 'expense', atau null untuk semua).
class TransactionTypeFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setFilter(String? filter) {
    state = filter;
  }
}

/// Provider untuk state filter jenis transaksi aktif.
final transactionTypeFilterProvider =
    NotifierProvider<TransactionTypeFilterNotifier, String?>(() {
      return TransactionTypeFilterNotifier();
    });

/// Notifier untuk filter kategori transaksi aktif (ID kategori atau null untuk semua).
class TransactionCategoryFilterNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void setCategory(int? categoryId) {
    state = categoryId;
  }
}

/// Provider untuk state filter kategori transaksi aktif.
final transactionCategoryFilterProvider =
    NotifierProvider<TransactionCategoryFilterNotifier, int?>(() {
      return TransactionCategoryFilterNotifier();
    });

/// Notifier untuk kata kunci pencarian transaksi (catatan atau nama kategori).
class TransactionSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

/// Provider untuk kata kunci pencarian transaksi.
final transactionSearchQueryProvider =
    NotifierProvider<TransactionSearchQueryNotifier, String>(() {
      return TransactionSearchQueryNotifier();
    });

/// Provider daftar transaksi yang terfilter jenis, kategori, dan kata kunci pencarian.
final transactionsListProvider = FutureProvider<List<TransactionModel>>((
  ref,
) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final typeFilter = ref.watch(transactionTypeFilterProvider);
  final categoryFilter = ref.watch(transactionCategoryFilterProvider);
  final searchQuery = ref.watch(transactionSearchQueryProvider);

  return await repository.getTransactions(
    type: typeFilter,
    categoryId: categoryFilter,
    searchQuery: searchQuery,
  );
});

/// Model data ringkasan untuk halaman Dashboard.
class DashboardSummary {
  final int availableBalance;
  final int monthIncome;
  final int monthExpense;
  final List<TransactionModel> recentTransactions;

  const DashboardSummary({
    required this.availableBalance,
    required this.monthIncome,
    required this.monthExpense,
    required this.recentTransactions,
  });
}

/// Provider agregasi data ringkasan untuk Dashboard.
final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final repository = ref.watch(transactionRepositoryProvider);

  final now = DateTime.now();
  final startOfMonth = DateFormatter.startOfMonth(now);
  final endOfMonth = DateFormatter.endOfMonth(now);

  final balance = await repository.getAvailableBalance();
  final income = await repository.getTotalIncome(
    startDate: startOfMonth,
    endDate: endOfMonth,
  );
  final expense = await repository.getTotalExpense(
    startDate: startOfMonth,
    endDate: endOfMonth,
  );
  final recent = await repository.getTransactions(limit: 5);

  return DashboardSummary(
    availableBalance: balance,
    monthIncome: income,
    monthExpense: expense,
    recentTransactions: recent,
  );
});

/// Controller untuk aksi Create, Update, dan Delete transaksi.
class TransactionActionController {
  final Ref _ref;

  TransactionActionController(this._ref);

  Future<int> addTransaction(TransactionModel transaction) async {
    final repo = _ref.read(transactionRepositoryProvider);
    final id = await repo.addTransaction(transaction);
    _invalidateData();
    return id;
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final repo = _ref.read(transactionRepositoryProvider);
    final count = await repo.updateTransaction(transaction);
    _invalidateData();
    return count;
  }

  Future<int> deleteTransaction(int id) async {
    final repo = _ref.read(transactionRepositoryProvider);
    final count = await repo.deleteTransaction(id);
    _invalidateData();
    return count;
  }

  void _invalidateData() {
    _ref.invalidate(transactionsListProvider);
    _ref.invalidate(dashboardSummaryProvider);
  }
}

/// Provider untuk mengakses [TransactionActionController].
final transactionActionControllerProvider =
    Provider<TransactionActionController>((ref) {
      return TransactionActionController(ref);
    });
