import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/category_expense_model.dart';

/// Palet warna kontras modern untuk visualisasi grafik donat kategori.
const List<Color> _categoryPalette = [
  Color(0xFFEF4444), // Red
  Color(0xFFF59E0B), // Amber
  Color(0xFF10B981), // Emerald
  Color(0xFF3B82F6), // Blue
  Color(0xFF8B5CF6), // Purple
  Color(0xFFEC4899), // Pink
  Color(0xFF06B6D4), // Cyan
  Color(0xFFF97316), // Orange
  Color(0xFF6366F1), // Indigo
  Color(0xFF84CC16), // Lime
];

/// Helper untuk mendapatkan warna konsisten berdasarkan indeks atau kode hex.
Color getCategoryChartColor(int index, String? hexColor) {
  if (hexColor != null && hexColor.isNotEmpty) {
    try {
      final hex = hexColor.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('0xFF$hex'));
      }
    } catch (_) {
      // Fallback ke palette
    }
  }
  return _categoryPalette[index % _categoryPalette.length];
}

/// Widget grafik donat pengeluaran per kategori menggunakan [fl_chart].
class ExpensePieChart extends StatefulWidget {
  final List<CategoryExpenseModel> categories;
  final int totalExpense;

  const ExpensePieChart({
    super.key,
    required this.categories,
    required this.totalExpense,
  });

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty || widget.totalExpense <= 0) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 54,
              color: AppColors.textSecondary.withAlpha(80),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tidak ada pengeluaran pada periode ini',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 65,
              sections: List.generate(widget.categories.length, (i) {
                final item = widget.categories[i];
                final isTouched = i == _touchedIndex;
                final radius = isTouched ? 36.0 : 28.0;
                final color = getCategoryChartColor(i, item.categoryColor);
                final percent = (item.percentage * 100).toStringAsFixed(0);

                return PieChartSectionData(
                  color: color,
                  value: item.totalAmount.toDouble(),
                  title: item.percentage >= 0.05 ? '$percent%' : '',
                  radius: radius,
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                );
              }),
            ),
          ),
          // Tulisan di tengah donat
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Total Pengeluaran',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                CurrencyFormatter.format(widget.totalExpense),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
