import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/category_icon_helper.dart';
import '../../../data/models/category_model.dart';
import '../controllers/category_controller.dart';

/// Modal dialog / sheet untuk menambah atau mengubah kategori transaksi.
class AddEditCategoryDialog extends ConsumerStatefulWidget {
  final CategoryModel? category;
  final String? defaultType;

  const AddEditCategoryDialog({super.key, this.category, this.defaultType});

  @override
  ConsumerState<AddEditCategoryDialog> createState() =>
      _AddEditCategoryDialogState();
}

class _AddEditCategoryDialogState extends ConsumerState<AddEditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  late String _type;
  late String _selectedIcon;
  late String _selectedColor;
  bool _isLoading = false;

  bool get _isEditMode => widget.category != null;

  @override
  void initState() {
    super.initState();
    final cat = widget.category;
    _nameController = TextEditingController(text: cat?.name ?? '');
    _type = cat?.type ?? widget.defaultType ?? 'expense';
    _selectedIcon =
        cat?.icon ?? (_type == 'income' ? 'trending_up' : 'restaurant');
    _selectedColor = cat?.color ?? (_type == 'income' ? '#2E7D32' : '#2878D0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    final trimmedName = _nameController.text.trim();
    setState(() => _isLoading = true);

    try {
      final controller = ref.read(categoryActionControllerProvider);
      final now = DateTime.now();

      if (_isEditMode) {
        final updated = widget.category!.copyWith(
          name: trimmedName,
          type: _type,
          icon: _selectedIcon,
          color: _selectedColor,
        );
        await controller.updateCategory(updated);
      } else {
        final newCategory = CategoryModel(
          name: trimmedName,
          type: _type,
          icon: _selectedIcon,
          color: _selectedColor,
          isDefault: false,
          isArchived: false,
          createdAt: now,
        );
        await controller.addCategory(newCategory);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Kategori "$trimmedName" berhasil diperbarui.'
                  : 'Kategori "$trimmedName" berhasil ditambahkan.',
            ),
            backgroundColor: AppColors.income,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan kategori: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = CategoryIconHelper.getColor(_selectedColor);
    final iconData = CategoryIconHelper.getIcon(_selectedIcon);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header ─────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _isEditMode ? 'Ubah Kategori' : 'Tambah Kategori Baru',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Pratinjau Kategori (Live Preview) ───────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: color.withAlpha(25),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withAlpha(80)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: color,
                          child: Icon(iconData, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _nameController.text.trim().isEmpty
                                    ? 'Nama Kategori'
                                    : _nameController.text.trim(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _type == 'expense'
                                    ? 'Kategori Pengeluaran'
                                    : 'Kategori Pemasukan',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _type == 'expense'
                                      ? AppColors.expense
                                      : AppColors.income,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Jenis Transaksi Toggle ──────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _TypeToggleItem(
                            label: 'Pengeluaran',
                            isSelected: _type == 'expense',
                            selectedColor: AppColors.expense,
                            onTap: widget.category?.isDefault == true
                                ? null
                                : () => setState(() => _type = 'expense'),
                          ),
                        ),
                        Expanded(
                          child: _TypeToggleItem(
                            label: 'Pemasukan',
                            isSelected: _type == 'income',
                            selectedColor: AppColors.income,
                            onTap: widget.category?.isDefault == true
                                ? null
                                : () => setState(() => _type = 'income'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Input Nama Kategori ─────────────────────────
                  Text(
                    'Nama Kategori',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Contoh: Hobi, Skincare, Bonus',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Nama kategori tidak boleh kosong';
                      }
                      if (val.trim().length > 30) {
                        return 'Maksimal 30 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Pemilih Ikon ────────────────────────────────
                  Text(
                    'Pilih Ikon',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 130,
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                      itemCount: CategoryIconHelper.availableIcons.length,
                      itemBuilder: (context, index) {
                        final key = CategoryIconHelper.availableIcons.keys
                            .elementAt(index);
                        final icon = CategoryIconHelper.availableIcons[key]!;
                        final isSelected = key == _selectedIcon;

                        return InkWell(
                          onTap: () => setState(() => _selectedIcon = key),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withAlpha(40)
                                  : AppColors.surfaceVariant.withAlpha(80),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? color : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              icon,
                              size: 20,
                              color: isSelected
                                  ? color
                                  : AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Pemilih Warna ───────────────────────────────
                  Text(
                    'Pilih Warna',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: CategoryIconHelper.availableColors.map((hex) {
                      final itemColor = CategoryIconHelper.getColor(hex);
                      final isSelected = hex == _selectedColor;

                      return InkWell(
                        onTap: () => setState(() => _selectedColor = hex),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: itemColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: itemColor.withAlpha(120),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // ── Tombol Simpan ───────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.pop(context),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveCategory,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(_isEditMode ? 'Simpan' : 'Tambah'),
                        ),
                      ),
                    ],
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

class _TypeToggleItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback? onTap;

  const _TypeToggleItem({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
