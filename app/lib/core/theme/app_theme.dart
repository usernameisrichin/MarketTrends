// ============================================================
// core/theme/app_theme.dart — App Visual Theme
// ============================================================
//
// Centralizing the theme means all colors and styles come from
// one place. To change the look of the entire app, you edit
// this file — nothing else.
// ============================================================

import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  /// The main theme used by MaterialApp
  static ThemeData get lightTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      );
}
