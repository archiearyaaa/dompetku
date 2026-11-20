import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Kartu ringkasan ganda: Tabungan dan Kewajiban/Piutang.
class SummaryCards extends StatelessWidget {
  final int totalSavings;
  final int totalDebt;
  final int totalReceivable;
  final VoidCallback? onSavingsTap;
  final VoidCallback? onDebtsTap;

  const SummaryCards({
    super.key,
    this.totalSavings = 0,
    this.totalDebt = 0,
    this.totalReceivable = 0,
    this.onSavingsTap,
    this.onDebtsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Kartu Tabungan ──────────────────────────────────
        Expanded(
          child: _SummaryCard(
            title: 'Tabungan',
            amountText: CurrencyFormatter.format(totalSavings),
            icon: Icons.savings_outlined,
            iconColor: AppColors.secondary,
            iconBackgroundColor: AppColors.secondary.withValues(alpha: 0.12),
            onTap: onSavingsTap,
            subtitle: 'Alokasi target',
          ),
        ),
        const SizedBox(width: 12),

        // ── Kartu Utang & Piutang ────────────────────────────
        Expanded(
          child: _SummaryCard(
            title: 'Utang / Piutang',
            amountText: totalDebt > 0
                ? 'Utang: ${CurrencyFormatter.format(totalDebt)}'
                : 'Piutang: ${CurrencyFormatter.format(totalReceivable)}',
            icon: Icons.account_balance_outlined,
            iconColor: totalDebt > 0 ? AppColors.warning : AppColors.secondary,
            iconBackgroundColor:
                (totalDebt > 0 ? AppColors.warning : AppColors.secondary)
                    .withValues(alpha: 0.12),
            onTap: onDebtsTap,
            subtitle: totalDebt > 0 && totalReceivable > 0
                ? 'Piutang: ${CurrencyFormatter.format(totalReceivable)}'
                : 'Kewajiban aktif',
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String amountText;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final VoidCallback? onTap;

  const _SummaryCard({
    required this.title,
    required this.amountText,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 16, color: iconColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                amountText,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
