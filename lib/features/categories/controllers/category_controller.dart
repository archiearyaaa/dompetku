import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/category_model.dart';
import '../../transactions/controllers/transaction_controller.dart';

/// Notifier untuk filter jenis kategori pada layar Manajemen Kategori.
class CategoryTypeFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setFilter(String? filter) {
    state = filter;
  }
}

final categoryTypeFilterProvider =
    NotifierProvider<CategoryTypeFilterNotifier, String?>(() {
      return CategoryTypeFilterNotifier();
    });

/// Notifier untuk toggle apakah kategori yang diarsipkan ikut ditampilkan.
class CategoryIncludeArchivedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
  }

  void set(bool value) {
    state = value;
  }
}

final categoryIncludeArchivedProvider =
    NotifierProvider<CategoryIncludeArchivedNotifier, bool>(() {
      return CategoryIncludeArchivedNotifier();
    });

/// Provider daftar kategori untuk layar Manajemen Kategori.
final categoryManagementListProvider = FutureProvider<List<CategoryModel>>((
  ref,
) async {
  final repository = ref.watch(categoryRepositoryProvider);
  final type = ref.watch(categoryTypeFilterProvider);
  final includeArchived = ref.watch(categoryIncludeArchivedProvider);

  return await repository.getCategories(
    type: type,
    includeArchived: includeArchived,
  );
});

/// Provider untuk mengecek apakah suatu kategori sedang digunakan oleh transaksi.
final categoryInUseProvider = FutureProvider.family<bool, int>((
  ref,
  categoryId,
) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.isCategoryInUse(categoryId);
});

/// Controller untuk operasi aksi CRUD kategori.
class CategoryActionController {
  final Ref _ref;

  CategoryActionController(this._ref);

  Future<int> addCategory(CategoryModel category) async {
    final repo = _ref.read(categoryRepositoryProvider);
    final id = await repo.addCategory(category);
    _invalidateAll();
    return id;
  }

  Future<int> updateCategory(CategoryModel category) async {
    final repo = _ref.read(categoryRepositoryProvider);
    final count = await repo.updateCategory(category);
    _invalidateAll();
    return count;
  }

  Future<int> archiveCategory(int id) async {
    final repo = _ref.read(categoryRepositoryProvider);
    final count = await repo.archiveCategory(id);
    _invalidateAll();
    return count;
  }

  Future<int> unarchiveCategory(int id) async {
    final repo = _ref.read(categoryRepositoryProvider);
    final count = await repo.unarchiveCategory(id);
    _invalidateAll();
    return count;
  }

  Future<int> deleteCategory(int id) async {
    final repo = _ref.read(categoryRepositoryProvider);
    final count = await repo.deleteCategory(id);
    _invalidateAll();
    return count;
  }

  void _invalidateAll() {
    _ref.invalidate(categoryManagementListProvider);
    _ref.invalidate(categoriesProvider(null));
    _ref.invalidate(categoriesProvider('income'));
    _ref.invalidate(categoriesProvider('expense'));
    _ref.invalidate(transactionsListProvider);
    _ref.invalidate(dashboardSummaryProvider);
  }
}

final categoryActionControllerProvider = Provider<CategoryActionController>((
  ref,
) {
  return CategoryActionController(ref);
});
