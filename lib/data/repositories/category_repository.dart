import '../datasources/category_datasource.dart';
import '../models/category_model.dart';

/// Repository untuk mengelola akses data kategori.
class CategoryRepository {
  final CategoryDatasource _datasource;

  CategoryRepository({CategoryDatasource? datasource})
    : _datasource = datasource ?? CategoryDatasource();

  Future<List<CategoryModel>> getCategories({
    String? type,
    bool includeArchived = false,
  }) {
    return _datasource.getCategories(
      type: type,
      includeArchived: includeArchived,
    );
  }

  Future<CategoryModel?> getCategoryById(int id) {
    return _datasource.getCategoryById(id);
  }

  Future<int> addCategory(CategoryModel category) {
    return _datasource.insertCategory(category);
  }

  Future<int> updateCategory(CategoryModel category) {
    return _datasource.updateCategory(category);
  }

  Future<int> archiveCategory(int id) {
    return _datasource.archiveCategory(id);
  }

  Future<int> unarchiveCategory(int id) {
    return _datasource.unarchiveCategory(id);
  }

  Future<bool> isCategoryInUse(int id) {
    return _datasource.isCategoryInUse(id);
  }

  Future<int> deleteCategory(int id) {
    return _datasource.deleteCategory(id);
  }
}
