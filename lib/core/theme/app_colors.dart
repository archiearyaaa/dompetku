import 'package:flutter/material.dart';

/// Palet warna identitas visual Dompetku.
///
/// Semua warna semantik didefinisikan di sini agar konsisten
/// di seluruh aplikasi. Jangan gunakan warna literal di widget;
/// gunakan konstanta dari kelas ini atau dari [Theme].
class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────
  /// Midnight Navy — warna utama aplikasi.
  static const Color primary = Color(0xFF142D4E);

  /// Blue — warna sekunder / aksen.
  static const Color secondary = Color(0xFF2878D0);

  // ── Background & Surface ───────────────────────────────
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F2F5);

  // ── Teks ───────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // ── Semantik Keuangan ──────────────────────────────────
  /// Hijau — pemasukan / sukses.
  static const Color income = Color(0xFF22C55E);

  /// Merah — pengeluaran / error.
  static const Color expense = Color(0xFFEF4444);

  /// Alias untuk kejelasan konteks.
  static const Color success = income;
  static const Color error = expense;

  /// Kuning — peringatan.
  static const Color warning = Color(0xFFF59E0B);

  /// Biru info — informasi umum.
  static const Color info = secondary;

  // ── Komponen ───────────────────────────────────────────
  static const Color divider = Color(0xFFE5E7EB);
  static const Color border = Color(0xFFD1D5DB);
  static const Color disabled = Color(0xFF9CA3AF);
  static const Color cardShadow = Color(0x1A000000);

  // ── Navigasi ───────────────────────────────────────────
  static const Color navBarBackground = surface;
  static const Color navBarSelected = primary;
  static const Color navBarUnselected = Color(0xFF9CA3AF);
}
