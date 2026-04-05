// ============================================================
// dashboard_screen.dart — The Main Portfolio Dashboard UI
// ============================================================
//
// This file contains the DashboardScreen widget.
// It shows your portfolio summary and a list of assets.
//
// It also fetches data from the FastAPI backend we built.
// ============================================================

// Flutter UI library (widgets, colors, etc.)
import 'package:flutter/material.dart';

// "dart:convert" gives us jsonDecode() — converts JSON text → Dart Map
import 'dart:convert';

// "http" package lets us make HTTP GET requests to our API
// We named the import "http" so we call it as: http.get(...)
import 'package:http/http.dart' as http;


// ============================================================
// URL of the FastAPI backend
//
// When running Flutter on a physical Android device or emulator,
// use 10.0.2.2 instead of localhost (Android's way to reach the host machine).
//
// For iOS simulator and web: localhost works fine.
// For real devices on the same WiFi: use your computer's local IP (e.g. 192.168.x.x).
// ============================================================
const String kApiUrl = 'http://localhost:8000/portfolio';


// ============================================================
// DashboardScreen — A StatefulWidget
//
// "StatefulWidget" means this widget CAN change over time.
// When we fetch data from the API, the screen needs to update.
// That's why we use StatefulWidget instead of StatelessWidget.
//
// A StatefulWidget has TWO parts:
//   1. The widget class itself (DashboardScreen) — stays constant
//   2. The State class (_DashboardScreenState) — holds the changing data
// ============================================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  // createState() links this widget to its State class
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}


// ============================================================
// _DashboardScreenState — Where the logic and changing data lives
//
// The underscore "_" means this class is private to this file.
// "State<DashboardScreen>" means it manages the state of DashboardScreen.
// ============================================================
class _DashboardScreenState extends State<DashboardScreen> {

  // ── State Variables ────────────────────────────────────────
  // These are the pieces of data that can change and cause a UI update.

  // "bool" = true/false. isLoading tracks whether we're fetching data.
  bool isLoading = false;

  // "String?" = a String that might be null.
  // Holds an error message if the API call fails.
  String? errorMessage;

  // "Map<String, dynamic>?" = a dictionary (key → value pairs), or null.
  // This holds the full portfolio JSON response from the API.
  Map<String, dynamic>? portfolioData;


  // ── fetchPortfolio() ───────────────────────────────────────
  // This function calls our FastAPI backend and loads the data.
  //
  // "async" means this function runs asynchronously — it won't
  // block the UI while waiting for the network response.
  //
  // "Future<void>" means it returns a Future (like a Promise in JS)
  // that resolves to nothing (void).
  Future<void> fetchPortfolio() async {
    // setState() tells Flutter: "data is about to change, re-draw the screen"
    // Everything inside setState() runs, then Flutter rebuilds the widget.
    setState(() {
      isLoading = true;      // Show a loading spinner
      errorMessage = null;   // Clear any previous error
    });

    // "try/catch" handles errors gracefully
    // If something goes wrong (no server, timeout, etc.) we catch it
    try {
      // http.get() sends a GET request to the API URL
      // "await" pauses here until the response comes back
      final response = await http.get(Uri.parse(kApiUrl));

      // response.statusCode == 200 means "OK" — success!
      if (response.statusCode == 200) {
        // jsonDecode() converts the JSON string into a Dart Map
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        setState(() {
          portfolioData = data;  // Save the data
          isLoading = false;     // Hide the loading spinner
        });
      } else {
        // Server returned an error (e.g. 404, 500)
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      // Network error — server not running, wrong URL, etc.
      setState(() {
        errorMessage = 'Could not connect to server.\n\nMake sure the backend is running:\nuvicorn main:app --reload';
        isLoading = false;
      });
    }
  }


  // ── build() ───────────────────────────────────────────────
  // Flutter calls this every time state changes to re-draw the UI.
  // It returns a Widget tree describing what to show on screen.
  @override
  Widget build(BuildContext context) {
    // Scaffold is the basic page layout widget.
    // It provides: AppBar (top bar), body (main content), FAB, etc.
    return Scaffold(

      // AppBar = the top bar of the screen
      appBar: AppBar(
        // backgroundColor: the color of the app bar
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        // title: the text shown in the app bar
        title: const Text(
          'Market — Portfolio Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // body: the main content of the screen
      // SingleChildScrollView allows the content to scroll if it's too tall
      body: SingleChildScrollView(
        // Padding adds space around the content (like CSS padding)
        // EdgeInsets.all(16) means 16 pixels on all sides
        padding: const EdgeInsets.all(16),

        // "child" is the widget inside SingleChildScrollView
        // Column stacks widgets vertically (like a div with flex-direction: column)
        child: Column(
          // crossAxisAlignment: how to align children horizontally
          // stretch = make each child as wide as the column
          crossAxisAlignment: CrossAxisAlignment.stretch,

          // children: the list of widgets stacked inside this Column
          children: [

            // ── Header Card ──────────────────────────────────
            _buildHeaderCard(),

            // SizedBox is a blank space widget. height: 16 = 16px gap.
            const SizedBox(height: 16),

            // ── Load Button ───────────────────────────────────
            _buildLoadButton(),

            const SizedBox(height: 24),

            // ── Content Area ─────────────────────────────────
            // Show different content based on current state:
            if (isLoading)
              _buildLoadingIndicator()
            else if (errorMessage != null)
              _buildErrorCard()
            else if (portfolioData != null)
              _buildPortfolioContent()
            else
              _buildEmptyState(),

          ],
        ),
      ),
    );
  }


  // ============================================================
  // UI Builder Methods
  //
  // Breaking the UI into small methods makes it much easier to read.
  // Each method returns a Widget.
  // ============================================================

  // ── Header Card ─────────────────────────────────────────────
  Widget _buildHeaderCard() {
    // Card is a Material Design card with a shadow and rounded corners
    return Card(
      // color: background color of the card
      color: Theme.of(context).colorScheme.primaryContainer,

      child: Padding(
        padding: const EdgeInsets.all(20),

        // Column stacks the title and subtitle vertically
        child: Column(
          children: [
            // Text widget — displays a string on screen
            // style: customize font size, weight, color
            const Text(
              'My Portfolio',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '₹ Indian Stocks  •  ₿ Bitcoin',
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ── Load Portfolio Button ────────────────────────────────────
  Widget _buildLoadButton() {
    // ElevatedButton is a raised button (Material Design)
    // onPressed: the function to call when tapped
    return ElevatedButton.icon(
      onPressed: isLoading ? null : fetchPortfolio,
      // When isLoading is true, we pass null to disable the button

      // icon: a small icon shown before the label
      icon: const Icon(Icons.refresh),

      // label: the text on the button
      label: const Text(
        'Load Portfolio',
        style: TextStyle(fontSize: 16),
      ),

      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }


  // ── Loading Spinner ──────────────────────────────────────────
  Widget _buildLoadingIndicator() {
    // Center puts its child in the middle of available space
    return const Center(
      child: Column(
        children: [
          SizedBox(height: 40),
          // CircularProgressIndicator = spinning loading circle
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Fetching your portfolio...', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }


  // ── Error Card ───────────────────────────────────────────────
  Widget _buildErrorCard() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 12),
            Text(
              errorMessage!,  // "!" tells Dart this is NOT null here
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }


  // ── Empty State (before any button press) ───────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.bar_chart, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Tap "Load Portfolio" above\nto fetch your live holdings',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }


  // ── Full Portfolio Content ───────────────────────────────────
  Widget _buildPortfolioContent() {
    // Extract values from the portfolioData map
    // The ?? operator means "if null, use this default instead"
    final totalValue = portfolioData!['total_value'] ?? 0.0;
    final totalPL = portfolioData!['total_profit_loss'] ?? 0.0;
    final totalPLPct = portfolioData!['total_profit_loss_pct'] ?? 0.0;
    final dailyChange = portfolioData!['daily_change'] ?? 0.0;
    final dailyChangePct = portfolioData!['daily_change_pct'] ?? 0.0;
    final assets = portfolioData!['assets'] as List<dynamic>;

    // Whether profit is positive (green) or negative (red)
    final bool isProfit = totalPL >= 0;
    final Color plColor = isProfit ? Colors.green.shade700 : Colors.red.shade700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        // ── Summary Card ──────────────────────────────────────
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Portfolio Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // Total Value
                _buildSummaryRow(
                  label: 'Total Value',
                  value: '₹${_formatNumber(totalValue)}',
                  valueStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const Divider(height: 24),

                // Total P&L
                _buildSummaryRow(
                  label: 'Total Profit / Loss',
                  value: '${isProfit ? "+" : ""}₹${_formatNumber(totalPL)} (${totalPLPct.toStringAsFixed(2)}%)',
                  valueStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: plColor),
                ),

                const SizedBox(height: 8),

                // Daily Change
                _buildSummaryRow(
                  label: "Today's Change",
                  value: '+₹${_formatNumber(dailyChange)} (+${dailyChangePct.toStringAsFixed(2)}%)',
                  valueStyle: TextStyle(fontSize: 15, color: Colors.green.shade700),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── Assets List Header ────────────────────────────────
        const Text(
          'Holdings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        // ── Asset Cards ───────────────────────────────────────
        // We use "map" to convert each asset into a Widget,
        // then ".toList()" converts the result back to a List.
        ...assets.map((asset) => _buildAssetCard(asset as Map<String, dynamic>)),
      ],
    );
  }


  // ── Single Asset Card ────────────────────────────────────────
  Widget _buildAssetCard(Map<String, dynamic> asset) {
    final bool isProfit = (asset['profit_loss'] ?? 0.0) >= 0;
    final Color plColor = isProfit ? Colors.green.shade700 : Colors.red.shade700;
    final bool isCrypto = asset['asset_type'] == 'crypto';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          // Row arranges children horizontally
          children: [

            // Asset icon (circle with first letter)
            CircleAvatar(
              backgroundColor: isCrypto
                  ? Colors.orange.shade100
                  : Colors.indigo.shade100,
              child: Text(
                asset['symbol'][0],  // First letter of the symbol
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCrypto ? Colors.orange.shade800 : Colors.indigo.shade800,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Asset name and symbol
            // "Expanded" makes this Column take all remaining horizontal space
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    '${asset['symbol']} · ${isCrypto ? "Crypto" : "Stock"}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Value and P&L (right side)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${_formatNumber(asset['current_value'])}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  '${isProfit ? "+" : ""}${asset['profit_loss_pct'].toStringAsFixed(2)}%',
                  style: TextStyle(color: plColor, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }


  // ── Helper: Summary Row ──────────────────────────────────────
  Widget _buildSummaryRow({
    required String label,
    required String value,
    required TextStyle valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 15)),
        Text(value, style: valueStyle),
      ],
    );
  }


  // ── Helper: Format large numbers with commas ─────────────────
  // e.g. 427494.65 → "4,27,494.65" (Indian number format)
  String _formatNumber(dynamic value) {
    final double num = (value as num).toDouble();
    // Format to 2 decimal places
    final String formatted = num.toStringAsFixed(2);
    // Split integer and decimal parts
    final parts = formatted.split('.');
    String intPart = parts[0];
    final String decPart = parts[1];

    // Apply Indian numbering: last 3 digits, then groups of 2
    if (intPart.length > 3) {
      final String last3 = intPart.substring(intPart.length - 3);
      final String rest = intPart.substring(0, intPart.length - 3);
      final buffer = StringBuffer();
      for (int i = 0; i < rest.length; i++) {
        if (i > 0 && (rest.length - i) % 2 == 0) buffer.write(',');
        buffer.write(rest[i]);
      }
      intPart = '${buffer.toString()},$last3';
    }
    return '$intPart.$decPart';
  }
}
