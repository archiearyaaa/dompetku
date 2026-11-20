# Product Requirements Document (PRD)
## Dompetku — Personal Finance Management

- **Versi:** 1.0
- **Status:** Draft awal untuk MVP
- **Platform:** Android
- **Framework:** Flutter (Dart)
- **Penyimpanan:** SQLite lokal, offline-first
- **Mata uang utama:** Rupiah (IDR)

## 1. Ringkasan Produk
Dompetku adalah aplikasi Android untuk membantu individu mencatat dan memantau keuangan pribadi. Pengguna dapat mengelola pemasukan, pengeluaran, tabungan, utang, dan piutang dalam satu aplikasi yang dapat digunakan tanpa koneksi internet.

## 2. Tujuan Aplikasi
1. Memudahkan pencatatan pemasukan dan pengeluaran harian.
2. Memberikan gambaran saldo dan kondisi keuangan secara jelas.
3. Membantu pengguna menetapkan serta memantau target tabungan.
4. Membantu pengguna mencatat utang, piutang, dan pembayarannya.
5. Menyediakan laporan keuangan berdasarkan periode dan kategori.
6. Menyimpan data secara lokal agar aplikasi tetap berfungsi secara offline.

## 3. Masalah yang Diselesaikan
- Pengeluaran kecil sehari-hari sering terlupakan atau tidak tercatat.
- Pengguna kesulitan mengetahui total pengeluaran dalam satu periode.
- Catatan pemasukan, tabungan, utang, dan piutang tersebar di beberapa tempat.
- Pengguna tidak memiliki ringkasan saldo dan kebiasaan belanja yang mudah dibaca.
- Aplikasi yang membutuhkan internet tidak selalu dapat digunakan dalam semua kondisi.

## 4. Target Pengguna
- Individu yang ingin mengatur keuangan pribadi.
- Mahasiswa atau pekerja yang memiliki pemasukan dan pengeluaran rutin.
- Pengguna Android yang membutuhkan pencatatan sederhana dan offline.
- Pengguna yang ingin memantau tabungan, utang, dan piutang pribadi.

## 5. Platform dan Prinsip Produk
- Android sebagai platform rilis MVP.
- Antarmuka berbahasa Indonesia.
- Format mata uang Rupiah.
- Desain modern, minimalis, mudah dipahami.
- Offline-first: data utama disimpan di perangkat.
- Tidak memerlukan akun atau server untuk fungsi inti MVP.

## 6. Fitur Utama

### 6.1 Dashboard
- Menampilkan saldo tersedia.
- Menampilkan total pemasukan dan pengeluaran dalam periode terpilih.
- Menampilkan ringkasan tabungan serta kewajiban/piutang.
- Menampilkan beberapa transaksi terbaru.
- Menyediakan akses cepat untuk menambah transaksi.

### 6.2 Transaksi
- Membuat, membaca, mengubah, dan menghapus transaksi.
- Jenis transaksi: pemasukan dan pengeluaran.
- Data transaksi: nominal, kategori, tanggal, catatan opsional.
- Filter berdasarkan periode, jenis, dan kategori.
- Validasi nominal harus lebih besar dari nol.

### 6.3 Kategori
- Kategori bawaan untuk pemasukan dan pengeluaran.
- Menambah, mengubah, dan mengarsipkan kategori buatan pengguna.
- Kategori memiliki nama, jenis, dan ikon/warna opsional.
- Kategori yang sudah dipakai tidak dihapus secara permanen tanpa aturan migrasi data yang aman.

### 6.4 Tabungan
- Membuat target tabungan dengan nama, target nominal, dan tanggal target opsional.
- Mencatat setoran dan penarikan.
- Menampilkan saldo tabungan dan persentase progres.
- Menjaga agar alokasi tabungan tidak dihitung sebagai pengeluaran konsumsi.
- Perpindahan uang ke/dari tabungan harus tercermin konsisten pada saldo tersedia dan saldo tabungan.

### 6.5 Utang dan Piutang
- Mencatat uang yang dipinjam pengguna (utang) dan uang yang dipinjamkan (piutang).
- Data: pihak terkait, nominal awal, tanggal, jatuh tempo opsional, catatan, dan status.
- Mencatat pembayaran atau penerimaan sebagian/seluruhnya.
- Menampilkan sisa nominal dan riwayat pembayaran.
- Transaksi pembayaran harus tercermin pada saldo dengan arah yang benar.

### 6.6 Laporan
- Ringkasan pemasukan dan pengeluaran berdasarkan hari, minggu, dan bulan.
- Grafik tren pengeluaran.
- Ringkasan pengeluaran per kategori.
- Filter rentang tanggal.
- Laporan dihitung dari data transaksi, bukan angka ringkasan yang disimpan terpisah.

### 6.7 Pengaturan
- Preferensi sederhana seperti tema dan format tampilan.
- Pengaturan kategori.
- Informasi aplikasi dan versi database.
- Fitur ekspor/cadangan dapat dipertimbangkan setelah MVP.

## 7. MVP (Minimum Viable Product)
MVP mencakup:
1. Inisialisasi aplikasi dan database SQLite.
2. Dashboard dengan ringkasan saldo, pemasukan, pengeluaran, dan transaksi terbaru.
3. CRUD transaksi pemasukan dan pengeluaran.
4. Kategori transaksi bawaan dan kategori pengguna dasar.
5. Pencatatan target tabungan, setoran, dan penarikan.
6. Pencatatan utang/piutang dan pembayaran.
7. Laporan ringkas bulanan dan kategori.
8. Validasi input, penanganan error, dan pengujian dasar.

### Di luar MVP
- Login, sinkronisasi cloud, dan multi-perangkat.
- Integrasi bank, e-wallet, atau open banking.
- OCR struk otomatis.
- Impor transaksi otomatis dari SMS/notifikasi.
- Berbagi akun atau kolaborasi keluarga.
- Notifikasi terjadwal kompleks.
- Versi iOS dan web.
- Analitik prediktif atau rekomendasi berbasis AI.

## 8. Aturan Bisnis dan Definisi Keuangan
- **Saldo tersedia** = total pemasukan kas + penerimaan piutang - pengeluaran kas - pembayaran utang - alokasi bersih ke tabungan, dengan perlakuan transfer yang konsisten.
- Tabungan adalah alokasi aset milik pengguna, bukan pengeluaran konsumsi.
- Setoran tabungan mengurangi saldo tersedia dan menambah saldo tabungan; penarikan melakukan kebalikannya.
- Utang yang diterima menambah kas dan kewajiban; pembayaran utang mengurangi kas dan kewajiban.
- Piutang yang diberikan mengurangi kas dan menambah piutang; penerimaan pembayaran piutang menambah kas dan mengurangi piutang.
- Jangan menghitung penerimaan utang sebagai pemasukan pendapatan.
- Jangan menghitung pembayaran pokok utang sebagai pengeluaran konsumsi pada laporan pengeluaran. Jika bunga/biaya dicatat, komponen tersebut dapat diklasifikasikan sebagai pengeluaran.
- Semua nominal disimpan sebagai integer Rupiah untuk menghindari kesalahan floating point.
- Waktu transaksi disimpan dengan format yang konsisten; tampilkan sesuai zona waktu perangkat.

## 9. Kriteria Penerimaan Produk
- Pengguna dapat mencatat transaksi tanpa internet.
- Data tetap tersedia setelah aplikasi ditutup dan dibuka kembali.
- Ringkasan dashboard sesuai dengan transaksi dan mutasi terkait.
- Setoran/penarikan tabungan dan pembayaran utang/piutang memperbarui saldo secara benar.
- Input nominal tidak valid ditolak dengan pesan yang jelas.
- Penghapusan atau perubahan data tidak meninggalkan saldo yang tidak konsisten.
- Aplikasi dapat dijalankan pada perangkat Android yang didukung.

## 10. Batasan dan Asumsi
- Data hanya tersimpan di perangkat pada MVP; kehilangan atau penghapusan data aplikasi dapat menghilangkan data jika belum dicadangkan.
- SQLite bukan layanan sinkronisasi.
- Pengguna bertanggung jawab atas kebenaran data yang dimasukkan.
- Dompetku bukan aplikasi perbankan, pemberi pinjaman, atau penasihat keuangan.
- Versi Android minimum ditentukan berdasarkan konfigurasi Flutter dan dependensi saat implementasi.
