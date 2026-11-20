/// Model data untuk tabel `savings_movements`.
///
/// Menyimpan riwayat setoran ('deposit') atau penarikan ('withdrawal')
/// pada suatu target tabungan.
class SavingsMovementModel {
  final int? id;
  final int goalId;
  final String type; // 'deposit' | 'withdrawal'
  final int amount;
  final DateTime occurredAt;
  final String? note;

  const SavingsMovementModel({
    this.id,
    required this.goalId,
    required this.type,
    required this.amount,
    required this.occurredAt,
    this.note,
  }) : assert(amount > 0, 'Nominal mutasi harus lebih besar dari 0');

  /// Apakah mutasi merupakan setoran tabungan.
  bool get isDeposit => type == 'deposit';

  /// Apakah mutasi merupakan penarikan tabungan.
  bool get isWithdrawal => type == 'withdrawal';

  /// Mengonversi Map dari database SQLite ke objek [SavingsMovementModel].
  factory SavingsMovementModel.fromMap(Map<String, dynamic> map) {
    return SavingsMovementModel(
      id: map['id'] as int?,
      goalId: map['goal_id'] as int,
      type: map['type'] as String,
      amount: map['amount'] as int,
      occurredAt: DateTime.parse(map['occurred_at'] as String),
      note: map['note'] as String?,
    );
  }

  /// Mengonversi objek [SavingsMovementModel] ke Map untuk penyimpanan SQLite.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'goal_id': goalId,
      'type': type,
      'amount': amount,
      'occurred_at': occurredAt.toIso8601String(),
      'note': note,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Membuat salinan objek dengan atribut yang diperbarui.
  SavingsMovementModel copyWith({
    int? id,
    int? goalId,
    String? type,
    int? amount,
    DateTime? occurredAt,
    String? note,
  }) {
    return SavingsMovementModel(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      occurredAt: occurredAt ?? this.occurredAt,
      note: note ?? this.note,
    );
  }
}
