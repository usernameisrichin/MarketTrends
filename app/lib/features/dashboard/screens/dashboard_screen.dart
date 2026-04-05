// ============================================================
// features/dashboard/screens/dashboard_screen.dart
// ============================================================
//
// This is the main dashboard screen.
//
// Notice how CLEAN it is compared to the original version —
// because we moved logic into PortfolioService and UI pieces
// into widget files (AssetCard, SummaryCard).
//
// The screen's only job: coordinate state and compose widgets.
// ============================================================

import 'package:flutter/material.dart';
import '../models/portfolio_model.dart';
import '../services/portfolio_service.dart';
import '../widgets/asset_card.dart';
import '../widgets/summary_card.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}


class _DashboardScreenState extends State<DashboardScreen> {

  // ── Dependencies ─────────────────────────────────────────
  // We create one instance of the service for this screen.
  // In a larger app, this would be injected (dependency injection).
  final _portfolioService = PortfolioService();

  // ── State ────────────────────────────────────────────────
  bool _isLoading = false;
  String? _error;
  PortfolioSummary? _portfolio;


  // ── Data Fetching ────────────────────────────────────────
  Future<void> _loadPortfolio() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _portfolioService.fetchPortfolio();
      setState(() {
        _portfolio = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not load portfolio.\n\nMake sure the backend is running:\ncd api && uvicorn main:app --reload';
        _isLoading = false;
      });
    }
  }


  // ── Build ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          'Portfolio Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── Load Button ───────────────────────────────
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _loadPortfolio,
              icon: const Icon(Icons.refresh),
              label: const Text('Load Portfolio', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            // ── Dynamic Content ───────────────────────────
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              _ErrorCard(message: _error!)
            else if (_portfolio != null)
              _PortfolioView(portfolio: _portfolio!)
            else
              _EmptyState(),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// Private sub-widgets — only used in this screen
//
// Keeping them private (underscore prefix) and in the same file
// is fine when they're small and tightly coupled to this screen.
// ============================================================

class _PortfolioView extends StatelessWidget {
  final PortfolioSummary portfolio;
  const _PortfolioView({required this.portfolio});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Summary card at the top
        SummaryCard(
          totalValue: portfolio.totalValue,
          dailyChange: portfolio.dailyChange,
        ),

        const SizedBox(height: 20),

        const Text(
          'Holdings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        // One AssetCard per holding
        ...portfolio.assets.map((asset) => AssetCard(asset: asset)),
      ],
    );
  }
}


class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}


class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.bar_chart, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Tap "Load Portfolio" above\nto fetch your live holdings',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
