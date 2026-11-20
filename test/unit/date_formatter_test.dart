import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:dompetku/core/utils/date_formatter.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('DateFormatter — Database', () {
    test('toDbString menghasilkan format ISO-8601', () {
      final dt = DateTime(2026, 11, 19, 10, 30, 0, 0);
      final result = DateFormatter.toDbString(dt);
      expect(result, contains('2026'));
      expect(result, contains('11'));
      expect(result, contains('19'));
    });

    test('fromDbString membaca kembali hasil toDbString', () {
      final original = DateTime(2026, 11, 19, 10, 30, 0, 123);
      final dbString = DateFormatter.toDbString(original);
      final parsed = DateFormatter.fromDbString(dbString);

      expect(parsed, isNotNull);
      expect(parsed!.year, original.year);
      expect(parsed.month, original.month);
      expect(parsed.day, original.day);
      expect(parsed.hour, original.hour);
      expect(parsed.minute, original.minute);
    });

    test('fromDbString mengembalikan null untuk input null', () {
      expect(DateFormatter.fromDbString(null), isNull);
    });

    test('fromDbString mengembalikan null untuk string kosong', () {
      expect(DateFormatter.fromDbString(''), isNull);
    });
  });

  group('DateFormatter — Tampilan', () {
    test('formatDisplay menghasilkan format lengkap Indonesia', () {
      final dt = DateTime(2026, 1, 5);
      final result = DateFormatter.formatDisplay(dt);
      expect(result, contains('2026'));
      expect(result, contains('05'));
    });

    test('formatShort menghasilkan format pendek', () {
      final dt = DateTime(2026, 11, 19);
      final result = DateFormatter.formatShort(dt);
      expect(result, contains('19'));
      expect(result, contains('2026'));
    });

    test('formatMonthYear menghasilkan bulan dan tahun', () {
      final dt = DateTime(2026, 11);
      final result = DateFormatter.formatMonthYear(dt);
      expect(result, contains('2026'));
    });
  });

  group('DateFormatter — Utilitas', () {
    test('startOfDay mengembalikan 00:00:00', () {
      final dt = DateTime(2026, 11, 19, 15, 30, 45);
      final result = DateFormatter.startOfDay(dt);
      expect(result.hour, 0);
      expect(result.minute, 0);
      expect(result.second, 0);
    });

    test('endOfDay mengembalikan 23:59:59', () {
      final dt = DateTime(2026, 11, 19, 10, 0, 0);
      final result = DateFormatter.endOfDay(dt);
      expect(result.hour, 23);
      expect(result.minute, 59);
      expect(result.second, 59);
    });

    test('isSameDay mengembalikan true untuk hari yang sama', () {
      final a = DateTime(2026, 11, 19, 10, 0);
      final b = DateTime(2026, 11, 19, 23, 59);
      expect(DateFormatter.isSameDay(a, b), isTrue);
    });

    test('isSameDay mengembalikan false untuk hari berbeda', () {
      final a = DateTime(2026, 11, 19);
      final b = DateTime(2026, 11, 20);
      expect(DateFormatter.isSameDay(a, b), isFalse);
    });

    test('formatRelative mengembalikan "Hari ini"', () {
      final now = DateTime.now();
      expect(DateFormatter.formatRelative(now), 'Hari ini');
    });

    test('formatRelative mengembalikan "Kemarin"', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(DateFormatter.formatRelative(yesterday), 'Kemarin');
    });

    test('startOfMonth mengembalikan tanggal 1', () {
      final dt = DateTime(2026, 11, 19);
      final result = DateFormatter.startOfMonth(dt);
      expect(result.day, 1);
      expect(result.month, 11);
    });

    test('endOfMonth mengembalikan hari terakhir', () {
      final dt = DateTime(2026, 11, 19);
      final result = DateFormatter.endOfMonth(dt);
      expect(result.day, 30); // November memiliki 30 hari.
      expect(result.month, 11);
    });
  });
}
