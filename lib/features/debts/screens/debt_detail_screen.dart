import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/debt_model.dart';
import '../../../shared/widgets/empty_state.dart';
import '../controllers/debt_controller.dart';
import '../widgets/debt_payment_dialog.dart';
import 'add_edit_debt_screen.dart';

/// Halaman Detail Utang atau Piutang, progres pelunasan, dan riwayat pembayaran.
class DebtDetailScreen extends ConsumerWidget {
  final int debtId;
  final DebtModel? initialDebt;

  const DebtDetailScreen({super.key, required this.debtId, this.initialDebt});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final debtAsync = ref.watch(debtDetailProvider(debtId));
    final paymentsAsync = ref.watch(debtPaymentsProvider(debtId));

    final debt = debtAsync.value ?? initialDebt;

    if (debtAsync.isLoading && debt == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Utang & Piutang')),
        body: const Center(child: Text('Memuat data...')),
      );
    }

    if (debt == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Utang & Piutang')),
        body: const Center(
          child: Text('Catatan tidak ditemukan atau telah dihapus.'),
        ),
      );
    }

    final isPayable = debt.isPayable;
    final isSettled = debt.isSettled;
    final progress = debt.principalAmount > 0
        ? (debt.paidAmount / debt.principalAmount).clamp(0.0, 1.0)
        : 1.0;
    final percentText = (progress * 100).toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(
        title: Text(isPayable ? 'Detail Utang' : 'Detail Piutang'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Catatan',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditDebtScreen(debt: debt),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(debtDetailProvider(debtId));
          ref.invalidate(debtPaymentsProvider(debtId));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 1. Kartu Ringkasan Utama ────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPayable
                        ? [AppColors.primary, const Color(0xFF2C3E50)]
                        : [const Color(0xFF1B4965), AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(40),
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
                        // Badge Jenis (Utang / Piutang)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isPayable ? 'UTANG SAYA' : 'PIUTANG SAYA',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        // Badge Status Lunas / Persen
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSettled
                                ? AppColors.income
                                : Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isSettled ? 'Lunas 🎉' : '$percentText% Terbayar',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Nama Pihak
                    Text(
                      debt.personName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.white.withAlpha(40),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isSettled ? AppColors.income : Colors.amber,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Rincian Pokok, Terbayar, dan Sisa
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nominal Pokok',
                              style: TextStyle(
                                color: Colors.white.withAlpha(180),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(debt.principalAmount),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Sisa Tagihan',
                              style: TextStyle(
                                color: Colors.white.withAlpha(180),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(debt.remainingAmount),
                              style: TextStyle(
                                color: isSettled
                                    ? AppColors.income
                                    : const Color(0xFFFFB4A2),
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 24),

                    // Info Jatuh Tempo & Catatan
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          debt.dueDate != null
                              ? 'Jatuh tempo: ${DateFormatter.formatDisplay(debt.dueDate!)}'
                              : 'Tidak ada tenggat waktu',
                          style: TextStyle(
                            color: Colors.white.withAlpha(200),
                            fontSize: 12,
                          ),
                        ),
                        if (debt.note != null && debt.note!.isNotEmpty)
                          Expanded(
                            child: Text(
                              debt.note!,
                              style: TextStyle(
                                color: Colors.white.withAlpha(180),
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── 2. Tombol Aksi Cepat Bayar / Terima ──────────
              if (!isSettled)
                ElevatedButton.icon(
                  onPressed: () {
                    DebtPaymentDialog.show(
                      context,
                      debtId: debt.id!,
                      personName: debt.personName,
                      direction: debt.direction,
                      remainingAmount: debt.remainingAmount,
                    );
                  },
                  icon: Icon(
                    isPayable ? Icons.payment_outlined : Icons.savings_outlined,
                  ),
                  label: Text(
                    isPayable
                        ? 'Catat Pembayaran Utang'
                        : 'Catat Penerimaan Piutang',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPayable
                        ? AppColors.expense
                        : AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.income.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.income.withAlpha(100)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.income,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isPayable
                            ? 'Utang ini sudah lunas sepenuhnya 🎉'
                            : 'Piutang ini sudah diterima lunas 🎉',
                        style: const TextStyle(
                          color: AppColors.income,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // ── 3. Riwayat Pembayaran ───────────────────────
              Text(
                'Riwayat Pembayaran',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              paymentsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('Memuat riwayat pembayaran...')),
                ),
                error: (err, stack) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Gagal memuat pembayaran: $err',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
                data: (payments) {
                  if (payments.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: const EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'Belum Ada Pembayaran',
                        description:
                            'Gunakan tombol di atas untuk mencatat cicilan atau pelunasan.',
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: payments.length,
                    separatorBuilder: (_, separatorIndex) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = payments[index];

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: isPayable
                              ? AppColors.expense.withAlpha(25)
                              : AppColors.secondary.withAlpha(25),
                          child: Icon(
                            Icons.check,
                            color: isPayable
                                ? AppColors.expense
                                : AppColors.secondary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          CurrencyFormatter.format(item.amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.textPrimary,
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
