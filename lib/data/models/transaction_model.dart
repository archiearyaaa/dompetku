import 'category_model.dart';

/// Model data untuk tabel `transactions`.
///
/// [amount] selalu bernilai integer Rupiah positif.
/// Arah saldo ditentukan oleh [type] ('income' atau 'expense').
class TransactionModel {
  final int? id;
  final String type; // 'income' | 'expense'
  final int amount;
  final int categoryId;
  final String? note;
  final DateTime occurredAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Kategori terkait (diisi saat query JOIN).
  final CategoryModel? category;

  const TransactionModel({
    this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    this.note,
    required this.occurredAt,
    required this.createdAt,
    required this.updatedAt,
    this.category,
  }) : assert(amount > 0, 'Nominal transaksi harus lebih besar dari 0');

  /// Apakah transaksi merupakan pemasukan.
  bool get isIncome => type == 'income';

  /// Apakah transaksi merupakan pengeluaran.
  bool get isExpense => type == 'expense';

  /// Mengonversi Map dari database SQLite ke objek [TransactionModel].
  factory TransactionModel.fromMap(
    Map<String, dynamic> map, {
    CategoryModel? category,
  }) {
    return TransactionModel(
      id: map['id'] as int?,
      type: map['type'] as String,
      amount: map['amount'] as int,
      categoryId: map['category_id'] as int,
      note: map['note'] as String?,
      occurredAt: DateTime.parse(map['occurred_at'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      category: category,
    );
  }

  /// Mengonversi objek [TransactionModel] ke Map untuk penyimpanan SQLite.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'type': type,
      'amount': amount,
      'category_id': categoryId,
      'note': note,
      'occurred_at': occurredAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Membuat salinan objek dengan atribut yang diperbarui.
  TransactionModel copyWith({
    int? id,
    String? type,
    int? amount,
    int? categoryId,
    String? note,
    DateTime? occurredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    CategoryModel? category,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      occurredAt: occurredAt ?? this.occurredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
    );
  }
}
