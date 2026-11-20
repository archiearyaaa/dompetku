import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/savings_goal_model.dart';
import '../../../shared/widgets/empty_state.dart';
import '../controllers/savings_controller.dart';
import '../widgets/savings_movement_dialog.dart';
import 'add_edit_savings_goal_screen.dart';

/// Halaman Detail Target Tabungan, progres pencapaian, dan riwayat mutasi.
class SavingsGoalDetailScreen extends ConsumerWidget {
  final int goalId;
  final SavingsGoalModel? initialGoal;

  const SavingsGoalDetailScreen({
    super.key,
    required this.goalId,
    this.initialGoal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final goalAsync = ref.watch(savingsGoalDetailProvider(goalId));
    final movementsAsync = ref.watch(savingsMovementsProvider(goalId));

    final goal = goalAsync.value ?? initialGoal;

    if (goalAsync.isLoading && goal == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Tabungan')),
        body: const Center(child: Text('Memuat data tabungan...')),
      );
    }

    if (goal == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Tabungan')),
        body: const Center(
          child: Text('Target tabungan tidak ditemukan atau telah dihapus.'),
        ),
      );
    }

    final isTargetReached = goal.isAchieved;
    final progress = goal.progressPercentage.clamp(0.0, 1.0);
    final percentText = (progress * 100).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Target',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditSavingsGoalScreen(goal: goal),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(savingsGoalDetailProvider(goalId));
          ref.invalidate(savingsMovementsProvider(goalId));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 1. Kartu Progres Utama ──────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withAlpha(220),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(50),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            goal.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (isTargetReached)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.income,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Tercapai 🎉',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        else
                          Text(
                            '$percentText%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Colors.white.withAlpha(50),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isTargetReached
                              ? AppColors.income
                              : AppColors.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Rincian Terkumpul vs Target
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Terkumpul',
                              style: TextStyle(
                                color: Colors.white.withAlpha(180),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(goal.currentAmount),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Target',
                              style: TextStyle(
                                color: Colors.white.withAlpha(180),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(goal.targetAmount),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 24),

                    // Info Sisa & Tenggat Waktu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isTargetReached
                              ? 'Target telah terpenuhi!'
                              : 'Sisa: ${CurrencyFormatter.format(goal.remainingAmount)}',
                          style: TextStyle(
                            color: Colors.white.withAlpha(200),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (goal.targetDate != null)
                          Text(
                            'Tenggat: ${DateFormatter.formatDisplay(goal.targetDate!)}',
                            style: TextStyle(
                              color: Colors.white.withAlpha(200),
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── 2. Tombol Aksi Cepat (Setor & Tarik) ─────────
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        SavingsMovementDialog.show(
                          context,
                          goalId: goal.id!,
                          goalName: goal.name,
                          currentAmount: goal.currentAmount,
                          initialType: 'deposit',
                        );
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Setor'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.income,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: goal.currentAmount <= 0
                          ? null
                          : () {
                              SavingsMovementDialog.show(
                                context,
                                goalId: goal.id!,
                                goalName: goal.name,
                                currentAmount: goal.currentAmount,
                                initialType: 'withdrawal',
                              );
                            },
                      icon: const Icon(Icons.remove_circle_outline),
                      label: const Text('Tarik'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.expense,
                        side: const BorderSide(color: AppColors.expense),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── 3. Riwayat Mutasi ───────────────────────────
              Text(
                'Riwayat Mutasi',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              movementsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('Memuat riwayat mutasi...')),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Gagal memuat riwayat mutasi: $err',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
                data: (movements) {
                  if (movements.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: const EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'Belum Ada Mutasi',
                        description:
                            'Tekan tombol Setor untuk mulai menabung ke target ini.',
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: movements.length,
                    separatorBuilder: (_, separatorIndex) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = movements[index];
                      final isDep = item.isDeposit;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: isDep
                              ? AppColors.income.withAlpha(30)
                              : AppColors.expense.withAlpha(30),
                          child: Icon(
                            isDep ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isDep ? AppColors.income : AppColors.expense,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          isDep ? 'Setoran Tabungan' : 'Penarikan Tabungan',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          item.note != null && item.note!.isNotEmpty
                              ? '${DateFormatter.formatDisplay(item.occurredAt)} • ${item.note}'
                              : DateFormatter.formatDisplay(item.occurredAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: Text(
                          '${isDep ? '+' : '-'} ${CurrencyFormatter.format(item.amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: isDep ? AppColors.income : AppColors.expense,
                          ),
                        ),
                      );
                    },
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
