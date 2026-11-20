import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/category_expense_model.dart';
import '../../transactions/controllers/transaction_controller.dart';

/// Pilihan periode laporan keuangan.
enum ReportPeriod { daily, weekly, monthly, custom }

/// Notifier untuk mengelola state periode laporan aktif.
class ReportPeriodNotifier extends Notifier<ReportPeriod> {
  @override
  ReportPeriod build() => ReportPeriod.monthly;

  void setPeriod(ReportPeriod period) {
    state = period;
  }
}

/// Provider periode laporan aktif (default: Bulanan).
final reportPeriodProvider =
    NotifierProvider<ReportPeriodNotifier, ReportPeriod>(() {
      return ReportPeriodNotifier();
    });

/// Notifier untuk rentang tanggal kustom.
class CustomDateRangeNotifier extends Notifier<DateTimeRange?> {
  @override
  DateTimeRange? build() => null;

  void setRange(DateTimeRange? range) {
    state = range;
  }
}

/// Provider rentang tanggal kustom yang dipilih pengguna.
final customDateRangeProvider =
    NotifierProvider<CustomDateRangeNotifier, DateTimeRange?>(() {
      return CustomDateRangeNotifier();
    });

/// Model data ringkasan analitik laporan.
class ReportData {
  final int totalIncome;
  final int totalExpense;
  final int netCashFlow;
  final List<CategoryExpenseModel> categoryExpenses;
  final DateTime startDate;
  final DateTime endDate;
  final ReportPeriod period;

  const ReportData({
    required this.totalIncome,
    required this.totalExpense,
    required this.netCashFlow,
    required this.categoryExpenses,
    required this.startDate,
    required this.endDate,
    required this.period,
  });
}

/// Provider agregasi data laporan berdasarkan periode yang dipilih.
final reportsDataProvider = FutureProvider<ReportData>((ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final period = ref.watch(reportPeriodProvider);
  final customRange = ref.watch(customDateRangeProvider);
  final now = DateTime.now();

  late DateTime start;
  late DateTime end;

  switch (period) {
    case ReportPeriod.daily:
      start = DateFormatter.startOfDay(now);
      end = DateFormatter.endOfDay(now);
      break;
    case ReportPeriod.weekly:
      start = DateFormatter.startOfWeek(now);
      end = DateFormatter.endOfWeek(now);
      break;
    case ReportPeriod.monthly:
      start = DateFormatter.startOfMonth(now);
      end = DateFormatter.endOfMonth(now);
      break;
    case ReportPeriod.custom:
      if (customRange != null) {
        start = DateFormatter.startOfDay(customRange.start);
        end = DateFormatter.endOfDay(customRange.end);
      } else {
        start = DateFormatter.startOfMonth(now);
        end = DateFormatter.endOfMonth(now);
      }
      break;
  }

  final income = await repository.getTotalIncome(
    startDate: start,
    endDate: end,
  );
  final expense = await repository.getTotalExpense(
    startDate: start,
    endDate: end,
  );
  final categories = await repository.getExpenseByCategory(
    startDate: start,
    endDate: end,
  );

  return ReportData(
    totalIncome: income,
    totalExpense: expense,
    netCashFlow: income - expense,
    categoryExpenses: categories,
    startDate: start,
    endDate: end,
    period: period,
  );
});

/// Generator ekspor teks/CSV dari ringkasan laporan keuangan.
String generateCsvReport(ReportData data) {
  final buffer = StringBuffer();
  buffer.writeln('LAPORAN KEUANGAN ${AppConstants.appName.toUpperCase()}');
  buffer.writeln(
    'Periode: ${DateFormatter.formatDisplay(data.startDate)} – ${DateFormatter.formatDisplay(data.endDate)}',
  );
  buffer.writeln('${AppConstants.copyright} by ${AppConstants.appAuthor}');
  buffer.writeln();
  buffer.writeln('--- RINGKASAN ARUS KAS ---');
  buffer.writeln('Total Pemasukan,${data.totalIncome}');
  buffer.writeln('Total Pengeluaran,${data.totalExpense}');
  buffer.writeln('Selisih Kas Bersih,${data.netCashFlow}');
  buffer.writeln();
  buffer.writeln('--- RINCIAN PENGELUARAN PER KATEGORI ---');
  buffer.writeln('Kategori,Total Pengeluaran,Jumlah Transaksi,Persentase');
  for (final cat in data.categoryExpenses) {
    final pct = (cat.percentage * 100).toStringAsFixed(1);
    buffer.writeln(
      '${cat.categoryName},${cat.totalAmount},${cat.transactionCount},$pct%',
    );
  }
  return buffer.toString();
}
