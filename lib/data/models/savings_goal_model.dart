/// Model data untuk tabel `savings_goals`.
class SavingsGoalModel {
  final int? id;
  final String name;
  final int targetAmount;
  final DateTime? targetDate;
  final DateTime createdAt;
  final bool isArchived;

  /// Jumlah terkumpul saat ini (dihitung dari saldo mutasi).
  final int currentAmount;

  const SavingsGoalModel({
    this.id,
    required this.name,
    required this.targetAmount,
    this.targetDate,
    required this.createdAt,
    this.isArchived = false,
    this.currentAmount = 0,
  }) : assert(targetAmount > 0, 'Target nominal harus lebih besar dari 0');

  /// Persentase progres tabungan (0.0 sampai 1.0+).
  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  /// Sisa nominal untuk mencapai target tabungan.
  int get remainingAmount {
    final diff = targetAmount - currentAmount;
    return diff > 0 ? diff : 0;
  }

  /// Apakah target tabungan sudah tercapai.
  bool get isAchieved => currentAmount >= targetAmount;

  /// Mengonversi Map dari database SQLite ke objek [SavingsGoalModel].
  factory SavingsGoalModel.fromMap(
    Map<String, dynamic> map, {
    int currentAmount = 0,
  }) {
    return SavingsGoalModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      targetAmount: map['target_amount'] as int,
      targetDate: map['target_date'] != null
          ? DateTime.parse(map['target_date'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      isArchived: (map['is_archived'] as int) == 1,
      currentAmount: currentAmount,
    );
  }

  /// Mengonversi objek [SavingsGoalModel] ke Map untuk penyimpanan SQLite.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'target_amount': targetAmount,
      'target_date': targetDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'is_archived': isArchived ? 1 : 0,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Membuat salinan objek dengan atribut yang diperbarui.
  SavingsGoalModel copyWith({
    int? id,
    String? name,
    int? targetAmount,
    DateTime? targetDate,
    DateTime? createdAt,
    bool? isArchived,
    int? currentAmount,
  }) {
    return SavingsGoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
      currentAmount: currentAmount ?? this.currentAmount,
    );
  }
}
