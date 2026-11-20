import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dompetku/data/models/category_model.dart';
import 'package:dompetku/features/categories/controllers/category_controller.dart';
import 'package:dompetku/features/categories/screens/categories_screen.dart';
import 'package:dompetku/features/categories/widgets/add_edit_category_dialog.dart';

void main() {
  final dummyCategories = [
    CategoryModel(
      id: 1,
      name: 'Gaji Pokok',
      type: 'income',
      icon: 'work_outline',
      color: '#2E7D32',
      isDefault: true,
      isArchived: false,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: 2,
      name: 'Makanan & Jajan',
      type: 'expense',
      icon: 'restaurant',
      color: '#D32F2F',
      isDefault: false,
      isArchived: false,
      createdAt: DateTime.now(),
    ),
  ];

  Widget buildScreen({List<CategoryModel>? categories}) {
    return ProviderScope(
      overrides: [
        categoryManagementListProvider.overrideWith((ref) async {
          final type = ref.watch(categoryTypeFilterProvider);
          final list = categories ?? dummyCategories;
          if (type == null) return list;
          return list.where((c) => c.type == type).toList();
        }),
        categoryInUseProvider.overrideWith((ref, id) async => false),
      ],
      child: const MaterialApp(home: CategoriesScreen()),
    );
  }

  testWidgets('Menampilkan daftar kategori beserta badge dan filter', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();
    await tester.pumpAndSettle();

    // Verifikasi judul dan filter chip
    expect(find.text('Kelola Kategori'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Pengeluaran'), findsWidgets);
    expect(find.text('Pemasukan'), findsWidgets);

    // Verifikasi item kategori
    expect(find.text('Gaji Pokok'), findsOneWidget);
    expect(find.text('Bawaan'), findsOneWidget);
    expect(find.text('Makanan & Jajan'), findsOneWidget);
    expect(find.text('Kustom'), findsOneWidget);

    // Verifikasi FAB
    expect(find.text('Kategori Baru'), findsOneWidget);
  });

  testWidgets('Membuka modal dialog Tambah Kategori Baru saat FAB ditekan', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kategori Baru'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(AddEditCategoryDialog), findsOneWidget);
    expect(find.text('Tambah Kategori Baru'), findsOneWidget);
    expect(find.text('Nama Kategori'), findsWidgets);
    expect(find.text('Pilih Ikon'), findsOneWidget);
    expect(find.text('Pilih Warna'), findsOneWidget);
  });
}
