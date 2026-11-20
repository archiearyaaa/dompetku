import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/debt_model.dart';
import '../../../shared/widgets/empty_state.dart';
import '../controllers/debt_controller.dart';
import 'add_edit_debt_screen.dart';
import 'debt_detail_screen.dart';

/// Halaman Pencatatan & Monitoring Utang dan Piutang.
class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(debtsSummaryProvider);
    final debtsAsync = ref.watch(debtsListProvider);
    final currentFilter = ref.watch(debtDirectionFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Utang & Piutang')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditDebtScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Catat Baru'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(debtsSummaryProvider);
          ref.invalidate(debtsListProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 1. Dua Kartu Ringkasan (Total Utang & Piutang) ─
              summaryAsync.when(
                loading: () => const SizedBox(
                  height: 90,
                  child: Center(child: Text('Memuat ringkasan...')),
                ),
                error: (err, stack) => const SizedBox.shrink(),
                data: (summary) {
                  return Row(
                    children: [
                      // Kartu Utang (Kewajiban)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.expense.withAlpha(50),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.expense.withAlpha(20),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_upward_rounded,
                                      color: AppColors.expense,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Total Utang',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                CurrencyFormatter.format(summary.totalPayable),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.expense,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Kartu Piutang (Hak Tagih)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.secondary.withAlpha(50),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withAlpha(20),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_downward_rounded,
                                      color: AppColors.secondary,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Total Piutang',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                CurrencyFormatter.format(
                                  summary.totalReceivable,
                                ),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.secondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // ── 2. Filter Chips (Semua, Utang, Piutang) ──────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('Semua'),
                      selected: currentFilter == null,
                      onSelected: (_) {
                        ref
                            .read(debtDirectionFilterProvider.notifier)
                            .setFilter(null);
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Utang Saja'),
                      selected: currentFilter == 'payable',
                      selectedColor: AppColors.expense.withAlpha(30),
                      onSelected: (_) {
                        ref
                            .read(debtDirectionFilterProvider.notifier)
                            .setFilter('payable');
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Piutang Saja'),
                      selected: currentFilter == 'receivable',
                      selectedColor: AppColors.secondary.withAlpha(30),
                      onSelected: (_) {
                        ref
                            .read(debtDirectionFilterProvider.notifier)
                            .setFilter('receivable');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── 3. Daftar Utang & Piutang ────────────────────
              debtsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text('Memuat data utang & piutang...')),
                ),
                error: (err, stack) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Gagal memuat data: $err',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
                data: (debts) {
                  if (debts.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        children: [
                          const EmptyState(
                            icon: Icons.account_balance_outlined,
                            title: 'Belum Ada Catatan Utang / Piutang',
                            description:
                                'Catat kewajiban atau uang yang dipinjamkan agar pengelolaan keuangan lebih teratur.',
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddEditDebtScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Catat Utang / Piutang'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: debts.length,
                    separatorBuilder: (_, separatorIndex) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = debts[index];
                      return _DebtCard(debt: item);
                    },
                  );
                },
              ),
              const SizedBox(height: 80), // Jarak untuk FAB
            ],
          ),
        ),
      ),
    );
  }
}

/// Komponen kartu untuk satu catatan utang / piutang.
class _DebtCard extends StatelessWidget {
  final DebtModel debt;

  const _DebtCard({required this.debt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPayable = debt.isPayable;
    final isSettled = debt.isSettled;
    final progress = debt.principalAmount > 0
        ? (debt.paidAmount / debt.principalAmount).clamp(0.0, 1.0)
        : 1.0;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                DebtDetailScreen(debtId: debt.id!, initialDebt: debt),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSettled
                ? AppColors.income.withAlpha(80)
                : AppColors.divider,
            width: isSettled ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris Atas: Badge Tipe, Nama Pihak, dan Status Lunas / Sisa
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isPayable
                        ? AppColors.expense.withAlpha(20)
                        : AppColors.secondary.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isPayable ? 'Utang' : 'Piutang',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isPayable
                          ? AppColors.expense
                          : AppColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    debt.personName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSettled)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.income.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Lunas 🎉',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.income,
                      ),
                    ),
                  )
                else
                  Text(
                    'Sisa: ${CurrencyFormatter.format(debt.remainingAmount)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isPayable
                          ? AppColors.expense
                          : AppColors.secondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isSettled
                      ? AppColors.income
                      : (isPayable ? AppColors.expense : AppColors.secondary),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Baris Bawah: Total Pokok & Tenggat Waktu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pokok: ${CurrencyFormatter.format(debt.principalAmount)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (debt.dueDate != null)
                  Text(
                    'Jatuh tempo: ${DateFormatter.formatDisplay(debt.dueDate!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
