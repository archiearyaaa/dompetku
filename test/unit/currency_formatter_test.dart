import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:dompetku/core/utils/currency_formatter.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('CurrencyFormatter.format', () {
    test('format nol', () {
      expect(CurrencyFormatter.format(0), contains('0'));
    });

    test('format nominal positif kecil', () {
      final result = CurrencyFormatter.format(1000);
      expect(result, contains('Rp'));
      expect(result, contains('1'));
    });

    test('format nominal positif besar', () {
      final result = CurrencyFormatter.format(1500000);
      expect(result, contains('Rp'));
      expect(result, contains('1'));
      expect(result, contains('500'));
    });
  });

  group('CurrencyFormatter.formatSigned', () {
    test('pemasukan menampilkan tanda +', () {
      final result = CurrencyFormatter.formatSigned(50000, isIncome: true);
      expect(result.startsWith('+'), isTrue);
    });

    test('pengeluaran menampilkan tanda -', () {
      final result = CurrencyFormatter.formatSigned(50000, isIncome: false);
      expect(result.startsWith('-'), isTrue);
    });
  });

  group('CurrencyFormatter.tryParse', () {
    test('parse angka murni', () {
      expect(CurrencyFormatter.tryParse('150000'), 150000);
    });

    test('parse string dengan titik pemisah ribuan', () {
      expect(CurrencyFormatter.tryParse('150.000'), 150000);
    });

    test('parse string dengan Rp dan titik', () {
      expect(CurrencyFormatter.tryParse('Rp150.000'), 150000);
    });

    test('parse string kosong mengembalikan null', () {
      expect(CurrencyFormatter.tryParse(''), isNull);
    });

    test('parse string tanpa angka mengembalikan null', () {
      expect(CurrencyFormatter.tryParse('abc'), isNull);
    });
  });
}
