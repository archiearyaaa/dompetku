import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/category_icon_helper.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../shared/widgets/empty_state.dart';
import '../controllers/transaction_controller.dart';
import 'add_edit_transaction_screen.dart';

/// Halaman Riwayat dan Daftar Transaksi Keuangan dengan Pencarian & Filter Kategori.
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(transactionSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _searchController.clear();
    ref.read(transactionSearchQueryProvider.notifier).clear();
    ref.read(transactionCategoryFilterProvider.notifier).setCategory(null);
  }

  @override
  Widget build(BuildContext context) {
    final activeType = ref.watch(transactionTypeFilterProvider);
    final activeCategoryId = ref.watch(transactionCategoryFilterProvider);
    final searchQuery = ref.watch(transactionSearchQueryProvider);
    final transactionsAsync = ref.watch(transactionsListProvider);
    final categoriesAsync = ref.watch(categoriesProvider(activeType));

    final isFiltered =
        activeCategoryId != null || searchQuery.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi')),
      body: Column(
        children: [
          // ── 1. Kolom Pencarian Transaksi ───────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.pagePaddingH,
              12,
              AppConstants.pagePaddingH,
              6,
            ),
            color: Theme.of(context).colorScheme.surface,
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                ref.read(transactionSearchQueryProvider.notifier).setQuery(val);
              },
              decoration: InputDecoration(
                hintText: 'Cari catatan atau nama kategori...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(transactionSearchQueryProvider.notifier)
                              .clear();
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                filled: true,
                fillColor: AppColors.surfaceVariant.withAlpha(90),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── 2. Filter Bar: Jenis Transaksi & Kategori ──────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.pagePaddingH,
              vertical: 8,
            ),
            color: Theme.of(context).colorScheme.surface,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Filter Jenis
                  _FilterChip(
                    label: 'Semua',
                    isSelected: activeType == null,
                    onSelected: () {
                      ref
                          .read(transactionTypeFilterProvider.notifier)
                          .setFilter(null);
                      ref
                          .read(transactionCategoryFilterProvider.notifier)
                          .setCategory(null);
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Pemasukan',
                    isSelected: activeType == 'income',
                    selectedColor: AppColors.income,
                    onSelected: () {
                      ref
                          .read(transactionTypeFilterProvider.notifier)
                          .setFilter('income');
                      ref
                          .read(transactionCategoryFilterProvider.notifier)
                          .setCategory(null);
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Pengeluaran',
                    isSelected: activeType == 'expense',
                    selectedColor: AppColors.expense,
                    onSelected: () {
                      ref
                          .read(transactionTypeFilterProvider.notifier)
                          .setFilter('expense');
                      ref
                          .read(transactionCategoryFilterProvider.notifier)
                          .setCategory(null);
                    },
                  ),

                  // Divider vertikal
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    height: 20,
                    width: 1,
                    color: AppColors.divider,
                  ),

                  // Dropdown / Pemilih Kategori
                  categoriesAsync.when(
                    data: (categories) {
                      final selectedCategory = categories
                          .where((c) => c.id == activeCategoryId)
                          .firstOrNull;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: activeCategoryId != null
                              ? AppColors.primary.withAlpha(25)
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: activeCategoryId != null
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 1.2,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int?>(
                            value: activeCategoryId,
                            isDense: true,
                            hint: Text(
                              selectedCategory?.name ?? 'Semua Kategori',
                              style: TextStyle(
                                fontSize: 13,
                                color: activeCategoryId != null
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontWeight: activeCategoryId != null
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            icon: Icon(
                              Icons.arrow_drop_down,
                              size: 18,
                              color: activeCategoryId != null
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('Semua Kategori'),
                              ),
                              ...categories.map((cat) {
                                return DropdownMenuItem<int?>(
                                  value: cat.id,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        CategoryIconHelper.getIcon(cat.icon),
                                        size: 16,
                                        color: CategoryIconHelper.getColor(
                                          cat.color,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(cat.name),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            onChanged: (val) {
                              ref
                                  .read(
                                    transactionCategoryFilterProvider.notifier,
                                  )
                                  .setCategory(val);
                            },
                          ),
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, stack) => const SizedBox.shrink(),
                  ),

                  if (isFiltered) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 18),
                      tooltip: 'Reset Filter',
                      onPressed: _clearFilters,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // ── 3. Daftar Transaksi ─────────────────────────────────
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  if (isFiltered) {
                    return EmptyState(
                      icon: Icons.search_off_outlined,
                      title: 'Tidak Ditemukan',
                      description:
                          'Tidak ada transaksi yang sesuai dengan kata kunci atau filter kategori yang dipilih.',
                      actionLabel: 'Reset Pencarian',
                      onAction: _clearFilters,
                    );
                  }

                  return EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'Belum Ada Transaksi',
                    description: activeType == null
                        ? 'Catat transaksi pemasukan atau pengeluaran pertama Anda.'
                        : 'Tidak ada transaksi dengan filter ${activeType == 'income' ? 'Pemasukan' : 'Pengeluaran'}.',
                    actionLabel: '+ Catat Transaksi',
                    onAction: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditTransactionScreen(
                            initialType: activeType ?? 'expense',
                          ),
                        ),
                      );
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(transactionsListProvider);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.pagePaddingH,
                      vertical: 12,
                    ),
                    itemCount: transactions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = transactions[index];
                      return _TransactionListItem(
                        transaction: item,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddEditTransactionScreen(transaction: item),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
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
                        'Gagal memuat transaksi: $e',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () =>
                            ref.invalidate(transactionsListProvider),
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_transactions',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditTransactionScreen(
                initialType: activeType ?? 'expense',
              ),
            ),
          );
        },
        tooltip: 'Catat Transaksi',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? selectedColor;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.selectedColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = selectedColor ?? AppColors.primary;

    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withAlpha(35)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? activeColor : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onTap;

  const _TransactionListItem({required this.transaction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = transaction.isIncome;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final categoryName = transaction.category?.name ?? 'Tanpa Kategori';
    final categoryIcon = CategoryIconHelper.getIcon(transaction.category?.icon);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              // Icon Kategori
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(categoryIcon, color: color, size: 20),
              ),
              const SizedBox(width: 12),

              // Detail Kategori, Catatan, dan Tanggal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (transaction.note != null &&
                        transaction.note!.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        transaction.note!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      DateFormatter.formatRelative(transaction.occurredAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary.withAlpha(200),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Nominal Rupiah Bertanda (+/-)
              Text(
                CurrencyFormatter.formatSigned(
                  transaction.amount,
                  isIncome: isIncome,
                ),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
