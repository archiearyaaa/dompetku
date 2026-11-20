/// Konstanta aplikasi Dompetku.
///
/// Berisi nama aplikasi, versi, dan nilai-nilai tetap
/// yang digunakan di banyak tempat.
class AppConstants {
  AppConstants._();

  // ── Identitas Aplikasi ─────────────────────────────────
  static const String appName = 'Dompetku';
  static const String appVersion = '1.0.0';
  static const String appAuthor = 'Archie Arya Manggala';
  static const String copyright = 'Copyright © 2026 Archie Arya Manggala';

  // ── Database ───────────────────────────────────────────
  static const String databaseName = 'dompetku.db';
  static const int databaseVersion = 1;

  // ── Format ─────────────────────────────────────────────
  /// Locale Indonesia untuk format tanggal dan angka.
  static const String localeId = 'id_ID';

  /// Simbol mata uang.
  static const String currencySymbol = 'Rp';

  /// Format waktu yang disimpan di database (ISO-8601).
  static const String dbDateTimeFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS";

  /// Format tanggal yang ditampilkan di UI.
  static const String displayDateFormat = 'dd MMMM yyyy';

  /// Format tanggal pendek.
  static const String shortDateFormat = 'dd MMM yyyy';

  /// Format tanggal dengan waktu.
  static const String displayDateTimeFormat = 'dd MMM yyyy, HH:mm';

  // ── UI ─────────────────────────────────────────────────
  /// Padding horizontal standar halaman.
  static const double pagePaddingH = 16.0;

  /// Padding vertikal standar halaman.
  static const double pagePaddingV = 16.0;

  /// Radius border standar untuk card dan container.
  static const double borderRadius = 12.0;

  /// Durasi animasi standar dalam milidetik.
  static const int animationDurationMs = 300;
}
