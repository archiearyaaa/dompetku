# Technical Architecture
## Dompetku

- **Versi dokumen:** 1.0
- **Status:** Draft arsitektur MVP

## 1. Ringkasan Arsitektur
Dompetku menggunakan arsitektur Flutter modular dengan pemisahan presentasi, logika aplikasi, dan akses data. SQLite menjadi sumber data lokal utama.

Alur umum:

```text
UI / Screens
    |
    v
State Management / Controllers
    |
    v
Services / Use Cases
    |
    v
Repositories
    |
    v
SQLite Database (sqflite)
```

Widget tidak boleh menjalankan SQL secara langsung. Screen berinteraksi dengan controller/provider, controller menggunakan service atau repository, dan repository mengelola akses database.

## 2. Teknologi
| Area | Teknologi | Tanggung jawab |
|---|---|---|
| Platform | Android | Target MVP |
| UI | Flutter | Antarmuka aplikasi |
| Bahasa | Dart | Implementasi |
| Database | SQLite melalui `sqflite` | Penyimpanan lokal |
| Path database | `path` | Penyusunan lokasi file database |
| Format | `intl` | Rupiah dan tanggal |
| Grafik | `fl_chart` | Visualisasi laporan |
| Preferensi | `shared_preferences` | Preferensi non-kritis |
| State management | Provider atau Riverpod | Dipilih dan dikunci saat setup implementasi |

Catatan: jangan menambahkan package baru tanpa alasan teknis dan pemeriksaan kompatibilitas.

## 3. Struktur Folder yang Disarankan

```text
dompetku/
├── android/
├── assets/
│   ├── icons/
│   └── images/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── constants/
│   │   ├── database/
│   │   │   ├── database_helper.dart
│   │   │   └── migrations/
│   │   ├── errors/
│   │   ├── theme/
│   │   └── utils/
│   ├── data/
│   │   ├── datasources/
│   │   ├── models/
│   │   └── repositories/
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/
│   │   └── usecases/
│   ├── features/
│   │   ├── dashboard/
│   │   │   ├── screens/
│   │   │   ├── widgets/
│   │   │   └── controllers/
│   │   ├── transactions/
│   │   ├── categories/
│   │   ├── savings/
│   │   ├── debts/
│   │   ├── reports/
│   │   └── settings/
│   └── shared/
│       ├── widgets/
│       └── formatters/
├── test/
│   ├── unit/
│   ├── widget/
│   └── helpers/
├── pubspec.yaml
├── PRD.md
├── ARCHITECTURE.md
├── TODO.md
├── AGENTS.md
├── WORKFLOW.md
└── SKILL.md
```

Struktur boleh disederhanakan jika skala kode masih kecil, tetapi pemisahan tanggung jawab harus tetap dijaga.

## 4. Arsitektur Aplikasi
### Presentation
- Screens, widgets, forms, dan navigasi.
- Menampilkan state loading, data, empty, dan error.
- Tidak berisi query SQL atau perhitungan bisnis yang kompleks.

### State Management / Controllers
- Mengelola state halaman.
- Memanggil use case/service.
- Memvalidasi alur UI dan meneruskan hasil ke tampilan.

### Domain / Use Cases
- Aturan bisnis keuangan.
- Perhitungan saldo, progres tabungan, sisa utang/piutang, dan ringkasan laporan.
- Tidak bergantung pada widget Flutter atau implementasi SQLite.

### Data / Repositories
- Mengubah data database menjadi model/entity.
- Menangani query, transaksi database, dan pemetaan data.
- Menjadi satu-satunya lapisan fitur yang berinteraksi langsung dengan datasource.

## 5. Desain Database SQLite

Gunakan foreign key dan transaksi database untuk operasi yang melibatkan lebih dari satu tabel. Aktifkan `PRAGMA foreign_keys = ON` pada setiap koneksi yang relevan.

### Tabel `categories`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id | INTEGER PK | ID kategori |
| name | TEXT | Nama kategori |
| type | TEXT | income / expense |
| icon | TEXT nullable | Nama ikon |
| color | TEXT nullable | Warna |
| is_default | INTEGER | Kategori bawaan |
| is_archived | INTEGER | Status arsip |
| created_at | TEXT | Waktu dibuat |

### Tabel `transactions`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id | INTEGER PK | ID transaksi |
| type | TEXT | income / expense |
| amount | INTEGER | Nominal Rupiah positif |
| category_id | INTEGER FK | Kategori |
| note | TEXT nullable | Catatan |
| occurred_at | TEXT | Waktu transaksi |
| created_at | TEXT | Waktu dibuat |
| updated_at | TEXT | Waktu diubah |

### Tabel `savings_goals`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id | INTEGER PK | ID target |
| name | TEXT | Nama target |
| target_amount | INTEGER | Target Rupiah |
| target_date | TEXT nullable | Tenggat |
| created_at | TEXT | Waktu dibuat |
| is_archived | INTEGER | Status arsip |

### Tabel `savings_movements`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id | INTEGER PK | ID mutasi |
| goal_id | INTEGER FK | Target tabungan |
| type | TEXT | deposit / withdrawal |
| amount | INTEGER | Nominal positif |
| occurred_at | TEXT | Waktu mutasi |
| note | TEXT nullable | Catatan |

### Tabel `debts`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id | INTEGER PK | ID catatan |
| direction | TEXT | payable / receivable |
| person_name | TEXT | Nama pihak terkait |
| principal_amount | INTEGER | Nominal awal |
| due_date | TEXT nullable | Jatuh tempo |
| note | TEXT nullable | Catatan |
| created_at | TEXT | Waktu dibuat |
| status | TEXT | active / settled / archived |

### Tabel `debt_payments`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id | INTEGER PK | ID pembayaran |
| debt_id | INTEGER FK | Catatan utang/piutang |
| amount | INTEGER | Nominal positif |
| occurred_at | TEXT | Tanggal pembayaran |
| note | TEXT nullable | Catatan |

### Tabel `settings`
| Kolom | Tipe | Keterangan |
|---|---|---|
| key | TEXT PK | Kunci pengaturan |
| value | TEXT | Nilai pengaturan |

Simpan waktu dalam format ISO-8601 yang konsisten. Buat index untuk kolom tanggal, kategori, dan foreign key yang sering digunakan.

## 6. Hubungan Antarfitur
- Dashboard membaca agregasi dari transaksi, mutasi tabungan, dan pembayaran utang/piutang.
- Transaksi menggunakan kategori.
- Tabungan memiliki banyak mutasi setoran/penarikan.
- Utang/piutang memiliki banyak catatan pembayaran.
- Laporan membaca data transaksi dan mutasi dengan aturan klasifikasi yang konsisten.
- Pengaturan menyimpan preferensi aplikasi, bukan saldo atau data transaksi utama.

## 7. Aturan Perhitungan
- Simpan nominal sebagai integer Rupiah dan validasi `amount > 0`.
- Pemasukan menambah saldo kas.
- Pengeluaran mengurangi saldo kas.
- Setoran tabungan mengurangi saldo tersedia dan menambah saldo tabungan.
- Penarikan tabungan menambah saldo tersedia dan mengurangi saldo tabungan.
- Utang diterima menambah kas dan kewajiban, bukan pendapatan.
- Pembayaran utang mengurangi kas dan kewajiban.
- Piutang diberikan mengurangi kas dan menambah piutang.
- Pembayaran piutang yang diterima menambah kas dan mengurangi piutang.
- Gunakan satu sumber kebenaran; jangan menyimpan total saldo yang dapat dihitung ulang kecuali ada kebutuhan performa dan mekanisme rekonsiliasi.

## 8. Migrasi Database
- Gunakan `version` pada `openDatabase`.
- Setiap perubahan skema harus memiliki migrasi `onUpgrade` yang berurutan.
- Jangan menghapus atau mengganti database pengguna saat upgrade.
- Uji migrasi dari setiap versi skema yang pernah dirilis.
- Gunakan transaksi database saat migrasi dan operasi multi-tabel.

## 9. Keamanan dan Privasi
- Tidak menyimpan password atau data kartu pembayaran.
- Data keuangan bersifat privat dan tidak dikirim ke server pada MVP.
- Hindari mencetak nominal, nama pihak, atau catatan pribadi ke log produksi.
- Validasi semua input dan gunakan parameterized query.
- Fitur ekspor/cadangan di masa depan harus memberi kontrol eksplisit kepada pengguna.

## 10. Keputusan Teknis Final
- State management: Riverpod (`flutter_riverpod`).
- Minimum Android SDK: Mengikuti konfigurasi default Flutter (`flutter.minSdkVersion`).
- Architecture: Simplified Clean Architecture (modular).
- Strategi backup/restore: Direncanakan setelah MVP.
- Dompet/sumber kas: Single wallet/cash flow untuk MVP.
