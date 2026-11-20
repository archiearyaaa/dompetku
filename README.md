# Dompetku 👛

<p align="center">
  <img src="assets/icons/app_icon.png" width="128" height="128" alt="Dompetku Logo" />
</p>

<p align="center">
  <b>Aplikasi Pengelola Keuangan Pribadi Modern, Minimalis & Offline-First</b><br>
  Dibangun menggunakan Flutter, Dart, SQLite (sqflite), dan Riverpod.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android-green?logo=android" alt="Platform Android" />
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Language-Dart-0175C2?logo=dart" alt="Dart" />
  <img src="https://img.shields.io/badge/Database-SQLite-003B57?logo=sqlite" alt="SQLite" />
  <img src="https://img.shields.io/badge/State_Management-Riverpod_3-purple" alt="Riverpod" />
  <img src="https://img.shields.io/badge/Tests-92%20Passed-brightgreen" alt="Tests" />
  <img src="https://img.shields.io/badge/License-Copyright-blue" alt="License" />
</p>

---

## 🌟 Fitur Utama

- **Dashboard Real-Time**:
  - Saldo kas tersedia terpadu yang terhitung otomatis dari seluruh arus kas masuk, keluar, tabungan, dan pelunasan kewajiban.
  - Kartu ringkasan pemasukan bulanan, pengeluaran bulanan, tabungan aktif, utang, dan piutang.
  - Akses cepat (*Quick Actions*) untuk pencatatan instan.

- **Pencatatan Transaksi Pemasukan & Pengeluaran**:
  - Format nominal otomatis mata uang Rupiah (`Rp`).
  - Validasi ketat nominal positif dan kategori wajib.
  - Form edit, konfirmasi hapus permanen, dan empty state ramah.

- **Pencarian Transaksi & Filter Kategori**:
  - Kolom pencarian cepat (*real-time search*) berdasarkan catatan transaksi maupun nama kategori.
  - Filter chip jenis transaksi (Semua, Pemasukan, Pengeluaran).
  - Filter dropdown dinamis per kategori dengan ikon dan warna masing-masing.

- **Manajemen Kategori Kustom**:
  - 12 kategori sistem bawaan siap pakai.
  - Tambah, ubah, arsipkan, dan aktifkan kembali kategori buatan pengguna.
  - 21 preset ikon material dan 12 palet warna hex modern.
  - *Live preview* kartu kategori interaktif.
  - Proteksi integritas relasi data: kategori yang sudah dipakai dalam riwayat transaksi dilindungi dari penghapusan permanen (`ON DELETE RESTRICT`) dan diarahkan untuk diarsipkan.

- **Target Tabungan (*Savings Goals*)**:
  - Pembuatan target tabungan dengan target nominal dan tenggat waktu opsional.
  - Pencatatan mutasi setoran dan penarikan tabungan.
  - Validasi pencegahan penarikan melebihi saldo tabungan aktual.
  - Indikator progres persentase dinamis dan badge target tercapai.

- **Pencatatan Utang & Piutang (*Debts & Receivables*)**:
  - Pencatatan uang yang dipinjam (utang) dan uang yang dipinjamkan (piutang).
  - Pembayaran bertahap (cicilan) dan pelunasan sekaligus dengan validasi pembayaran tidak melebihi sisa kewajiban.
  - Riwayat lengkap mutasi pembayaran per utang/piutang.
  - Pengingat jatuh tempo lokal.

- **Laporan Arus Kas & Analisis Grafik**:
  - Filter rentang periode: Harian, Mingguan (Senin–Minggu ISO), Bulanan, dan Rentang Tanggal Kustom.
  - Visualisasi grafik donat (*donut pie chart*) pengeluaran interaktif dengan sentuhan tooltip menggunakan `fl_chart`.
  - Rincian pengeluaran per kategori lengkap dengan persentase dan bar kemajuan.
  - Ekspor laporan keuangan ke format teks CSV terstruktur yang ramah offline dan dapat disalin ke clipboard.

- **Tampilan & Kenyamanan Pengguna**:
  - Desain modern minimalis berpedoman Material Design 3.
  - Dukungan Tema Terang (*Light Mode*) dan Tema Gelap (*Dark Mode*) dengan persistensi `shared_preferences`.
  - Berfungsi 100% secara offline tanpa memerlukan koneksi internet atau login.

---

## 🏗️ Arsitektur & Teknologi

Proyek ini menerapkan **Simplified Clean Architecture** dengan pemisahan tanggung jawab yang rapi:

```
lib/
├── core/                  # Konstanta, konfigurasi database, tema, & utilitas formatter
│   ├── constants/
│   ├── database/          # DatabaseHelper & skema SQLite (7 tabel)
│   ├── theme/             # AppColors & AppTheme (Light & Dark)
│   └── utils/             # CurrencyFormatter, DateFormatter, CategoryIconHelper
├── data/                  # Lapisan data terpadu (SQLite)
│   ├── datasources/       # Query SQLite mentah (Category, Transaction, Savings, Debt)
│   ├── models/            # Entitas model data & pemetaan toMap/fromMap
│   └── repositories/      # Repository penghubung data ke domain
├── features/              # Modul fitur berbasis domain
│   ├── categories/        # Manajemen Kategori Kustom
│   ├── dashboard/         # Dashboard & Navigasi Bawah
│   ├── debts/             # Modul Utang & Piutang
│   ├── reports/           # Laporan Keuangan, Grafik, & Ekspor CSV
│   ├── savings/           # Modul Target Tabungan & Mutasi
│   ├── settings/          # Pengaturan Aplikasi & Tema
│   └── transactions/      # Pencatatan Transaksi & Pencarian
└── shared/                # Widget & formatter yang digunakan lintas fitur
```

---

## 🚀 Memulai (Getting Started)

### Prasyarat
- Flutter SDK (versi 3.x ke atas)
- Android Studio / VS Code dengan ekstensi Flutter & Dart
- Android SDK untuk pengujian perangkat

### Langkah Instalasi

1. **Clone repositori ini**:
   ```bash
   git clone https://github.com/archiearyaaa/dompetku.git
   cd dompetku
   ```

2. **Pasang dependensi proyek**:
   ```bash
   flutter pub get
   ```

3. **Jalankan pengujian (Unit & Widget Test)**:
   ```bash
   flutter test
   ```

4. **Jalankan aplikasi di perangkat / emulator**:
   ```bash
   flutter run
   ```

5. **Build APK Release**:
   ```bash
   flutter build apk --release
   ```
   File APK siap pasang akan tersedia di `build/app/outputs/flutter-apk/app-release.apk`.

---

## 🧪 Pengujian (Testing)

Proyek ini dilengkapi dengan cakupan pengujian unit dan pengujian widget yang menyeluruh:
- **Unit Tests**: Kalkulasi saldo keuangan, aturan penarikan tabungan, pembatasan pelunasan utang, integritas skema SQLite & foreign key cascades, kueri pencarian & filter, serta parsing/format Rupiah.
- **Widget Tests**: Formulir input, validasi error state, navigasi 5 tab, dialog aksi, filter kategori, dan antarmuka pengaturan.

Jalankan seluruh pengujian:
```bash
flutter test
```
*Status: 92/92 test lulus 100%.*

---

## 📄 Hak Cipta & Lisensi

Copyright © 2026 **Archie Arya Manggala**. All rights reserved.
Aplikasi ini dikembangkan untuk keperluan pengelolaan keuangan pribadi yang aman, privat, dan offline-first.
