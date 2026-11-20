import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dompetku/features/settings/screens/settings_screen.dart';

void main() {
  testWidgets(
    'Menampilkan halaman Pengaturan dan Copyright by Archie Arya Manggala',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SettingsScreen())),
      );
      await tester.pumpAndSettle();

      // Verifikasi judul dan nama aplikasi
      expect(find.text('Pengaturan'), findsOneWidget);
      expect(find.text('Dompetku'), findsOneWidget);

      // Verifikasi copyright sesuai permintaan pengguna di header card
      expect(find.text('Copyright by Archie Arya Manggala'), findsWidgets);

      // Verifikasi section informasi dasar
      expect(find.text('Tentang Dompetku'), findsOneWidget);

      // Verifikasi section Master Data Kelola Kategori
      expect(find.text('Kelola Kategori'), findsOneWidget);

      // Verifikasi pengaturan tema
      await tester.scrollUntilVisible(
        find.text('Tema Aplikasi'),
        100,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('Tema Aplikasi'), findsOneWidget);
      await tester.tap(find.text('Tema Aplikasi'));
      await tester.pumpAndSettle();

      expect(find.text('Pilih Tema Aplikasi'), findsOneWidget);
      expect(find.text('Ikuti Sistem'), findsOneWidget);
      expect(find.text('Tema Terang'), findsOneWidget);
      expect(find.text('Tema Gelap (Dark Mode)'), findsOneWidget);

      // Tutup dialog
      await tester.tap(find.text('Tema Gelap (Dark Mode)'));
      await tester.pumpAndSettle();

      // Verifikasi switch pengingat setelah scroll jika diperlukan
      await tester.scrollUntilVisible(
        find.text('Pengingat Jatuh Tempo'),
        100,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('Pengingat Jatuh Tempo'), findsOneWidget);
    },
  );
}
