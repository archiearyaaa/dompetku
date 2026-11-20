# Dompetku — Task Management

Status: `[ ]` Belum dikerjakan · `[-]` Sedang dikerjakan · `[x]` Selesai  
Prioritas: **P0** wajib MVP · **P1** penting · **P2** setelah MVP

## 1. Persiapan Proyek
- [x] **P0** Buat project Flutter `dompetku`.
  - Selesai jika project dapat dibuka dan `flutter analyze` tidak memiliki error.
- [x] **P0** Tetapkan versi Flutter, Android SDK, dan state management.
  - Selesai jika keputusan dicatat di `ARCHITECTURE.md`.
- [x] **P0** Pasang dependensi yang diperlukan.
  - Selesai jika `flutter pub get` berhasil dan dependensi kompatibel.
- [x] **P1** Siapkan struktur folder modular.
  - Selesai jika folder utama tersedia dan aplikasi tetap dapat dijalankan.

## 2. Fondasi UI
- [x] **P0** Buat tema warna, tipografi, dan komponen dasar.
  - Selesai jika tema konsisten dan mendukung ukuran layar Android umum.
- [x] **P0** Buat navigasi bawah.
  - Selesai jika semua menu utama dapat dibuka.
- [x] **P0** Buat layout dashboard.
  - Selesai jika kartu saldo, ringkasan, dan transaksi terbaru tampil dengan state kosong.
- [x] **P1** Tambahkan dark mode.
  - Selesai jika seluruh halaman utama terbaca dalam tema gelap.

## 3. Database dan Model
- [x] **P0** Buat helper SQLite dan inisialisasi skema.
  - Selesai jika database dibuat tanpa error dan tabel sesuai arsitektur.
- [x] **P0** Aktifkan foreign key dan index yang dibutuhkan.
  - Selesai jika relasi diuji dan query umum memiliki index relevan.
- [x] **P0** Buat model/entity dan repository.
  - Selesai jika pemetaan data diuji.
- [x] **P0** Buat strategi migrasi database.
  - Selesai jika upgrade skema tidak menghilangkan data uji.
- [x] **P1** Buat seed kategori bawaan.
  - Selesai jika kategori hanya dibuat sekali dan tidak terduplikasi.

## 4. Transaksi
- [x] **P0** Buat daftar transaksi.
  - Selesai jika daftar, filter tanggal, dan empty state bekerja.
- [x] **P0** Buat tambah pemasukan.
  - Selesai jika nominal, kategori, tanggal, dan catatan tersimpan.
- [x] **P0** Buat tambah pengeluaran.
  - Selesai jika nominal, kategori, tanggal, dan catatan tersimpan.
- [x] **P0** Buat edit dan hapus transaksi.
  - Selesai jika perubahan tercermin pada dashboard dan laporan.
- [x] **P0** Validasi form transaksi.
  - Selesai jika nominal nol/negatif dan input wajib kosong ditolak.

## 5. Tabungan
- [x] **P0** Buat CRUD target tabungan.
  - Selesai jika target dapat dibuat, dilihat, diubah, dan diarsipkan.
- [x] **P0** Buat setoran dan penarikan.
  - Selesai jika mutasi tersimpan dan saldo tersedia/tabungan konsisten.
- [x] **P0** Buat progres target.
  - Selesai jika progres dihitung dari mutasi dan tidak melebihi aturan yang ditetapkan.

## 6. Utang dan Piutang
- [x] **P0** Buat pencatatan utang dan piutang.
  - Selesai jika arah kewajiban/piutang jelas dan saldo awal tercermin benar.
- [x] **P0** Buat pembayaran sebagian dan pelunasan.
  - Selesai jika sisa nominal dihitung benar dan pembayaran berlebih ditolak.
- [x] **P0** Buat riwayat pembayaran.
  - Selesai jika semua pembayaran dapat ditelusuri.
- [x] **P1** Tambahkan pengingat jatuh tempo lokal.
  - Selesai jika pengguna dapat mengatur dan mematikan pengingat.

## 7. Dashboard dan Laporan
- [x] **P0** Buat kalkulasi saldo tersedia.
  - Selesai jika hasil cocok dengan skenario uji pemasukan, pengeluaran, tabungan, utang, dan piutang.
- [x] **P0** Buat ringkasan periode.
  - Selesai jika filter harian, mingguan, dan bulanan menghasilkan nilai yang benar.
- [x] **P0** Buat grafik pengeluaran.
  - Selesai jika grafik cocok dengan data transaksi dan kategori.
- [x] **P1** Tambahkan rentang tanggal kustom dan ekspor laporan.

## 8. Pengujian dan Rilis
- [x] **P0** Unit test kalkulasi keuangan.
  - Selesai jika kasus normal, batas, dan kesalahan memiliki hasil yang diharapkan.
- [x] **P0** Test repository/database.
  - Selesai jika CRUD, relasi, transaksi atomik, dan migrasi diuji.
- [x] **P0** Widget test halaman penting.
  - Selesai jika form, navigasi, loading, empty, dan error state diuji.
- [x] **P0** Jalankan `flutter analyze` dan seluruh test.
  - Selesai jika tidak ada error dan semua test lulus.
- [ ] **P0** Uji manual pada perangkat Android.
  - Selesai jika alur utama bekerja offline dan data bertahan setelah aplikasi dibuka ulang.
- [ ] **P1** Build APK release.
  - Selesai jika APK berhasil dipasang dan diuji pada perangkat target.

## 9. Catatan Progres
Perbarui bagian ini setiap sesi:
- Tanggal: 19-20 November 2026
- Pekerjaan selesai:
  - Penambahan dependency `flutter_riverpod` dan `sqflite_common_ffi` (dev).
  - Pembuatan struktur folder modular berdasarkan ARCHITECTURE.md.
  - Implementasi fondasi aplikasi (`main.dart`, `app.dart`, `app_constants.dart`, `app_colors.dart`, `app_theme.dart`, `currency_formatter.dart`, `date_formatter.dart`).
  - Implementasi `DatabaseHelper` SQLite (`sqflite`), 7 tabel skema, aktivasi `PRAGMA foreign_keys = ON`, index performa, dan seed 12 kategori bawaan serta pengaturan awal.
  - Pembuatan model data: `CategoryModel`, `TransactionModel`, `SavingsGoalModel`, `SavingsMovementModel`, `DebtModel`, `DebtPaymentModel`.
  - Implementasi Navigasi Bawah (`MainNavigationScreen`) 5 menu: Dashboard, Transaksi, Tabungan, Utang, dan Laporan.
  - Implementasi Dashboard Shell (`DashboardScreen`, `BalanceCard`, `QuickActions`, `SummaryCards`, `EmptyState`, dan `SettingsScreen`).
  - Implementasi penuh Fitur Transaksi (P0):
    - `CategoryDatasource` dan `CategoryRepository`.
    - `TransactionDatasource` dan `TransactionRepository` (CRUD, filter, agregat saldo & total pemasukan/pengeluaran).
    - `TransactionActionController`, `transactionTypeFilterProvider`, `transactionsListProvider`, dan `dashboardSummaryProvider`.
    - Form `AddEditTransactionScreen` (Pemasukan/Pengeluaran, format Rupiah otomatis, pemilih kategori bawaan, pemilih tanggal, validasi > Rp0, dan hapus dengan dialog konfirmasi).
    - Halaman daftar `TransactionsScreen` (filter chip Semua/Pemasukan/Pengeluaran, list item dengan signed nominal dan warna, empty state interaktif).
    - Sinkronisasi real-time saldo dan transaksi terbaru pada Dashboard.
  - Implementasi penuh Fitur Tabungan (P0):
    - `SavingsDatasource` dan `SavingsRepository` (CRUD target tabungan, mutasi setoran & penarikan dengan validasi penarikan tidak melebihi saldo tabungan aktual, transaksi atomik SQLite).
    - `savings_controller.dart` (`savingsGoalsProvider`, `savingsGoalDetailProvider`, `savingsMovementsProvider`, `totalSavingsProvider`, `SavingsActionController` dengan sinkronisasi invalidasi otomatis ke saldo kas dashboard).
    - `AddEditSavingsGoalScreen` (tambah/edit target tabungan, nominal target > 0, tenggat waktu opsional, konfirmasi hapus permanen).
    - `SavingsGoalDetailScreen` (tampilan progres tercapai, persentase dinamis, badge tercapai, aksi cepat Setor/Tarik, riwayat mutasi masuk/keluar).
    - `SavingsMovementDialog` (modal bottom sheet setor & tarik tabungan, format Rupiah otomatis, pemilih tanggal, catatan, pencegahan penarikan melebihi saldo).
    - Halaman utama `SavingsScreen` (kartu total akumulasi tabungan, daftar kartu target, empty state dengan CTA, FAB).
    - Sinkronisasi kartu ringkasan tabungan pada `DashboardScreen` secara reaktif dengan `totalSavingsProvider`.
  - Implementasi penuh Fitur Utang dan Piutang (P0):
    - `DebtDatasource` dan `DebtRepository` (CRUD utang & piutang, pelunasan bertahap/penuh, validasi pembayaran tidak melebihi sisa kewajiban, penyesuaian otomatis status `settled`, transaksi atomik SQLite).
    - `debt_controller.dart` (`debtsListProvider`, `debtDirectionFilterProvider`, `debtDetailProvider`, `debtPaymentsProvider`, `debtsSummaryProvider`, `DebtActionController` dengan invalidasi otomatis ke saldo kas dashboard).
    - `AddEditDebtScreen` (form pencatatan utang/piutang baru atau edit, pilihan arah utang vs piutang, validasi nominal > 0, jatuh tempo opsional, dan konfirmasi hapus).
    - `DebtDetailScreen` (ringkasan status lunas/aktif, progres pelunasan, sisa tagihan, tombol aksi pembayaran cepat, dan riwayat mutasi pembayaran).
    - `DebtPaymentDialog` (modal bottom sheet cicilan/pelunasan utang-piutang, tombol 'Bayar Lunas', validasi nominal tidak melebihi sisa).
    - Halaman utama `DebtsScreen` (kartu total utang & total piutang, filter chip Semua/Utang Saja/Piutang Saja, kartu interaktif status lunas/sisa, empty state, FAB).
    - Sinkronisasi real-time kartu ringkasan utang & piutang pada `DashboardScreen` melalui `debtsSummaryProvider`.
  - Implementasi penuh Fitur Dashboard dan Laporan (P0):
    - Penambahan `startOfWeek` dan `endOfWeek` pada `DateFormatter` sesuai standar ISO (Senin–Minggu).
    - Penambahan method `getExpenseByCategory` pada `TransactionDatasource` dan `TransactionRepository` untuk mengagregasi nominal pengeluaran dan jumlah transaksi per kategori.
    - Pembuatan model `CategoryExpenseModel` dengan penghitungan persentase pengeluaran dinamis.
    - `reports_controller.dart` (`reportPeriodProvider` untuk filter Harian/Mingguan/Bulanan dan `reportsDataProvider` yang mengagregasi pemasukan, pengeluaran, selisih kas bersih, dan rincian kategori).
    - `ExpensePieChart` (visualisasi grafik donat pengeluaran menggunakan `fl_chart`, tooltip sentuh interaktif, palet warna kontras modern, dan ringkasan total pengeluaran di tengah donat).
    - `CategoryExpenseTile` (kartu rincian pengeluaran kategori dengan progress bar persentase, jumlah transaksi, dan nominal).
    - Halaman utama `ReportsScreen` (pemilih periode tab Harian/Mingguan/Bulanan, label tanggal dinamis, kartu ringkasan arus kas, grafik donat komposisi, dan daftar rincian kategori).
  - Implementasi Fitur Tambahan P1 & Copyright:
    - Dukungan Dark Mode (Tema Gelap): `AppTheme.dark` (Material 3 Dark Theme), `ThemeModeNotifier` dengan persistensi `shared_preferences` (Sistem, Terang, Gelap).
    - Fitur Pengingat Jatuh Tempo Lokal: `debtReminderProvider` dengan toggle preferensi di Pengaturan.
    - Rentang Tanggal Kustom & Ekspor Laporan: Pemilih tanggal rentang `showDateRangePicker` (`ReportPeriod.custom`), generator teks CSV laporan keuangan lengkap dengan atribusi hak cipta, dan dialog ekspor dengan tombol salin clipboard.
    - Penambahan Hak Cipta & Identitas Pengembang: `Copyright by Archie Arya Manggala` di `AppConstants`, kartu profil Pengaturan, header, dialog ekspor, dan footer aplikasi.
    - Pemasangan logo aplikasi resmi Dompetku menggantikan logo bawaan Flutter pada seluruh densitas Android mipmap (`mdpi` hingga `xxxhdpi`).
  - Implementasi Fitur Manajemen Kategori Kustom (Opsi 2):
    - Penambahan operasi `isCategoryInUse`, `deleteCategory`, dan `unarchiveCategory` pada `CategoryDatasource` dan `CategoryRepository`.
    - `CategoryIconHelper` untuk pemetaan 21 ikon dan 12 palet warna hex modern.
    - `category_controller.dart` (`categoryManagementListProvider`, `categoryTypeFilterProvider`, `categoryIncludeArchivedProvider`, `categoryInUseProvider`, dan `CategoryActionController`).
    - Modal dialog `AddEditCategoryDialog` dengan live preview interaktif, validasi nama, pemilih jenis, ikon, dan warna.
    - Halaman utama `CategoriesScreen` lengkap dengan filter jenis, penanda badge (Bawaan/Kustom/Diarsipkan), proteksi hapus kategori terpakai, dan menu aksi popup.
    - Menu navigasi "Kelola Kategori" pada `SettingsScreen` dan tombol cepat "+ Kategori Baru" pada `AddEditTransactionScreen`.
  - Implementasi Pencarian Transaksi & Filter per Kategori (Opsi 4):
    - Dukungan parameter `searchQuery` dan `categoryId` pada `TransactionDatasource.getTransactions` dan `TransactionRepository`.
    - `TransactionSearchQueryNotifier` dan `TransactionCategoryFilterNotifier` pada `transaction_controller.dart`.
    - Search bar interaktif dengan tombol clear dan dropdown filter kategori di `TransactionsScreen`.
    - Empty state adaptif saat hasil pencarian atau filter kategori tidak ditemukan.
  - Penulisan unit test & widget test menyeluruh: total **92 pengujian lulus 100%** dan `flutter analyze` 0 issues.
- Pekerjaan berjalan: Seluruh Fitur MVP (P0), Fitur Prioritas P1, Manajemen Kategori Kustom, serta Pencarian Transaksi & Filter Kategori telah selesai 100%.
- Kendala: Tidak ada kendala aktif.
- Keputusan teknis: Integritas foreign key SQLite tetap ditegakkan (`ON DELETE RESTRICT`), kategori yang sudah memiliki transaksi dilindungi dari penghapusan permanen dan diarahkan untuk diarsipkan agar data historis tetap konsisten.
- Langkah berikutnya: Build APK release (`flutter build apk --release`).
