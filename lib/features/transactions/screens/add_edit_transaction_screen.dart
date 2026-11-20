import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared/formatters/rupiah_input_formatter.dart';
import '../../categories/widgets/add_edit_category_dialog.dart';
import '../controllers/transaction_controller.dart';

/// Halaman Form Tambah dan Edit Transaksi Keuangan.
class AddEditTransactionScreen extends ConsumerStatefulWidget {
  final String initialType;
  final TransactionModel? transaction;

  const AddEditTransactionScreen({
    super.key,
    this.initialType = 'expense',
    this.transaction,
  });

  @override
  ConsumerState<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState
    extends ConsumerState<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  int? _selectedCategoryId;
  bool _isLoading = false;

  bool get _isEditMode => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    _type = widget.transaction?.type ?? widget.initialType;

    if (_isEditMode) {
      _amountController = TextEditingController(
        text: CurrencyFormatter.format(
          widget.transaction!.amount,
        ).replaceAll('Rp', '').trim(),
      );
      _noteController = TextEditingController(
        text: widget.transaction?.note ?? '',
      );
      _selectedDate = widget.transaction!.occurredAt;
      _selectedCategoryId = widget.transaction!.categoryId;
    } else {
      _amountController = TextEditingController();
      _noteController = TextEditingController();
      _selectedDate = DateTime.now();
    }
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
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('id', 'ID'),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih kategori transaksi.')),
      );
      return;
    }

    final rawAmount = CurrencyFormatter.tryParse(_amountController.text);
    if (rawAmount == null || rawAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal harus lebih besar dari 0.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final controller = ref.read(transactionActionControllerProvider);

      if (_isEditMode) {
        final updatedTransaction = widget.transaction!.copyWith(
          type: _type,
          amount: rawAmount,
          categoryId: _selectedCategoryId!,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          occurredAt: _selectedDate,
          updatedAt: now,
        );
        await controller.updateTransaction(updatedTransaction);
      } else {
        final newTransaction = TransactionModel(
          type: _type,
          amount: rawAmount,
          categoryId: _selectedCategoryId!,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          occurredAt: _selectedDate,
          createdAt: now,
          updatedAt: now,
        );
        await controller.addTransaction(newTransaction);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Transaksi berhasil diperbarui.'
                  : 'Transaksi berhasil disimpan.',
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
            content: Text('Gagal menyimpan transaksi: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteTransaction() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Transaksi?'),
        content: const Text(
          'Transaksi ini akan dihapus secara permanen dari catatan keuangan Anda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        final controller = ref.read(transactionActionControllerProvider);
        await controller.deleteTransaction(widget.transaction!.id!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaksi berhasil dihapus.')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus transaksi: $e'),
              backgroundColor: AppColors.expense,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesProvider(_type));

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Ubah Transaksi' : 'Catat Transaksi'),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              tooltip: 'Hapus Transaksi',
              onPressed: _isLoading ? null : _deleteTransaction,
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.pagePaddingH,
              vertical: 20,
            ),
            children: [
              // ── 1. Pemilih Jenis Transaksi (Toggle Tab) ─────────
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: _TypeToggleButton(
                        label: 'Pengeluaran',
                        isSelected: _type == 'expense',
                        selectedColor: AppColors.expense,
                        onTap: () {
                          if (_type != 'expense') {
                            setState(() {
                              _type = 'expense';
                              _selectedCategoryId = null;
                            });
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: _TypeToggleButton(
                        label: 'Pemasukan',
                        isSelected: _type == 'income',
                        selectedColor: AppColors.income,
                        onTap: () {
                          if (_type != 'income') {
                            setState(() {
                              _type = 'income';
                              _selectedCategoryId = null;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── 2. Input Nominal Rupiah ─────────────────────────
              Text(
                'Nominal (Rp)',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _type == 'income'
                      ? AppColors.income
                      : AppColors.expense,
                ),
                inputFormatters: [RupiahInputFormatter()],
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  prefixStyle: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _type == 'income'
                        ? AppColors.income
                        : AppColors.expense,
                  ),
                  hintText: '0',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nominal wajib diisi';
                  }
                  final parsed = CurrencyFormatter.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return 'Nominal harus lebih besar dari Rp0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ── 3. Pilihan Kategori ─────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kategori',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text(
                      'Kategori Baru',
                      style: TextStyle(fontSize: 12),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) =>
                            AddEditCategoryDialog(defaultType: _type),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              categoriesAsync.when(
                data: (categories) {
                  if (categories.isEmpty) {
                    return const Text('Tidak ada kategori tersedia.');
                  }

                  return DropdownButtonFormField<int>(
                    initialValue: _selectedCategoryId,
                    decoration: const InputDecoration(
                      hintText: 'Pilih Kategori',
                    ),
                    items: categories.map((cat) {
                      return DropdownMenuItem<int>(
                        value: cat.id,
                        child: Row(
                          children: [
                            Icon(
                              _getCategoryIcon(cat.icon),
                              size: 18,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 10),
                            Text(cat.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                    validator: (val) =>
                        val == null ? 'Kategori wajib dipilih' : null,
                  );
                },
                loading: () => const SizedBox(
                  height: 48,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Memuat kategori...',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
                error: (e, _) => Text(
                  'Gagal memuat kategori: $e',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
              const SizedBox(height: 20),

              // ── 4. Tanggal Transaksi ────────────────────────────
              Text(
                'Tanggal',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 20,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        DateFormatter.formatDisplay(_selectedDate),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── 5. Catatan Opsional ─────────────────────────────
              Text(
                'Catatan (Opsional)',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Makan siang bersama rekan kerja',
                ),
              ),
              const SizedBox(height: 32),

              // ── 6. Tombol Simpan ────────────────────────────────
              ElevatedButton(
                onPressed: _isLoading ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                        _isEditMode ? 'Simpan Perubahan' : 'Catat Transaksi',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'trending_up':
        return Icons.trending_up;
      case 'restaurant':
        return Icons.restaurant_outlined;
      case 'directions_car':
        return Icons.directions_car_outlined;
      case 'shopping_bag':
        return Icons.shopping_bag_outlined;
      case 'receipt_long':
        return Icons.receipt_long_outlined;
      case 'sports_esports':
        return Icons.sports_esports_outlined;
      case 'medical_services':
        return Icons.medical_services_outlined;
      case 'school':
        return Icons.school_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}

class _TypeToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _TypeToggleButton({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
