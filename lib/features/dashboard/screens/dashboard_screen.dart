import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../settings/screens/settings_screen.dart';
import '../../debts/controllers/debt_controller.dart';
import '../../savings/controllers/savings_controller.dart';
import '../../transactions/controllers/transaction_controller.dart';
import '../../transactions/screens/add_edit_transaction_screen.dart';
import '../widgets/balance_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/summary_cards.dart';

/// Halaman utama Dashboard Dompetku.
class DashboardScreen extends ConsumerWidget {
  final VoidCallback? onNavigateToTransactions;
  final VoidCallback? onNavigateToSavings;
  final VoidCallback? onNavigateToDebts;
  final VoidCallback? onAddIncome;
  final VoidCallback? onAddExpense;

  const DashboardScreen({
    super.key,
    this.onNavigateToTransactions,
    this.onNavigateToSavings,
    this.onNavigateToDebts,
    this.onAddIncome,
    this.onAddExpense,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final totalSavingsAsync = ref.watch(totalSavingsProvider);
    final debtsSummaryAsync = ref.watch(debtsSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.account_balance_wallet_rounded,
              color: AppColors.textOnPrimary,
              size: 22,
            ),
            const SizedBox(width: 8),
            const Text(AppConstants.appName),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Pengaturan',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardSummaryProvider);
          ref.invalidate(totalSavingsProvider);
          ref.invalidate(debtsSummaryProvider);
          await ref.read(dashboardSummaryProvider.future);
        },
        child: summaryAsync.when(
          data: (summary) {
            return ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.pagePaddingH,
                vertical: 16,
              ),
              children: [
                // ── 1. Kartu Saldo Utama ───────────────────────────
                BalanceCard(
                  availableBalance: summary.availableBalance,
                  totalIncome: summary.monthIncome,
                  totalExpense: summary.monthExpense,
                ),
                const SizedBox(height: 16),

                // ── 2. Aksi Cepat ──────────────────────────────────
                QuickActions(
                  onAddIncome:
                      onAddIncome ??
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddEditTransactionScreen(
                              initialType: 'income',
                            ),
                          ),
                        );
                      },
                  onAddExpense:
                      onAddExpense ??
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddEditTransactionScreen(
                              initialType: 'expense',
                            ),
                          ),
                        );
                      },
                ),
                const SizedBox(height: 16),

                // ── 3. Ringkasan Tabungan & Utang ──────────────────
                SummaryCards(
                  totalSavings: totalSavingsAsync.value ?? 0,
                  totalDebt: debtsSummaryAsync.value?.totalPayable ?? 0,
                  totalReceivable:
                      debtsSummaryAsync.value?.totalReceivable ?? 0,
                  onSavingsTap: onNavigateToSavings,
                  onDebtsTap: onNavigateToDebts,
                ),
                const SizedBox(height: 24),

                // ── 4. Transaksi Terbaru (Header) ──────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transaksi Terbaru',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: onNavigateToTransactions,
                      child: const Text('Lihat Semua'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ── 5. Daftar / Empty State Transaksi Terbaru ──────
                if (summary.recentTransactions.isEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: const EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'Belum Ada Transaksi',
                      description:
                          'Catat pemasukan atau pengeluaran pertama Anda menggunakan tombol di atas.',
                    ),
                  )
                else
                  ...summary.recentTransactions.map((tx) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _RecentTransactionTile(
                        transaction: tx,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddEditTransactionScreen(transaction: tx),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                const SizedBox(height: 24),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Gagal memuat ringkasan: $e',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(dashboardSummaryProvider),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentTransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onTap;

  const _RecentTransactionTile({
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = transaction.isIncome;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final categoryName = transaction.category?.name ?? 'Tanpa Kategori';

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isIncome
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (transaction.note != null &&
                        transaction.note!.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        transaction.note!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      DateFormatter.formatRelative(transaction.occurredAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                CurrencyFormatter.formatSigned(
                  transaction.amount,
                  isIncome: isIncome,
                ),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
