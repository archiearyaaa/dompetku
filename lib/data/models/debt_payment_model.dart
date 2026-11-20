/// Model data untuk tabel `debt_payments`.
///
/// Menyimpan cicilan / pembayaran sebagian atau pelunasan utang/piutang.
class DebtPaymentModel {
  final int? id;
  final int debtId;
  final int amount;
  final DateTime occurredAt;
  final String? note;

  const DebtPaymentModel({
    this.id,
    required this.debtId,
    required this.amount,
    required this.occurredAt,
    this.note,
  }) : assert(amount > 0, 'Nominal pembayaran harus lebih besar dari 0');

  /// Mengonversi Map dari database SQLite ke objek [DebtPaymentModel].
  factory DebtPaymentModel.fromMap(Map<String, dynamic> map) {
    return DebtPaymentModel(
      id: map['id'] as int?,
      debtId: map['debt_id'] as int,
      amount: map['amount'] as int,
      occurredAt: DateTime.parse(map['occurred_at'] as String),
      note: map['note'] as String?,
    );
  }

  /// Mengonversi objek [DebtPaymentModel] ke Map untuk penyimpanan SQLite.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'debt_id': debtId,
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
  DebtPaymentModel copyWith({
    int? id,
    int? debtId,
    int? amount,
    DateTime? occurredAt,
    String? note,
  }) {
    return DebtPaymentModel(
      id: id ?? this.id,
      debtId: debtId ?? this.debtId,
      amount: amount ?? this.amount,
      occurredAt: occurredAt ?? this.occurredAt,
      note: note ?? this.note,
    );
  }
}
