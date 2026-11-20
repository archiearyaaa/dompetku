import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';

/// Entry point aplikasi Dompetku.
///
/// Menginisialisasi locale Indonesia dan membungkus aplikasi
/// dengan [ProviderScope] untuk state management Riverpod.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi data locale Indonesia untuk format tanggal.
  await initializeDateFormatting(AppConstants.localeId, null);

  runApp(const ProviderScope(child: DompetkuApp()));
}
