import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/debt_model.dart';
import '../../../shared/formatters/rupiah_input_formatter.dart';
import '../controllers/debt_controller.dart';

/// Halaman Tambah atau Edit Utang & Piutang.
class AddEditDebtScreen extends ConsumerStatefulWidget {
  final DebtModel? debt;
  final String initialDirection; // 'payable' atau 'receivable'

  const AddEditDebtScreen({
    super.key,
    this.debt,
    this.initialDirection = 'payable',
  });

  @override
  ConsumerState<AddEditDebtScreen> createState() => _AddEditDebtScreenState();
}

class _AddEditDebtScreenState extends ConsumerState<AddEditDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _personNameController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late String _direction;
  DateTime? _dueDate;
  bool _isLoading = false;

  bool get _isEditMode => widget.debt != null;
  bool get _isPayable => _direction == 'payable';

  @override
  void initState() {
    super.initState();
    final debt = widget.debt;
    _direction = debt?.direction ?? widget.initialDirection;
    _personNameController = TextEditingController(text: debt?.personName ?? '');
    _amountController = TextEditingController(
      text: debt != null ? CurrencyFormatter.format(debt.principalAmount) : '',
    );
    _noteController = TextEditingController(text: debt?.note ?? '');
    _dueDate = debt?.dueDate;
  }

  @override
  void dispose() {
    _personNameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _saveDebt() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = CurrencyFormatter.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final controller = ref.read(debtActionControllerProvider);

      if (_isEditMode) {
        final updated = widget.debt!.copyWith(
          direction: _direction,
          personName: _personNameController.text.trim(),
          principalAmount: amount,
          dueDate: _dueDate,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );
        await controller.updateDebt(updated);
      } else {
        final newDebt = DebtModel(
          direction: _direction,
          personName: _personNameController.text.trim(),
          principalAmount: amount,
          dueDate: _dueDate,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          status: 'active',
          createdAt: DateTime.now(),
        );
        await controller.addDebt(newDebt);
      }

      if (mounted) {
        final label = _isPayable ? 'Catatan utang' : 'Catatan piutang';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? '$label berhasil diperbarui.'
                  : '$label berhasil disimpan.',
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
            content: Text('Gagal menyimpan data: $e'),
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
        title: const Text('Hapus Catatan?'),
        content: const Text(
          'Semua riwayat pembayaran terkait juga akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan.',
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
            .read(debtActionControllerProvider)
            .deleteDebt(widget.debt!.id!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Catatan berhasil dihapus.'),
              backgroundColor: AppColors.income,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus data: $e'),
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
    final isPayable = _isPayable;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode
              ? (isPayable ? 'Edit Utang' : 'Edit Piutang')
              : (isPayable ? 'Catat Utang Baru' : 'Catat Piutang Baru'),
        ),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.expense),
              tooltip: 'Hapus Catatan',
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
              // Pilihan Jenis (Utang vs Piutang)
              if (!_isEditMode) ...[
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
                          label: const Center(
                            child: Text('Utang (Saya Berutang)'),
                          ),
                          selected: isPayable,
                          selectedColor: AppColors.expense.withAlpha(35),
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isPayable
                                ? AppColors.expense
                                : AppColors.textSecondary,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _direction = 'payable');
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(
                            child: Text('Piutang (Hak Tagih)'),
                          ),
                          selected: !isPayable,
                          selectedColor: AppColors.secondary.withAlpha(35),
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: !isPayable
                                ? AppColors.secondary
                                : AppColors.textSecondary,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _direction = 'receivable');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Input Nama Pihak
              TextFormField(
                controller: _personNameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: isPayable
                      ? 'Nama Pemberi Pinjaman *'
                      : 'Nama Peminjam *',
                  hintText: 'Misal: Budi Santoso, Bank Mandiri',
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama pihak wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input Nominal Pokok
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [RupiahInputFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Nominal Pokok *',
                  hintText: 'Rp 0',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nominal pokok wajib diisi';
                  }
                  final parsed = CurrencyFormatter.tryParse(value) ?? 0;
                  if (parsed <= 0) {
                    return 'Nominal pokok harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input Tanggal Jatuh Tempo (Opsional)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDueDate,
                      borderRadius: BorderRadius.circular(10),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Jatuh Tempo (Opsional)',
                          prefixIcon: Icon(Icons.event_outlined),
                        ),
                        child: Text(
                          _dueDate != null
                              ? DateFormatter.formatDisplay(_dueDate!)
                              : 'Tidak ada tenggat',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _dueDate != null
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_dueDate != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: AppColors.textSecondary,
                      ),
                      tooltip: 'Hapus tanggal',
                      onPressed: () {
                        setState(() {
                          _dueDate = null;
                        });
                      },
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              // Input Catatan (Opsional)
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  hintText: 'Misal: Keperluan perbaikan motor',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
              ),
              const SizedBox(height: 32),

              // Tombol Simpan
              ElevatedButton(
                onPressed: _isLoading ? null : _saveDebt,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPayable
                      ? AppColors.primary
                      : AppColors.secondary,
                  foregroundColor: Colors.white,
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
                        _isEditMode ? 'Simpan Perubahan' : 'Simpan Catatan',
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
