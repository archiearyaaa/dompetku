import '../datasources/transaction_datasource.dart';
import '../models/category_expense_model.dart';
import '../models/transaction_model.dart';

/// Repository untuk mengelola akses data transaksi keuangan.
class TransactionRepository {
  final TransactionDatasource _datasource;

  TransactionRepository({TransactionDatasource? datasource})
    : _datasource = datasource ?? TransactionDatasource();

  Future<List<TransactionModel>> getTransactions({
    String? type,
    int? categoryId,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) {
    return _datasource.getTransactions(
      type: type,
      categoryId: categoryId,
      searchQuery: searchQuery,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
      offset: offset,
    );
  }

  Future<TransactionModel?> getTransactionById(int id) {
    return _datasource.getTransactionById(id);
  }

  Future<int> addTransaction(TransactionModel transaction) {
    return _datasource.insertTransaction(transaction);
  }

  Future<int> updateTransaction(TransactionModel transaction) {
    return _datasource.updateTransaction(transaction);
  }

  Future<int> deleteTransaction(int id) {
    return _datasource.deleteTransaction(id);
  }

  Future<int> getTotalIncome({DateTime? startDate, DateTime? endDate}) {
    return _datasource.getTotalIncome(startDate: startDate, endDate: endDate);
  }

  Future<int> getTotalExpense({DateTime? startDate, DateTime? endDate}) {
    return _datasource.getTotalExpense(startDate: startDate, endDate: endDate);
  }

  Future<List<CategoryExpenseModel>> getExpenseByCategory({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _datasource.getExpenseByCategory(
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<int> getAvailableBalance() {
    return _datasource.getAvailableBalance();
  }
}
