import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/savings_goal_model.dart';
import '../../../shared/formatters/rupiah_input_formatter.dart';
import '../controllers/savings_controller.dart';

/// Halaman Tambah atau Edit Target Tabungan.
class AddEditSavingsGoalScreen extends ConsumerStatefulWidget {
  final SavingsGoalModel? goal;

  const AddEditSavingsGoalScreen({super.key, this.goal});

  @override
  ConsumerState<AddEditSavingsGoalScreen> createState() =>
      _AddEditSavingsGoalScreenState();
}

class _AddEditSavingsGoalScreenState
    extends ConsumerState<AddEditSavingsGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _targetAmountController;

  DateTime? _targetDate;
  bool _isLoading = false;

  bool get _isEditMode => widget.goal != null;

  @override
  void initState() {
    super.initState();
    final goal = widget.goal;
    _nameController = TextEditingController(text: goal?.name ?? '');
    _targetAmountController = TextEditingController(
      text: goal != null ? CurrencyFormatter.format(goal.targetAmount) : '',
    );
    _targetDate = goal?.targetDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  Future<void> _pickTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    final targetAmount =
        CurrencyFormatter.tryParse(_targetAmountController.text) ?? 0;
    if (targetAmount <= 0) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final controller = ref.read(savingsActionControllerProvider);

      if (_isEditMode) {
        final updated = widget.goal!.copyWith(
          name: _nameController.text.trim(),
          targetAmount: targetAmount,
          targetDate: _targetDate,
        );
        await controller.updateGoal(updated);
      } else {
        final newGoal = SavingsGoalModel(
          name: _nameController.text.trim(),
          targetAmount: targetAmount,
          targetDate: _targetDate,
          isArchived: false,
          createdAt: DateTime.now(),
        );
        await controller.addGoal(newGoal);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Target tabungan berhasil diperbarui.'
                  : 'Target tabungan berhasil dibuat.',
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
            content: Text('Gagal menyimpan target tabungan: $e'),
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

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Target Tabungan?'),
        content: const Text(
          'Semua riwayat mutasi terkait target tabungan ini juga akan dihapus. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() {
        _isLoading = true;
      });

      try {
        await ref
            .read(savingsActionControllerProvider)
            .deleteGoal(widget.goal!.id!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Target tabungan berhasil dihapus.'),
              backgroundColor: AppColors.income,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus target: $e'),
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Target Tabungan' : 'Target Tabungan Baru',
        ),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.expense),
              tooltip: 'Hapus Target',
              onPressed: _isLoading ? null : _confirmDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Input Nama Target
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nama Target *',
                  hintText: 'Misal: Dana Darurat, Beli Motor, Liburan',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama target wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input Target Nominal
              TextFormField(
                controller: _targetAmountController,
                keyboardType: TextInputType.number,
                inputFormatters: [RupiahInputFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Target Nominal *',
                  hintText: 'Rp 0',
                  prefixIcon: Icon(Icons.savings_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Target nominal wajib diisi';
                  }
                  final parsed = CurrencyFormatter.tryParse(value) ?? 0;
                  if (parsed <= 0) {
                    return 'Target nominal harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input Target Tanggal (Opsional)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickTargetDate,
                      borderRadius: BorderRadius.circular(10),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tenggat Waktu (Opsional)',
                          prefixIcon: Icon(Icons.event_outlined),
                        ),
                        child: Text(
                          _targetDate != null
                              ? DateFormatter.formatDisplay(_targetDate!)
                              : 'Belum ditentukan',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _targetDate != null
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_targetDate != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: AppColors.textSecondary,
                      ),
                      tooltip: 'Hapus tanggal',
                      onPressed: () {
                        setState(() {
                          _targetDate = null;
                        });
                      },
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 32),

              // Tombol Simpan
              ElevatedButton(
                onPressed: _isLoading ? null : _saveGoal,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                        _isEditMode ? 'Simpan Perubahan' : 'Buat Target',
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
