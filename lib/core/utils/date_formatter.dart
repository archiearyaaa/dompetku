import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// Utilitas format tanggal dan waktu untuk Dompetku.
///
/// Semua tanggal di database disimpan dalam format ISO-8601 (string).
/// Kelas ini menyediakan konversi antara [DateTime], string database,
/// dan string tampilan UI berbahasa Indonesia.
class DateFormatter {
  DateFormatter._();

  // ── Formatter ──────────────────────────────────────────
  static final DateFormat _dbFormat = DateFormat(AppConstants.dbDateTimeFormat);

  static final DateFormat _displayDate = DateFormat(
    AppConstants.displayDateFormat,
    AppConstants.localeId,
  );

  static final DateFormat _shortDate = DateFormat(
    AppConstants.shortDateFormat,
    AppConstants.localeId,
  );

  static final DateFormat _displayDateTime = DateFormat(
    AppConstants.displayDateTimeFormat,
    AppConstants.localeId,
  );

  static final DateFormat _monthYear = DateFormat(
    'MMMM yyyy',
    AppConstants.localeId,
  );

  static final DateFormat _dayMonth = DateFormat(
    'dd MMM',
    AppConstants.localeId,
  );

  // ── Database ↔ DateTime ────────────────────────────────

  /// Mengubah [DateTime] menjadi string ISO-8601 untuk disimpan di database.
  static String toDbString(DateTime dateTime) {
    return _dbFormat.format(dateTime);
  }

  /// Mengubah string ISO-8601 dari database menjadi [DateTime].
  ///
  /// Mengembalikan `null` jika format tidak valid.
  static DateTime? fromDbString(String? dbString) {
    if (dbString == null || dbString.isEmpty) return null;
    try {
      return _dbFormat.parse(dbString);
    } on FormatException {
      // Fallback: coba parse ISO-8601 standar.
      return DateTime.tryParse(dbString);
    }
  }

  // ── Tampilan UI ────────────────────────────────────────

  /// Format tanggal lengkap: `19 November 2026`.
  static String formatDisplay(DateTime dateTime) {
    return _displayDate.format(dateTime);
  }

  /// Format tanggal pendek: `19 Nov 2026`.
  static String formatShort(DateTime dateTime) {
    return _shortDate.format(dateTime);
  }

  /// Format tanggal dengan waktu: `19 Nov 2026, 23:00`.
  static String formatDateTime(DateTime dateTime) {
    return _displayDateTime.format(dateTime);
  }

  /// Format bulan dan tahun: `November 2026`.
  static String formatMonthYear(DateTime dateTime) {
    return _monthYear.format(dateTime);
  }

  /// Format hari dan bulan pendek: `19 Nov`.
  static String formatDayMonth(DateTime dateTime) {
    return _dayMonth.format(dateTime);
  }

  // ── Utilitas ───────────────────────────────────────────

  /// Mengembalikan [DateTime] untuk awal hari (00:00:00).
  static DateTime startOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Mengembalikan [DateTime] untuk akhir hari (23:59:59.999).
  static DateTime endOfDay(DateTime dateTime) {
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      23,
      59,
      59,
      999,
    );
  }

  /// Mengembalikan [DateTime] untuk awal minggu (Senin 00:00:00).
  static DateTime startOfWeek(DateTime dateTime) {
    final diff = dateTime.weekday - 1;
    final monday = dateTime.subtract(Duration(days: diff));
    return startOfDay(monday);
  }

  /// Mengembalikan [DateTime] untuk akhir minggu (Minggu 23:59:59.999).
  static DateTime endOfWeek(DateTime dateTime) {
    final diff = 7 - dateTime.weekday;
    final sunday = dateTime.add(Duration(days: diff));
    return endOfDay(sunday);
  }

  /// Mengembalikan [DateTime] untuk awal bulan.
  static DateTime startOfMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month);
  }

  /// Mengembalikan [DateTime] untuk akhir bulan.
  static DateTime endOfMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month + 1, 0, 23, 59, 59, 999);
  }

  /// Memeriksa apakah dua [DateTime] berada pada hari yang sama.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Label relatif: `Hari ini`, `Kemarin`, atau tanggal pendek.
  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    if (isSameDay(dateTime, now)) return 'Hari ini';

    final yesterday = now.subtract(const Duration(days: 1));
    if (isSameDay(dateTime, yesterday)) return 'Kemarin';

    return formatShort(dateTime);
  }
}
