import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Kartu saldo utama di halaman Dashboard.
///
/// Menampilkan saldo tersedia dengan latar belakang warna utama (Midnight Navy),
/// serta ringkasan pemasukan dan pengeluaran pada periode berjalan.
class BalanceCard extends StatelessWidget {
  final int availableBalance;
  final int totalIncome;
  final int totalExpense;

  const BalanceCard({
    super.key,
    this.availableBalance = 0,
    this.totalIncome = 0,
    this.totalExpense = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33142D4E),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Label Saldo Tersedia ─────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saldo Tersedia',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 14,
                      color: AppColors.textOnPrimary.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Bulan Ini',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textOnPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Nilai Saldo Rupiah ────────────────────────────────
          Text(
            CurrencyFormatter.format(availableBalance),
            style: theme.textTheme.headlineLarge?.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 20),

          // ── Divider Halus ────────────────────────────────────
          Divider(
            color: Colors.white.withValues(alpha: 0.15),
            height: 1,
            thickness: 1,
          ),
          const SizedBox(height: 16),

          // ── Baris Pemasukan & Pengeluaran ────────────────────
          Row(
            children: [
              // Pemasukan
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.income.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_downward_rounded,
                        color: AppColors.income,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pemasukan',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textOnPrimary.withValues(
                                alpha: 0.7,
                              ),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.scaleDown,
                            child: Text(
                              CurrencyFormatter.formatSigned(
                                totalIncome,
                                isIncome: true,
                              ),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: AppColors.textOnPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                height: 32,
                width: 1,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              const SizedBox(width: 16),

              // Pengeluaran
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.expense.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        color: AppColors.expense,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pengeluaran',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textOnPrimary.withValues(
                                alpha: 0.7,
                              ),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.scaleDown,
                            child: Text(
                              CurrencyFormatter.formatSigned(
                                totalExpense,
                                isIncome: false,
                              ),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: AppColors.textOnPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
