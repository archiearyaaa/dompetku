import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/category_icon_helper.dart';
import '../../../data/models/category_model.dart';
import '../../../shared/widgets/empty_state.dart';
import '../controllers/category_controller.dart';
import '../widgets/add_edit_category_dialog.dart';

/// Halaman Manajemen Kategori Transaksi (Lihat, Tambah, Ubah, Arsip, Hapus).
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.read(categoryTypeFilterProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddEditCategoryDialog(defaultType: activeFilter),
    );
  }

  void _showEditCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    CategoryModel category,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddEditCategoryDialog(category: category),
    );
  }

  Future<void> _handleDeleteCategory(
    BuildContext context,
    WidgetRef ref,
    CategoryModel category,
  ) async {
    final controller = ref.read(categoryActionControllerProvider);

    // Jika kategori bawaan, lindungi dari penghapusan permanen
    if (category.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Kategori bawaan sistem tidak dapat dihapus. Anda dapat mengarsipkannya.',
          ),
          backgroundColor: AppColors.textSecondary,
        ),
      );
      return;
    }

    // Cek apakah kategori digunakan dalam transaksi
    final inUse = await ref.read(categoryInUseProvider(category.id!).future);

    if (!context.mounted) return;

    if (inUse) {
      // Tampilkan opsi pengarsipan karena kategori sedang dipakai
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Kategori Sedang Digunakan'),
          content: Text(
            'Kategori "${category.name}" telah digunakan dalam riwayat transaksi Anda. '
            'Untuk menjaga keutuhan data keuangan, kategori ini tidak dapat dihapus permanen. '
            'Apakah Anda ingin mengarsipkannya saja?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await controller.archiveCategory(category.id!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Kategori "${category.name}" berhasil diarsipkan.',
                      ),
                      backgroundColor: AppColors.income,
                    ),
                  );
                }
              },
              child: const Text('Arsipkan'),
            ),
          ],
        ),
      );
      return;
    }

    // Jika belum pernah digunakan, boleh dihapus permanen
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kategori?'),
        content: Text(
          'Kategori "${category.name}" belum digunakan dan akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus Permanen'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await controller.deleteCategory(category.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kategori "${category.name}" berhasil dihapus.'),
              backgroundColor: AppColors.expense,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(categoryTypeFilterProvider);
    final includeArchived = ref.watch(categoryIncludeArchivedProvider);
    final categoriesAsync = ref.watch(categoryManagementListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
        actions: [
          IconButton(
            icon: Icon(
              includeArchived
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            tooltip: includeArchived
                ? 'Sembunyikan Kategori Diarsipkan'
                : 'Tampilkan Kategori Diarsipkan',
            onPressed: () {
              ref.read(categoryIncludeArchivedProvider.notifier).toggle();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filter Chips: Semua / Pengeluaran / Pemasukan ──────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.pagePaddingH,
              vertical: 12,
            ),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                _FilterChipItem(
                  label: 'Semua',
                  isSelected: activeFilter == null,
                  onSelected: () => ref
                      .read(categoryTypeFilterProvider.notifier)
                      .setFilter(null),
                ),
                const SizedBox(width: 8),
                _FilterChipItem(
                  label: 'Pengeluaran',
                  isSelected: activeFilter == 'expense',
                  selectedColor: AppColors.expense,
                  onSelected: () => ref
                      .read(categoryTypeFilterProvider.notifier)
                      .setFilter('expense'),
                ),
                const SizedBox(width: 8),
                _FilterChipItem(
                  label: 'Pemasukan',
                  isSelected: activeFilter == 'income',
                  selectedColor: AppColors.income,
                  onSelected: () => ref
                      .read(categoryTypeFilterProvider.notifier)
                      .setFilter('income'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // ── Daftar Kategori ────────────────────────────────────
          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return EmptyState(
                    icon: Icons.category_outlined,
                    title: 'Belum Ada Kategori',
                    description: activeFilter == null
                        ? 'Belum ada kategori yang tersimpan.'
                        : 'Tidak ada kategori ${activeFilter == 'expense' ? 'pengeluaran' : 'pemasukan'}.',
                    actionLabel: '+ Tambah Kategori',
                    onAction: () => _showAddCategoryDialog(context, ref),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(categoryManagementListProvider);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.pagePaddingH,
                      vertical: 16,
                    ),
                    itemCount: categories.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = categories[index];
                      return _CategoryCard(
                        category: item,
                        onEdit: () =>
                            _showEditCategoryDialog(context, ref, item),
                        onDelete: () =>
                            _handleDeleteCategory(context, ref, item),
                        onToggleArchive: () async {
                          final controller = ref.read(
                            categoryActionControllerProvider,
                          );
                          if (item.isArchived) {
                            await controller.unarchiveCategory(item.id!);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Kategori "${item.name}" diaktifkan kembali.',
                                  ),
                                  backgroundColor: AppColors.income,
                                ),
                              );
                            }
                          } else {
                            await controller.archiveCategory(item.id!);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Kategori "${item.name}" berhasil diarsipkan.',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
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
                        'Gagal memuat kategori: $err',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () =>
                            ref.invalidate(categoryManagementListProvider),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Kategori Baru'),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleArchive;

  const _CategoryCard({
    required this.category,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleArchive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = CategoryIconHelper.getColor(category.color);
    final iconData = CategoryIconHelper.getIcon(category.icon);

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: category.isArchived
              ? AppColors.textSecondary.withAlpha(40)
              : Colors.transparent,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // ── Ikon Kategori ────────────────────────────────────
            CircleAvatar(
              radius: 22,
              backgroundColor: category.isArchived
                  ? AppColors.textSecondary.withAlpha(50)
                  : color.withAlpha(30),
              child: Icon(
                iconData,
                color: category.isArchived ? AppColors.textSecondary : color,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // ── Info Kategori ────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: category.isArchived
                          ? TextDecoration.lineThrough
                          : null,
                      color: category.isArchived
                          ? AppColors.textSecondary
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Badge Jenis
                      _BadgePill(
                        label: category.type == 'expense'
                            ? 'Pengeluaran'
                            : 'Pemasukan',
                        color: category.type == 'expense'
                            ? AppColors.expense
                            : AppColors.income,
                      ),
                      const SizedBox(width: 6),

                      // Badge Default/Kustom
                      _BadgePill(
                        label: category.isDefault ? 'Bawaan' : 'Kustom',
                        color: category.isDefault
                            ? AppColors.secondary
                            : AppColors.primary,
                      ),

                      if (category.isArchived) ...[
                        const SizedBox(width: 6),
                        const _BadgePill(
                          label: 'Diarsipkan',
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // ── Menu Aksi ────────────────────────────────────────
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (val) {
                switch (val) {
                  case 'edit':
                    onEdit();
                    break;
                  case 'archive':
                    onToggleArchive();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 20),
                      SizedBox(width: 10),
                      Text('Ubah'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'archive',
                  child: Row(
                    children: [
                      Icon(
                        category.isArchived
                            ? Icons.unarchive_outlined
                            : Icons.archive_outlined,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(category.isArchived ? 'Buka Arsip' : 'Arsipkan'),
                    ],
                  ),
                ),
                if (!category.isDefault)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: AppColors.error,
                        ),
                        SizedBox(width: 10),
                        Text('Hapus', style: TextStyle(color: AppColors.error)),
                      ],
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

class _BadgePill extends StatelessWidget {
  final String label;
  final Color color;

  const _BadgePill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onSelected;

  const _FilterChipItem({
    required this.label,
    required this.isSelected,
    this.selectedColor = AppColors.primary,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: selectedColor.withAlpha(40),
      checkmarkColor: selectedColor,
      labelStyle: TextStyle(
        color: isSelected ? selectedColor : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? selectedColor : AppColors.surfaceVariant,
        ),
      ),
    );
  }
}
