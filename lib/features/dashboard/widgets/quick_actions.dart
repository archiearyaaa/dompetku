import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Baris tombol aksi cepat di halaman Dashboard.
class QuickActions extends StatelessWidget {
  final VoidCallback? onAddIncome;
  final VoidCallback? onAddExpense;

  const QuickActions({super.key, this.onAddIncome, this.onAddExpense});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Tombol Tambah Pemasukan
        Expanded(
          child: _QuickActionButton(
            label: 'Pemasukan',
            icon: Icons.arrow_downward_rounded,
            color: AppColors.income,
            backgroundColor: AppColors.income.withValues(alpha: 0.1),
            onTap: onAddIncome,
          ),
        ),
        const SizedBox(width: 12),

        // Tombol Tambah Pengeluaran
        Expanded(
          child: _QuickActionButton(
            label: 'Pengeluaran',
            icon: Icons.arrow_upward_rounded,
            color: AppColors.expense,
            backgroundColor: AppColors.expense.withValues(alpha: 0.1),
            onTap: onAddExpense,
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
