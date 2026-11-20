import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _themeModeKey = 'app_theme_mode';
const String _debtReminderKey = 'debt_reminder_enabled';

/// Notifier untuk mengelola dan menyimpan preferensi tema (Light, Dark, System).
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadFromPreferences();
    return ThemeMode.system;
  }

  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeString = prefs.getString(_themeModeKey);
      if (modeString != null) {
        state = ThemeMode.values.firstWhere(
          (e) => e.name == modeString,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (_) {
      // Abaikan jika error (misal di widget test tanpa mock)
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode.name);
    } catch (_) {
      // Abaikan error penyimpanan
    }
  }
}

/// Provider tema aplikasi yang aktif.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

/// Notifier untuk mengelola preferensi pengingat jatuh tempo utang & piutang lokal.
class DebtReminderNotifier extends Notifier<bool> {
  @override
  bool build() {
    _loadFromPreferences();
    return true; // Default aktif
  }

  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(_debtReminderKey);
      if (enabled != null) {
        state = enabled;
      }
    } catch (_) {}
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_debtReminderKey, enabled);
    } catch (_) {}
  }
}

/// Provider pengaturan pengingat jatuh tempo utang & piutang.
final debtReminderProvider = NotifierProvider<DebtReminderNotifier, bool>(() {
  return DebtReminderNotifier();
});
