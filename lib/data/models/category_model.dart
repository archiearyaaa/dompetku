/// Model data untuk tabel `categories`.
class CategoryModel {
  final int? id;
  final String name;
  final String type; // 'income' | 'expense'
  final String? icon;
  final String? color;
  final bool isDefault;
  final bool isArchived;
  final DateTime createdAt;

  const CategoryModel({
    this.id,
    required this.name,
    required this.type,
    this.icon,
    this.color,
    this.isDefault = false,
    this.isArchived = false,
    required this.createdAt,
  });

  /// Mengonversi Map dari database SQLite ke objek [CategoryModel].
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: map['type'] as String,
      icon: map['icon'] as String?,
      color: map['color'] as String?,
      isDefault: (map['is_default'] as int) == 1,
      isArchived: (map['is_archived'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Mengonversi objek [CategoryModel] ke Map untuk penyimpanan SQLite.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'is_default': isDefault ? 1 : 0,
      'is_archived': isArchived ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Membuat salinan objek dengan nilai atribut yang diperbarui.
  CategoryModel copyWith({
    int? id,
    String? name,
    String? type,
    String? icon,
    String? color,
    bool? isDefault,
    bool? isArchived,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
