// ============================================================
// main.dart — Entry Point of the Flutter App
// ============================================================
//
// Every Flutter app starts here. Think of this as the "index.js"
// of a web app — it's where everything boots up.
//
// Flutter is built with the Dart programming language.
// Dart looks a lot like Java/JavaScript/TypeScript.
// ============================================================

// Import the Flutter Material Design library.
// Material Design is Google's design system (buttons, colors, layouts, etc.)
// Without this import, you'd have no widgets (UI components) to use.
import 'package:flutter/material.dart';

// Import our own dashboard screen file (we'll create this next)
import 'dashboard_screen.dart';


// ============================================================
// main() — The very first function Flutter runs
//
// "void" means this function returns nothing.
// "main()" is the standard entry point in Dart (like main() in C/Java).
// ============================================================
void main() {
  // runApp() tells Flutter to take our widget and display it on screen.
  // Everything in Flutter is a "widget" — buttons, text, layouts, all widgets.
  runApp(const MarketApp());
}


// ============================================================
// MarketApp — The Root Widget
//
// A "Widget" is a UI component. Think of it like a React component.
// "StatelessWidget" means this widget has NO changing state —
// it just renders the same thing every time.
//
// "extends" means MarketApp inherits from StatelessWidget.
// ============================================================
class MarketApp extends StatelessWidget {
  // "const" constructor: this widget never changes, so we mark it const
  // for performance optimization.
  const MarketApp({super.key});

  // build() is the method Flutter calls to draw this widget on screen.
  // It must return a Widget.
  // "BuildContext context" carries info about where this widget lives in the tree.
  @override
  Widget build(BuildContext context) {
    // MaterialApp is the top-level widget that sets up:
    //   - the app title (shown in task switchers)
    //   - the theme (colors, fonts)
    //   - the home screen (which widget to show first)
    return MaterialApp(
      // Title shown in the OS task switcher
      title: 'Market — Portfolio Dashboard',

      // debugShowCheckedModeBanner: removes the red "DEBUG" banner
      // that Flutter shows in the top-right corner during development
      debugShowCheckedModeBanner: false,

      // theme: sets the visual style for the whole app
      theme: ThemeData(
        // colorScheme: defines the primary color palette
        // Colors.indigo gives us a dark blue/purple theme
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),

        // useMaterial3: use the latest version of Material Design (M3)
        useMaterial3: true,
      ),

      // home: the first screen to show when the app launches
      // DashboardScreen is defined in dashboard_screen.dart
      home: const DashboardScreen(),
    );
  }
}
