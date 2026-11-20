/// Model data untuk tabel `debts` (Utang & Piutang).
///
/// [direction]:
/// - 'payable': Utang (saya berutang ke orang lain — kewajiban)
/// - 'receivable': Piutang (orang lain berutang ke saya — hak tagih)
class DebtModel {
  final int? id;
  final String direction; // 'payable' | 'receivable'
  final String personName;
  final int principalAmount;
  final DateTime? dueDate;
  final String? note;
  final DateTime createdAt;
  final String status; // 'active' | 'settled' | 'archived'

  /// Total yang sudah dibayarkan (dihitung dari riwayat pembayaran).
  final int paidAmount;

  const DebtModel({
    this.id,
    required this.direction,
    required this.personName,
    required this.principalAmount,
    this.dueDate,
    this.note,
    required this.createdAt,
    this.status = 'active',
    this.paidAmount = 0,
  }) : assert(principalAmount > 0, 'Nominal pokok harus lebih besar dari 0');

  /// Apakah berupa Utang (saya berutang ke pihak lain).
  bool get isPayable => direction == 'payable';

  /// Apakah berupa Piutang (pihak lain berutang ke saya).
  bool get isReceivable => direction == 'receivable';

  /// Sisa nominal utang/piutang yang belum dilunasi.
  int get remainingAmount {
    final diff = principalAmount - paidAmount;
    return diff > 0 ? diff : 0;
  }

  /// Apakah sudah lunas.
  bool get isSettled => status == 'settled' || remainingAmount == 0;

  /// Mengonversi Map dari database SQLite ke objek [DebtModel].
  factory DebtModel.fromMap(Map<String, dynamic> map, {int paidAmount = 0}) {
    return DebtModel(
      id: map['id'] as int?,
      direction: map['direction'] as String,
      personName: map['person_name'] as String,
      principalAmount: map['principal_amount'] as int,
      dueDate: map['due_date'] != null
          ? DateTime.parse(map['due_date'] as String)
          : null,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      status: map['status'] as String,
      paidAmount: paidAmount,
    );
  }

  /// Mengonversi objek [DebtModel] ke Map untuk penyimpanan SQLite.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'direction': direction,
      'person_name': personName,
      'principal_amount': principalAmount,
      'due_date': dueDate?.toIso8601String(),
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Membuat salinan objek dengan atribut yang diperbarui.
  DebtModel copyWith({
    int? id,
    String? direction,
    String? personName,
    int? principalAmount,
    DateTime? dueDate,
    String? note,
    DateTime? createdAt,
    String? status,
    int? paidAmount,
  }) {
    return DebtModel(
      id: id ?? this.id,
      direction: direction ?? this.direction,
      personName: personName ?? this.personName,
      principalAmount: principalAmount ?? this.principalAmount,
      dueDate: dueDate ?? this.dueDate,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      paidAmount: paidAmount ?? this.paidAmount,
    );
  }
}
