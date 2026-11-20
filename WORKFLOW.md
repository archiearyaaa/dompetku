# WORKFLOW.md — Development Workflow

## 1. Tujuan
Menetapkan alur kerja pengembangan Dompetku agar perubahan terkontrol, dapat ditinjau, dan tidak merusak data keuangan pengguna.

## 2. Urutan Kerja
1. Baca dokumen proyek yang relevan.
2. Pahami kebutuhan dan kriteria penerimaan pada `TODO.md`/`PRD.md`.
3. Periksa struktur kode dan test yang sudah ada.
4. Buat rencana singkat sebelum perubahan lintas file atau perubahan arsitektur.
5. Implementasikan dalam unit perubahan kecil.
6. Jalankan formatter, analyzer, dan test yang relevan.
7. Periksa dampak terhadap database dan fitur lain.
8. Perbarui `TODO.md` dan dokumentasi bila diperlukan.
9. Laporkan hasil secara jujur.

## 3. AI Boleh Bekerja Mandiri
AI boleh melakukan hal berikut selama masih sesuai kebutuhan yang disepakati:
- Membaca dan menjelaskan kode proyek.
- Membuat atau memperbaiki widget dan file internal dalam ruang lingkup fitur.
- Menambahkan unit/widget test.
- Memperbaiki bug yang jelas dan dapat direproduksi.
- Merapikan kode tanpa mengubah perilaku publik.
- Menjalankan formatter, analyzer, dan test.
- Memperbarui dokumentasi teknis yang mengikuti implementasi aktual.

## 4. AI Wajib Meminta Izin Sebelum
- Menghapus data pengguna, database, tabel, atau file penting.
- Melakukan reset database atau migrasi yang berisiko kehilangan data.
- Mengubah aturan perhitungan saldo atau definisi transaksi yang sudah disepakati.
- Menambahkan layanan cloud, login, analytics, iklan, atau komunikasi jaringan.
- Menambahkan dependensi besar atau berbayar yang mengubah arsitektur.
- Mengubah application ID, signing/release configuration, atau identitas aplikasi.
- Mengubah cakupan MVP atau menambahkan fitur besar di luar PRD.
- Menjalankan tindakan yang memerlukan kredensial, akses akun, atau biaya.
- Mengganti state management atau pola arsitektur yang sudah dikunci.

Jika ditemukan risiko kehilangan data atau ketidaksesuaian aturan keuangan, hentikan perubahan terkait dan jelaskan pilihan yang tersedia.

## 5. Standar Penyelesaian Fitur
Fitur hanya boleh ditandai selesai jika:
- Semua kriteria penerimaan fitur terpenuhi.
- UI memiliki loading, empty, dan error state yang sesuai.
- Validasi input diterapkan.
- Data tersimpan dan terbaca kembali dengan benar.
- Perhitungan saldo konsisten.
- Test yang relevan lulus.
- `flutter analyze` tidak menghasilkan error baru.
- Tidak ada perubahan tak sengaja pada fitur lain.
- Dokumentasi dan `TODO.md` diperbarui.

## 6. Aturan Database dan Migrasi
- Jangan mengubah skema tanpa menaikkan versi database.
- Buat migrasi yang mempertahankan data lama.
- Uji migrasi menggunakan database versi sebelumnya.
- Backup data sebelum operasi yang berpotensi destruktif jika mekanisme backup tersedia.
- Jangan menggunakan penghapusan database sebagai solusi bug rutin.
- Operasi yang menyentuh beberapa tabel harus atomik.

## 7. Prosedur Testing Minimal
Jalankan sesuai lingkup perubahan:

```bash
dart format .
flutter analyze
flutter test
```

Untuk perubahan database, tambahkan test CRUD, foreign key, transaksi atomik, dan migrasi. Untuk perubahan UI, tambahkan widget test atau lakukan pengujian manual pada perangkat Android.

## 8. Alur Git yang Disarankan
- Gunakan branch fitur untuk pekerjaan yang cukup besar.
- Buat commit kecil dengan pesan yang menjelaskan perubahan.
- Jangan memasukkan file rahasia atau data keuangan pribadi ke repository.
- Jangan force-push atau menghapus branch bersama tanpa izin.
- Periksa `git diff` sebelum commit.

Contoh nama branch:
- `feature/transaction-crud`
- `feature/savings-goals`
- `fix/balance-calculation`
- `test/database-migrations`

## 9. Format Laporan Sesi
```text
Pekerjaan:
Perubahan file:
Hasil test:
Status TODO:
Risiko/kendala:
Langkah berikutnya:
```
