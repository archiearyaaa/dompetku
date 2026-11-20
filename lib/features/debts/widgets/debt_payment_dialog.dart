import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/debt_payment_model.dart';
import '../../../shared/formatters/rupiah_input_formatter.dart';
import '../controllers/debt_controller.dart';

/// Modal dialog / bottom sheet untuk mencatat pembayaran utang atau penerimaan piutang.
class DebtPaymentDialog extends ConsumerStatefulWidget {
  final int debtId;
  final String personName;
  final String direction; // 'payable' atau 'receivable'
  final int remainingAmount;

  const DebtPaymentDialog({
    super.key,
    required this.debtId,
    required this.personName,
    required this.direction,
    required this.remainingAmount,
  });

  /// Helper untuk menampilkan dialog sebagai modal bottom sheet.
  static Future<bool?> show(
    BuildContext context, {
    required int debtId,
    required String personName,
    required String direction,
    required int remainingAmount,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: DebtPaymentDialog(
          debtId: debtId,
          personName: personName,
          direction: direction,
          remainingAmount: remainingAmount,
        ),
      ),
    );
  }

  @override
  ConsumerState<DebtPaymentDialog> createState() => _DebtPaymentDialogState();
}

class _DebtPaymentDialogState extends ConsumerState<DebtPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late DateTime _selectedDate;
  bool _isLoading = false;

  bool get _isPayable => widget.direction == 'payable';

  @override
  void initState() {
    super.initState();
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

  void _fillFullAmount() {
    setState(() {
      _amountController.text = CurrencyFormatter.format(widget.remainingAmount);
    });
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

    if (amount > widget.remainingAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Nominal melebihi sisa tagihan (${CurrencyFormatter.format(widget.remainingAmount)})',
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
      final payment = DebtPaymentModel(
        debtId: widget.debtId,
        amount: amount,
        occurredAt: _selectedDate,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      await ref.read(debtActionControllerProvider).addPayment(payment);

      if (mounted) {
        final actionText = _isPayable
            ? 'Pembayaran utang'
            : 'Penerimaan piutang';
        final isFullyPaid = amount == widget.remainingAmount;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFullyPaid
                  ? '$actionText berhasil! Status telah LUNAS 🎉'
                  : '$actionText sebesar ${CurrencyFormatter.format(amount)} berhasil disimpan.',
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
            content: Text('Gagal mencatat pembayaran: $e'),
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
    final titleText = _isPayable ? 'Bayar Utang' : 'Terima Piutang';
    final actionColor = _isPayable ? AppColors.expense : AppColors.secondary;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titleText,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: actionColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pihak: ${widget.personName}',
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

              // Kotak Info Sisa Tagihan & Tombol Bayar Lunas
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sisa yang belum dibayar:',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.format(widget.remainingAmount),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton(
                      onPressed: _fillFullAmount,
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        side: BorderSide(color: actionColor),
                        foregroundColor: actionColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                      child: const Text('Bayar Lunas'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Input Nominal
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [RupiahInputFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Nominal Pembayaran *',
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
                  if (parsed > widget.remainingAmount) {
                    return 'Nominal melebihi sisa tagihan';
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
                    labelText: 'Tanggal Pembayaran *',
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
                  hintText: 'Misal: Cicilan ke-1 via transfer',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Simpan
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionColor,
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
                        _isPayable
                            ? 'Simpan Pembayaran Utang'
                            : 'Simpan Penerimaan Piutang',
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
