// ============================================================
// main.dart — App Entry Point + Bottom Navigation
// ============================================================
//
// Navigation structure:
//   Tab 0 → Dashboard    (portfolio summary + heatmap)
//   Tab 1 → Tax          (capital gains estimator)
//   Tab 2 → SIP          (rupee-cost averaging backtester)
//   Tab 3 → Family       (aggregated family net worth)
//   Tab 4 → News         (headlines + sentiment)
// ============================================================

import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/tax/screens/tax_screen.dart';
import 'features/sip/screens/sip_screen.dart';
import 'features/family/screens/family_screen.dart';
import 'features/news/screens/news_screen.dart';


void main() => runApp(const MarketApp());


class MarketApp extends StatelessWidget {
  const MarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:                   'Market — Portfolio Dashboard',
      debugShowCheckedModeBanner: false,
      theme:                   AppTheme.lightTheme,
      home:                    const HomeScreen(),
    );
  }
}


/// HomeScreen holds the BottomNavigationBar and swaps content
/// based on the selected tab.  IndexedStack keeps all screens
/// alive in memory so they don't reload when switching tabs.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Screens instantiated once — IndexedStack keeps them alive
  static const _screens = [
    DashboardScreen(),
    TaxScreen(),
    SipScreen(),
    FamilyScreen(),
    NewsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack: only the child at [_currentIndex] is visible,
      // but ALL children stay in the widget tree (no state loss on tab switch)
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon:  Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon:  Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Tax',
          ),
          NavigationDestination(
            icon:  Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
            label: 'SIP',
          ),
          NavigationDestination(
            icon:  Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Family',
          ),
          NavigationDestination(
            icon:  Icon(Icons.newspaper_outlined),
            selectedIcon: Icon(Icons.newspaper),
            label: 'News',
          ),
        ],
      ),
    );
  }
}
