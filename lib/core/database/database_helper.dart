import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';

/// Helper terpusat untuk manajemen database SQLite Dompetku.
///
/// Menyediakan inisialisasi koneksi tunggal (singleton), pembuatan tabel,
/// migrasi skema, dan aktivasi Foreign Key.
class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal();

  /// Mengembalikan instance singleton [DatabaseHelper].
  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  /// Memungkinkan injeksi instance database kustom (berguna untuk testing).
  static void setDatabaseForTesting(Database? db) {
    _database = db;
  }

  /// Mengembalikan instance [Database] yang aktif.
  ///
  /// Menginisialisasi koneksi jika belum dibuka.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  /// Inisialisasi database SQLite di path penyimpanan perangkat.
  Future<Database> initDatabase({String? customPath}) async {
    final String path;
    if (customPath == inMemoryDatabasePath) {
      path = inMemoryDatabasePath;
    } else {
      final dbPath = customPath ?? await getDatabasesPath();
      path = p.join(dbPath, AppConstants.databaseName);
    }

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Mengaktifkan penegakan Foreign Key pada SQLite.
  ///
  /// Wajib dipanggil pada setiap koneksi agar relasi data terjaga integritasnya.
  static Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  /// Pembuatan skema tabel awal dan data seed (versi 1).
  static Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    // ── 1. Tabel categories ──────────────────────────────
    batch.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT,
        color TEXT,
        is_default INTEGER NOT NULL DEFAULT 0,
        is_archived INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      );
    ''');

    // ── 2. Tabel transactions ────────────────────────────
    batch.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        amount INTEGER NOT NULL CHECK (amount > 0),
        category_id INTEGER NOT NULL,
        note TEXT,
        occurred_at TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE RESTRICT
      );
    ''');

    // ── 3. Tabel savings_goals ───────────────────────────
    batch.execute('''
      CREATE TABLE savings_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        target_amount INTEGER NOT NULL CHECK (target_amount > 0),
        target_date TEXT,
        created_at TEXT NOT NULL,
        is_archived INTEGER NOT NULL DEFAULT 0
      );
    ''');

    // ── 4. Tabel savings_movements ───────────────────────
    batch.execute('''
      CREATE TABLE savings_movements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goal_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        amount INTEGER NOT NULL CHECK (amount > 0),
        occurred_at TEXT NOT NULL,
        note TEXT,
        FOREIGN KEY (goal_id) REFERENCES savings_goals (id) ON DELETE CASCADE
      );
    ''');

    // ── 5. Tabel debts ───────────────────────────────────
    batch.execute('''
      CREATE TABLE debts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        direction TEXT NOT NULL,
        person_name TEXT NOT NULL,
        principal_amount INTEGER NOT NULL CHECK (principal_amount > 0),
        due_date TEXT,
        note TEXT,
        created_at TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'active'
      );
    ''');

    // ── 6. Tabel debt_payments ───────────────────────────
    batch.execute('''
      CREATE TABLE debt_payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        debt_id INTEGER NOT NULL,
        amount INTEGER NOT NULL CHECK (amount > 0),
        occurred_at TEXT NOT NULL,
        note TEXT,
        FOREIGN KEY (debt_id) REFERENCES debts (id) ON DELETE CASCADE
      );
    ''');

    // ── 7. Tabel settings ────────────────────────────────
    batch.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      );
    ''');

    // ── Index untuk optimasi performa query ─────────────
    batch.execute(
      'CREATE INDEX idx_transactions_occurred_at ON transactions (occurred_at);',
    );
    batch.execute(
      'CREATE INDEX idx_transactions_category_id ON transactions (category_id);',
    );
    batch.execute('CREATE INDEX idx_transactions_type ON transactions (type);');
    batch.execute(
      'CREATE INDEX idx_savings_movements_goal_id ON savings_movements (goal_id);',
    );
    batch.execute(
      'CREATE INDEX idx_savings_movements_occurred_at ON savings_movements (occurred_at);',
    );
    batch.execute('CREATE INDEX idx_debts_status ON debts (status);');
    batch.execute('CREATE INDEX idx_debts_direction ON debts (direction);');
    batch.execute(
      'CREATE INDEX idx_debt_payments_debt_id ON debt_payments (debt_id);',
    );

    // Eksekusi seluruh pembuatan tabel dan index.
    await batch.commit(noResult: true);

    // ── Data Seed: Kategori Bawaan ───────────────────────
    await _seedDefaultCategories(db);

    // ── Data Seed: Pengaturan Awal ───────────────────────
    await _seedDefaultSettings(db);
  }

  /// Menanam data kategori bawaan saat database pertama kali dibuat.
  static Future<void> _seedDefaultCategories(Database db) async {
    final now = DateTime.now().toIso8601String();
    final batch = db.batch();

    final defaultCategories = [
      // Kategori Pemasukan
      {
        'name': 'Gaji',
        'type': 'income',
        'icon': 'wallet',
        'color': '0xFF22C55E',
      },
      {
        'name': 'Bonus',
        'type': 'income',
        'icon': 'card_giftcard',
        'color': '0xFF10B981',
      },
      {
        'name': 'Investasi',
        'type': 'income',
        'icon': 'trending_up',
        'color': '0xFF3B82F6',
      },
      {
        'name': 'Pemasukan Lain',
        'type': 'income',
        'icon': 'attach_money',
        'color': '0xFF6B7280',
      },

      // Kategori Pengeluaran
      {
        'name': 'Makanan & Minuman',
        'type': 'expense',
        'icon': 'restaurant',
        'color': '0xFFEF4444',
      },
      {
        'name': 'Transportasi',
        'type': 'expense',
        'icon': 'directions_car',
        'color': '0xFFF97316',
      },
      {
        'name': 'Belanja',
        'type': 'expense',
        'icon': 'shopping_bag',
        'color': '0xFFEC4899',
      },
      {
        'name': 'Tagihan & Utilitas',
        'type': 'expense',
        'icon': 'receipt_long',
        'color': '0xFF8B5CF6',
      },
      {
        'name': 'Hiburan',
        'type': 'expense',
        'icon': 'sports_esports',
        'color': '0xFF06B6D4',
      },
      {
        'name': 'Kesehatan',
        'type': 'expense',
        'icon': 'medical_services',
        'color': '0xFF14B8A6',
      },
      {
        'name': 'Pendidikan',
        'type': 'expense',
        'icon': 'school',
        'color': '0xFF6366F1',
      },
      {
        'name': 'Pengeluaran Lain',
        'type': 'expense',
        'icon': 'more_horiz',
        'color': '0xFF9CA3AF',
      },
    ];

    for (final cat in defaultCategories) {
      batch.insert('categories', {
        'name': cat['name'],
        'type': cat['type'],
        'icon': cat['icon'],
        'color': cat['color'],
        'is_default': 1,
        'is_archived': 0,
        'created_at': now,
      });
    }

    await batch.commit(noResult: true);
  }

  /// Menanam pengaturan default aplikasi.
  static Future<void> _seedDefaultSettings(Database db) async {
    final batch = db.batch();

    batch.insert('settings', {
      'key': 'app_version',
      'value': AppConstants.appVersion,
    });
    batch.insert('settings', {'key': 'currency', 'value': 'IDR'});

    await batch.commit(noResult: true);
  }

  /// Menangani migrasi skema database antar versi.
  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Migrasi versi masa depan akan diimplementasikan di sini secara bertahap
    // Contoh: if (oldVersion < 2) { await migrationV2(db); }
  }

  /// Menutup koneksi database yang aktif.
  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}
