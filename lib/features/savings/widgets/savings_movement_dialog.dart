import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/savings_movement_model.dart';
import '../../../shared/formatters/rupiah_input_formatter.dart';
import '../controllers/savings_controller.dart';

/// Modal dialog / bottom sheet untuk mencatat mutasi tabungan (Setoran / Penarikan).
class SavingsMovementDialog extends ConsumerStatefulWidget {
  final int goalId;
  final String goalName;
  final int currentAmount;
  final String initialType; // 'deposit' atau 'withdrawal'

  const SavingsMovementDialog({
    super.key,
    required this.goalId,
    required this.goalName,
    required this.currentAmount,
    this.initialType = 'deposit',
  });

  /// Helper untuk menampilkan dialog sebagai modal bottom sheet.
  static Future<bool?> show(
    BuildContext context, {
    required int goalId,
    required String goalName,
    required int currentAmount,
    String initialType = 'deposit',
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SavingsMovementDialog(
          goalId: goalId,
          goalName: goalName,
          currentAmount: currentAmount,
          initialType: initialType,
        ),
      ),
    );
  }

  @override
  ConsumerState<SavingsMovementDialog> createState() =>
      _SavingsMovementDialogState();
}

class _SavingsMovementDialogState extends ConsumerState<SavingsMovementDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late String _type;
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _amountController = TextEditingController();
    _noteController = TextEditingController();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = CurrencyFormatter.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return;

    // Validasi penarikan tidak boleh melebihi saldo saat ini
    if (_type == 'withdrawal' && amount > widget.currentAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Saldo tabungan tidak mencukupi (Maksimal ${CurrencyFormatter.format(widget.currentAmount)})',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final movement = SavingsMovementModel(
        goalId: widget.goalId,
        amount: amount,
        type: _type,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        occurredAt: _selectedDate,
      );

      await ref.read(savingsActionControllerProvider).addMovement(movement);

      if (mounted) {
        final label = _type == 'deposit' ? 'Setoran' : 'Penarikan';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$label sebesar ${CurrencyFormatter.format(amount)} berhasil disimpan.',
            ),
            backgroundColor: AppColors.income,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan mutasi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDeposit = _type == 'deposit';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Dialog
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDeposit ? 'Setor Tabungan' : 'Tarik Tabungan',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDeposit
                                ? AppColors.income
                                : AppColors.expense,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.goalName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Pilihan Jenis (Setor / Tarik)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Setor (+)')),
                        selected: isDeposit,
                        selectedColor: AppColors.income.withAlpha(40),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDeposit
                              ? AppColors.income
                              : AppColors.textSecondary,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _type = 'deposit');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Tarik (-)')),
                        selected: !isDeposit,
                        selectedColor: AppColors.expense.withAlpha(40),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: !isDeposit
                              ? AppColors.expense
                              : AppColors.textSecondary,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _type = 'withdrawal');
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Info Saldo Saat Ini jika mode penarikan
              if (!isDeposit)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Saldo Tabungan Saat Ini:',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(widget.currentAmount),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

              // Input Nominal
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [RupiahInputFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Nominal *',
                  hintText: 'Rp 0',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nominal wajib diisi';
                  }
                  final parsed = CurrencyFormatter.tryParse(value) ?? 0;
                  if (parsed <= 0) {
                    return 'Nominal harus lebih dari 0';
                  }
                  if (_type == 'withdrawal' && parsed > widget.currentAmount) {
                    return 'Nominal melebihi saldo tabungan';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Pilihan Tanggal
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(10),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal *',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    DateFormatter.formatDisplay(_selectedDate),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Catatan Opsional
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  hintText: 'Misal: Tabungan sisa belanja',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Simpan
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDeposit
                      ? AppColors.income
                      : AppColors.expense,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isDeposit ? 'Simpan Setoran' : 'Simpan Penarikan',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
