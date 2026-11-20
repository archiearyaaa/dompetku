/// Model agregasi pengeluaran per kategori untuk visualisasi grafik dan laporan.
class CategoryExpenseModel {
  final int categoryId;
  final String categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final int totalAmount;
  final int transactionCount;
  final double percentage;

  const CategoryExpenseModel({
    required this.categoryId,
    required this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    required this.totalAmount,
    required this.transactionCount,
    this.percentage = 0.0,
  });

  /// Mengonversi hasil query agregasi SQLite ke [CategoryExpenseModel].
  factory CategoryExpenseModel.fromMap(
    Map<String, dynamic> map, {
    int totalExpense = 0,
  }) {
    final amount = (map['total_amount'] as num?)?.toInt() ?? 0;
    final count = (map['transaction_count'] as num?)?.toInt() ?? 0;
    final pct = totalExpense > 0
        ? (amount / totalExpense).clamp(0.0, 1.0)
        : 0.0;

    return CategoryExpenseModel(
      categoryId: map['category_id'] as int,
      categoryName: map['category_name'] as String,
      categoryIcon: map['category_icon'] as String?,
      categoryColor: map['category_color'] as String?,
      totalAmount: amount,
      transactionCount: count,
      percentage: pct,
    );
  }
}
