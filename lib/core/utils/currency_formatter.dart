import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// Utilitas format mata uang Rupiah.
///
/// Semua nominal di Dompetku disimpan sebagai [int] (Rupiah penuh).
/// Kelas ini menyediakan fungsi format untuk tampilan UI.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: AppConstants.localeId,
    symbol: AppConstants.currencySymbol,
    decimalDigits: 0,
  );

  static final NumberFormat _compactFormatter = NumberFormat.compactCurrency(
    locale: AppConstants.localeId,
    symbol: AppConstants.currencySymbol,
    decimalDigits: 0,
  );

  /// Format integer Rupiah menjadi string dengan pemisah ribuan.
  ///
  /// Contoh: `150000` → `Rp150.000`
  static String format(int amount) {
    return _formatter.format(amount);
  }

  /// Format ringkas untuk nominal besar.
  ///
  /// Contoh: `1500000` → `Rp1,5 jt` (tergantung locale)
  static String formatCompact(int amount) {
    return _compactFormatter.format(amount);
  }

  /// Format nominal dengan tanda positif/negatif sesuai jenis transaksi.
  ///
  /// [isIncome] `true` → `+Rp150.000`, `false` → `-Rp150.000`
  static String formatSigned(int amount, {required bool isIncome}) {
    final prefix = isIncome ? '+' : '-';
    return '$prefix${_formatter.format(amount.abs())}';
  }

  /// Parse string angka (tanpa simbol mata uang) menjadi integer.
  ///
  /// Menghapus karakter non-digit sebelum parsing.
  /// Mengembalikan `null` jika input tidak valid.
  static int? tryParse(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return null;
    return int.tryParse(cleaned);
  }
}
