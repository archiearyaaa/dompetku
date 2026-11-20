import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../categories/screens/categories_screen.dart';
import '../controllers/theme_controller.dart';

/// Halaman Pengaturan Aplikasi Dompetku.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.read(themeModeProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pilih Tema Aplikasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                currentTheme == ThemeMode.system
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: currentTheme == ThemeMode.system
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              title: const Text('Ikuti Sistem'),
              onTap: () {
                ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.system);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: Icon(
                currentTheme == ThemeMode.light
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: currentTheme == ThemeMode.light
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              title: const Text('Tema Terang'),
              onTap: () {
                ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.light);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: Icon(
                currentTheme == ThemeMode.dark
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: currentTheme == ThemeMode.dark
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              title: const Text('Tema Gelap (Dark Mode)'),
              onTap: () {
                ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.dark);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Mengikuti Sistem';
      case ThemeMode.light:
        return 'Tema Terang';
      case ThemeMode.dark:
        return 'Tema Gelap';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final debtReminderEnabled = ref.watch(debtReminderProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // ── 1. Kartu Profil Aplikasi & Copyright ─────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF1E3A5F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(40),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppConstants.appName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Versi ${AppConstants.appVersion}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Copyright by Archie Arya Manggala',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── 2. Informasi Dasar Aplikasi ───────────────────
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.info_outline, color: AppColors.secondary),
                  title: Text('Tentang Dompetku'),
                  subtitle: Text(
                    'Aplikasi Keuangan Pribadi Offline-First • v1.0.0',
                  ),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.storage_outlined,
                    color: AppColors.secondary,
                  ),
                  title: Text('Penyimpanan Data'),
                  subtitle: Text('SQLite Offline-First (Lokal di perangkat)'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── 3. Master Data & Kategori ─────────────────────
          Text(
            'Master Data',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(
                Icons.category_outlined,
                color: AppColors.secondary,
              ),
              title: const Text('Kelola Kategori'),
              subtitle: const Text('Tambah, ubah, dan atur kategori transaksi'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // ── 4. Preferensi Tampilan & Tema ─────────────────
          Text(
            'Tampilan & Tema',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(
                Icons.palette_outlined,
                color: AppColors.secondary,
              ),
              title: const Text('Tema Aplikasi'),
              subtitle: Text(_getThemeLabel(themeMode)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showThemeDialog(context, ref),
            ),
          ),
          const SizedBox(height: 20),

          // ── 4. Pengingat & Notifikasi ─────────────────────
          Text(
            'Pengingat & Notifikasi',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            margin: EdgeInsets.zero,
            child: SwitchListTile(
              secondary: const Icon(
                Icons.notifications_active_outlined,
                color: AppColors.secondary,
              ),
              title: const Text('Pengingat Jatuh Tempo'),
              subtitle: const Text(
                'Peringatan untuk utang & piutang yang mendekati batas waktu',
              ),
              value: debtReminderEnabled,
              onChanged: (val) {
                ref.read(debtReminderProvider.notifier).setEnabled(val);
              },
            ),
          ),
          const SizedBox(height: 20),

          // ── 5. Hak Cipta & Informasi Pengembang ───────────
          Text(
            'Hak Cipta & Pengembang',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(
                    Icons.person_outline,
                    color: AppColors.secondary,
                  ),
                  title: Text('Pengembang'),
                  subtitle: Text(AppConstants.appAuthor),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.copyright_outlined,
                    color: AppColors.secondary,
                  ),
                  title: const Text('Hak Cipta'),
                  subtitle: Text(AppConstants.copyright),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Footer Text
          Center(
            child: Column(
              children: [
                Text(
                  '${AppConstants.appName} v${AppConstants.appVersion}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Copyright by Archie Arya Manggala',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
