import 'package:flutter/material.dart';

/// Helper untuk pemetaan ikon dan palet warna kategori keuangan Dompetku.
class CategoryIconHelper {
  CategoryIconHelper._();

  /// Daftar pilihan nama ikon kategori yang didukung beserta deskripsinya.
  static const Map<String, IconData> availableIcons = {
    'restaurant': Icons.restaurant_outlined,
    'directions_car': Icons.directions_car_outlined,
    'shopping_bag': Icons.shopping_bag_outlined,
    'receipt_long': Icons.receipt_long_outlined,
    'sports_esports': Icons.sports_esports_outlined,
    'medical_services': Icons.medical_services_outlined,
    'school': Icons.school_outlined,
    'work_outline': Icons.work_outline,
    'computer': Icons.computer_outlined,
    'card_giftcard': Icons.card_giftcard_outlined,
    'trending_up': Icons.trending_up,
    'home': Icons.home_outlined,
    'fitness_center': Icons.fitness_center_outlined,
    'flight': Icons.flight_outlined,
    'pets': Icons.pets_outlined,
    'volunteer_activism': Icons.volunteer_activism_outlined,
    'savings': Icons.savings_outlined,
    'local_cafe': Icons.local_cafe_outlined,
    'local_grocery_store': Icons.local_grocery_store_outlined,
    'movie': Icons.movie_outlined,
    'category_outlined': Icons.category_outlined,
  };

  /// Daftar palet warna preset untuk kategori (Hex string).
  static const List<String> availableColors = [
    '#142D4E', // Midnight Navy
    '#2878D0', // Blue
    '#2E7D32', // Emerald Green
    '#D32F2F', // Crimson Red
    '#F57C00', // Amber Orange
    '#7B1FA2', // Purple
    '#00897B', // Teal
    '#C2185B', // Pink
    '#3949AB', // Indigo
    '#6D4C41', // Brown
    '#546E7A', // Slate Blue
    '#FBC02D', // Golden Yellow
  ];

  /// Mengonversi nama ikon menjadi [IconData].
  static IconData getIcon(String? iconName) {
    if (iconName == null) return Icons.category_outlined;
    return availableIcons[iconName] ?? Icons.category_outlined;
  }

  /// Mengonversi string hex warna (#RRGGBB) menjadi [Color].
  static Color getColor(
    String? colorHex, {
    Color defaultColor = const Color(0xFF2878D0),
  }) {
    if (colorHex == null || colorHex.isEmpty) return defaultColor;
    try {
      var hex = colorHex.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return defaultColor;
    }
  }
}
