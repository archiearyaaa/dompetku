# SKILL.md — Reusable Prompt Library

Kumpulan prompt yang dapat digunakan ulang saat mengembangkan Dompetku. Sesuaikan nama file, fitur, dan konteks dengan kondisi repository terbaru.

## 1. Implementasi Fitur
```text
Baca PRD.md, ARCHITECTURE.md, AGENTS.md, WORKFLOW.md, dan TODO.md.
Implementasikan fitur [NAMA FITUR] sesuai ruang lingkup MVP.
Periksa kode yang sudah ada sebelum membuat file baru.
Ikuti arsitektur dan aturan bisnis keuangan.
Tambahkan validasi, loading/empty/error state, serta test yang relevan.
Jangan mengubah skema database atau menambah dependensi tanpa menjelaskan dampaknya dan meminta izin jika diwajibkan.
Jalankan dart format, flutter analyze, dan test terkait.
Laporkan file yang berubah, hasil test, risiko, dan status TODO.
```

## 2. Testing
```text
Tinjau fitur [NAMA FITUR] pada Dompetku.
Buat rencana test berdasarkan kriteria penerimaan.
Uji kondisi normal, input kosong, nominal nol/negatif, nominal besar,
tanggal batas, data kosong, error database, dan persistensi.
Untuk kalkulasi keuangan, verifikasi saldo sebelum dan sesudah operasi.
Jalankan test dan laporkan hasil aktual. Jangan mengklaim lulus jika belum dijalankan.
```

## 3. Debugging
```text
Bantu debug masalah berikut: [DESKRIPSI ERROR].
Periksa stack trace, file terkait, dan alur data sebelum mengubah kode.
Identifikasi akar masalah, bukan hanya menyembunyikan gejala.
Usulkan perbaikan terkecil yang aman.
Jangan menghapus database atau data pengguna.
Tambahkan regression test agar bug tidak terulang.
Jalankan analyzer dan test terkait, lalu jelaskan penyebab dan perbaikannya.
```

## 4. Refactoring
```text
Tinjau [FILE/MODUL] untuk peluang refactoring.
Pertahankan perilaku dan API yang sudah digunakan.
Hindari perubahan aturan bisnis dan skema database.
Kurangi duplikasi, perjelas penamaan, dan jaga pemisahan UI/domain/data.
Buat perubahan bertahap dan tambahkan test bila diperlukan.
Laporkan manfaat, risiko, dan hasil verifikasi.
```

## 5. Review Keamanan dan Privasi
```text
Lakukan review keamanan pada perubahan Dompetku.
Periksa validasi input, parameterized SQL, foreign key, izin Android,
penanganan error, logging data pribadi, penyimpanan rahasia, dan akses jaringan.
Pastikan data keuangan tidak dikirim ke layanan eksternal tanpa persetujuan.
Jangan mengklaim enkripsi atau perlindungan yang belum diterapkan.
Kelompokkan temuan berdasarkan tingkat risiko dan berikan rekomendasi.
```

## 6. Review Konsistensi Keuangan
```text
Audit kalkulasi saldo Dompetku.
Periksa pemasukan, pengeluaran, setoran/penarikan tabungan,
utang diterima/dibayar, piutang diberikan/diterima, edit, dan hapus.
Pastikan penerimaan utang bukan pendapatan dan setoran tabungan bukan
pengeluaran konsumsi.
Buat tabel skenario dengan saldo awal, aktivitas, dampak, dan saldo akhir.
Tambahkan test untuk setiap skenario yang belum tercakup.
```

## 7. Optimasi Performa
```text
Tinjau performa [HALAMAN/QUERY] pada Dompetku.
Cari rebuild widget berlebihan, query berulang, operasi sinkron yang berat,
pemrosesan data besar di UI thread, dan query tanpa index yang sesuai.
Ukur atau jelaskan bukti masalah sebelum mengoptimasi.
Pertahankan akurasi kalkulasi dan konsistensi database.
Jalankan test setelah perubahan dan laporkan dampaknya.
```

## 8. Review Sebelum Merge
```text
Lakukan final review terhadap perubahan saat ini.
Baca git diff dan periksa kesesuaian dengan PRD, ARCHITECTURE, AGENTS,
WORKFLOW, dan kriteria TODO.
Cari bug, regresi, risiko kehilangan data, masalah aksesibilitas,
dan test yang belum tersedia.
Jangan mengubah file kecuali diminta.
Berikan temuan berdasarkan prioritas dan rekomendasi keputusan merge.
```
