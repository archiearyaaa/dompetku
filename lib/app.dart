import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/screens/main_navigation_screen.dart';
import 'features/settings/controllers/theme_controller.dart';

/// Widget root aplikasi Dompetku.
///
/// Mengatur [MaterialApp] dengan tema dinamis (Light & Dark Mode) dan navigasi utama.
class DompetkuApp extends ConsumerWidget {
  const DompetkuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const MainNavigationScreen(),
    );
  }
}
