// ============================================================
// main.dart — App Entry Point
// ============================================================
//
// This file stays intentionally minimal.
// It just boots the app and points to the dashboard screen.
// All other logic lives in features/ and core/.
// ============================================================

import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/screens/dashboard_screen.dart';


void main() {
  runApp(const MarketApp());
}


class MarketApp extends StatelessWidget {
  const MarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Market — Portfolio Dashboard',
      debugShowCheckedModeBanner: false,
      // Theme is now defined in core/theme/app_theme.dart
      theme: AppTheme.lightTheme,
      // Entry screen is the dashboard
      home: const DashboardScreen(),
    );
  }
}
