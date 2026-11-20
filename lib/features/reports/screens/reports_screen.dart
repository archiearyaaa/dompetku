import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/empty_state.dart';
import '../controllers/reports_controller.dart';
import '../widgets/category_expense_tile.dart';
import '../widgets/expense_pie_chart.dart';

/// Halaman Laporan & Analitik Keuangan Dompetku.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  String _formatPeriodLabel(ReportData data) {
    switch (data.period) {
      case ReportPeriod.daily:
        return 'Hari Ini • ${DateFormatter.formatDisplay(data.startDate)}';
      case ReportPeriod.weekly:
        return '${DateFormatter.formatShort(data.startDate)} – ${DateFormatter.formatShort(data.endDate)}';
      case ReportPeriod.monthly:
        return DateFormatter.formatMonthYear(data.startDate);
      case ReportPeriod.custom:
        return '${DateFormatter.formatShort(data.startDate)} – ${DateFormatter.formatShort(data.endDate)} (Kustom)';
    }
  }

  Future<void> _pickCustomRange(BuildContext context, WidgetRef ref) async {
    final currentRange = ref.read(customDateRangeProvider);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange:
          currentRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 7)),
            end: DateTime.now(),
          ),
    );
    if (picked != null) {
      ref.read(customDateRangeProvider.notifier).setRange(picked);
      ref.read(reportPeriodProvider.notifier).setPeriod(ReportPeriod.custom);
    }
  }

  void _showExportDialog(BuildContext context, ReportData data) {
    final csvContent = generateCsvReport(data);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ekspor Laporan'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pratinjau data laporan (format teks CSV):',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  csvContent,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: csvContent));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Laporan berhasil disalin ke clipboard!'),
                  backgroundColor: AppColors.income,
                ),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Salin Teks'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedPeriod = ref.watch(reportPeriodProvider);
    final reportAsync = ref.watch(reportsDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Keuangan'),
        actions: [
          if (reportAsync.hasValue)
            IconButton(
              icon: const Icon(Icons.file_download_outlined),
              tooltip: 'Ekspor Laporan',
              onPressed: () => _showExportDialog(context, reportAsync.value!),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(reportsDataProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 1. Pemilih Periode (Harian, Mingguan, Bulanan, Kustom) ──
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Harian'),
                      selected: selectedPeriod == ReportPeriod.daily,
                      onSelected: (selected) {
                        if (selected) {
                          ref
                              .read(reportPeriodProvider.notifier)
                              .setPeriod(ReportPeriod.daily);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Mingguan'),
                      selected: selectedPeriod == ReportPeriod.weekly,
                      onSelected: (selected) {
                        if (selected) {
                          ref
                              .read(reportPeriodProvider.notifier)
                              .setPeriod(ReportPeriod.weekly);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Bulanan'),
                      selected: selectedPeriod == ReportPeriod.monthly,
                      onSelected: (selected) {
                        if (selected) {
                          ref
                              .read(reportPeriodProvider.notifier)
                              .setPeriod(ReportPeriod.monthly);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      avatar: const Icon(Icons.date_range, size: 16),
                      label: const Text('Kustom'),
                      selected: selectedPeriod == ReportPeriod.custom,
                      onSelected: (_) {
                        _pickCustomRange(context, ref);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              reportAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: Text('Memuat laporan keuangan...')),
                ),
                error: (err, stack) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Gagal memuat laporan: $err',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
                data: (data) {
                  final isNetPositive = data.netCashFlow >= 0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Label Rentang Periode Aktif
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatPeriodLabel(data),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── 2. Kartu Ringkasan Arus Kas ─────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Pemasukan
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Pemasukan',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        CurrencyFormatter.format(
                                          data.totalIncome,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.income,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 36,
                                  color: AppColors.divider,
                                ),
                                const SizedBox(width: 12),

                                // Pengeluaran
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Pengeluaran',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        CurrencyFormatter.format(
                                          data.totalExpense,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.expense,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),

                            // Selisih Bersih (Net Cash Flow)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Selisih Kas Bersih:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${isNetPositive ? '+' : ''}${CurrencyFormatter.format(data.netCashFlow)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: isNetPositive
                                        ? AppColors.income
                                        : AppColors.expense,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── 3. Visualisasi Donut Chart ──────────────
                      Text(
                        'Komposisi Pengeluaran',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: ExpensePieChart(
                          categories: data.categoryExpenses,
                          totalExpense: data.totalExpense,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── 4. Rincian Pengeluaran per Kategori ─────
                      Text(
                        'Rincian per Kategori',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (data.categoryExpenses.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: const EmptyState(
                            icon: Icons.bar_chart_outlined,
                            title: 'Belum Ada Pengeluaran',
                            description:
                                'Transaksi pengeluaran pada periode ini belum tercatat.',
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: data.categoryExpenses.length,
                          separatorBuilder: (_, separatorIndex) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final cat = data.categoryExpenses[index];
                            return CategoryExpenseTile(item: cat, index: index);
                          },
                        ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
