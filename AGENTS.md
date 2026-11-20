# AGENTS.md — AI Coding Instructions

Dokumen ini berisi aturan wajib bagi AI coding agent yang bekerja pada Dompetku.

## 1. Konteks Proyek
- Nama: Dompetku.
- Platform MVP: Android.
- Framework: Flutter, bahasa Dart.
- Penyimpanan utama: SQLite lokal melalui `sqflite`.
- Aplikasi harus berfungsi offline.
- Bahasa UI: Indonesia.
- Mata uang: Rupiah (IDR).
- Desain: modern minimalis.

Baca `PRD.md`, `ARCHITECTURE.md`, `TODO.md`, dan `WORKFLOW.md` sebelum melakukan perubahan yang berdampak pada produk atau arsitektur.

## 2. Aturan Umum Coding
1. Ikuti struktur dan batas tanggung jawab pada `ARCHITECTURE.md`.
2. Gunakan null safety dan tipe data yang jelas.
3. Utamakan kode sederhana, mudah dibaca, dan mudah diuji.
4. Hindari duplikasi logika bisnis.
5. Jangan menaruh query SQL langsung di widget atau screen.
6. Jangan menambahkan dependensi tanpa alasan dan persetujuan sesuai `WORKFLOW.md`.
7. Jangan mengubah fitur di luar ruang lingkup tugas tanpa menjelaskan alasannya.
8. Pertahankan kompatibilitas dengan data pengguna yang sudah ada.

## 3. Aturan Keuangan
- Nominal uang disimpan sebagai integer Rupiah, bukan `double`.
- Nominal transaksi harus positif; jenis transaksi menentukan arah dampak.
- Hindari perhitungan uang menggunakan floating point.
- Pisahkan pendapatan/pengeluaran dari perpindahan aset dan pencatatan kewajiban.
- Penerimaan utang bukan pemasukan pendapatan.
- Pembayaran pokok utang bukan pengeluaran konsumsi.
- Setoran tabungan bukan pengeluaran konsumsi.
- Pastikan semua kalkulasi saldo, tabungan, utang, piutang, dan laporan memakai aturan yang sama.
- Operasi yang mengubah beberapa tabel harus menggunakan transaksi SQLite.
- Jangan memperbarui angka ringkasan secara terpisah jika angka tersebut dapat dihitung dari data sumber.

## 4. Aturan Database
1. Semua query menggunakan parameter binding; jangan menyusun SQL dari input pengguna.
2. Gunakan foreign key dan index yang sesuai.
3. Setiap perubahan skema wajib menaikkan versi database dan menyediakan migrasi.
4. Jangan menghapus database, tabel, atau data pengguna untuk menyelesaikan bug.
5. Jangan mengubah nama/tipe kolom tanpa migrasi yang aman.
6. Operasi multi-tabel harus atomik menggunakan transaksi database.
7. Tangani error database dan tampilkan pesan yang ramah pada UI.
8. Gunakan timestamp yang konsisten dan dokumentasikan formatnya.
9. Uji migrasi dari skema lama, bukan hanya instalasi baru.

## 5. Aturan UI/UX
- Gunakan tema dan komponen bersama.
- Format nominal dengan pemisah ribuan dan awalan `Rp`.
- Form harus memiliki label, validasi, dan pesan error yang jelas.
- Sediakan loading, empty, success, dan error state yang relevan.
- Minta konfirmasi untuk tindakan destruktif seperti menghapus data.
- Hindari teks yang terlalu kecil dan kontrol yang sulit disentuh.
- Jangan menampilkan data contoh seolah-olah merupakan data transaksi nyata.

## 6. Keamanan dan Privasi
- Jangan menambahkan telemetry atau mengirim data ke jaringan tanpa persetujuan eksplisit.
- Jangan mencatat nominal, nama pihak, atau catatan keuangan pribadi ke log produksi.
- Jangan menyimpan kredensial, PIN, atau rahasia di source code.
- Validasi input sebelum disimpan.
- Jangan mengklaim database terenkripsi jika enkripsi belum diterapkan dan diuji.

## 7. Testing
- Tambahkan atau perbarui test untuk setiap perubahan logika bisnis.
- Uji kasus nominal nol, negatif, sangat besar, dan pembayaran melebihi sisa.
- Uji saldo setelah tambah, edit, dan hapus transaksi.
- Uji transaksi tabungan, utang, dan piutang.
- Uji persistensi setelah aplikasi ditutup dan dibuka kembali.
- Jalankan `dart format`, `flutter analyze`, dan test terkait sebelum menyatakan selesai.

## 8. Output Setiap Pekerjaan
Setelah menyelesaikan tugas, laporkan:
1. Ringkasan perubahan.
2. File yang dibuat/diubah.
3. Dependensi atau migrasi database (jika ada).
4. Test yang dijalankan dan hasilnya.
5. Hal yang belum selesai atau risiko.
6. Langkah berikutnya.

Jangan mengklaim test berhasil jika test belum benar-benar dijalankan.
