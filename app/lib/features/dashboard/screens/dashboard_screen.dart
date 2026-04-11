// features/dashboard/screens/dashboard_screen.dart
// Updated: sector heatmap + hide/reveal balance

import 'package:flutter/material.dart';
import '../models/portfolio_model.dart';
import '../services/portfolio_service.dart';
import '../widgets/asset_card.dart';
import '../widgets/summary_card.dart';
import '../widgets/sector_heatmap.dart';
import '../../../shared/widgets/balance_visibility_wrapper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _service = PortfolioService();

  bool              _isLoading = false;
  String?           _error;
  PortfolioSummary? _portfolio;

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await _service.fetchPortfolio();
      setState(() { _portfolio = data; _isLoading = false; });
    } catch (e) {
      setState(() {
        _error = 'Could not connect. Make sure the backend is running:\n'
                 'cd api && uvicorn main:app --reload';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_portfolio != null)
            IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            if (!_isLoading && _portfolio == null && _error == null)
              ElevatedButton.icon(
                onPressed: _load,
                icon:  const Icon(Icons.refresh),
                label: const Text('Load Portfolio', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),

            const SizedBox(height: 16),

            if (_isLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ))
            else if (_error != null)
              _ErrorCard(message: _error!)
            else if (_portfolio != null) ...[

              // ── Summary card with hidden balance ───────
              BalanceVisibilityWrapper(
                child: SummaryCard(
                  totalValue:  _portfolio!.totalValue,
                  dailyChange: _portfolio!.dailyChange,
                ),
              ),

              const SizedBox(height: 20),

              // ── Sector Heatmap (donut chart) ───────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SectorHeatmap(assets: _portfolio!.assets),
                ),
              ),

              const SizedBox(height: 20),

              const Text('Holdings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ..._portfolio!.assets.map((a) => AssetCard(asset: a)),

            ] else
              _EmptyState(onLoad: _load),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});
  @override
  Widget build(BuildContext context) => Card(
    color: Colors.red.shade50,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 40),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 14)),
      ]),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onLoad;
  const _EmptyState({required this.onLoad});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(children: [
        Icon(Icons.bar_chart, size: 80, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text('Tap "Load Portfolio" to fetch your holdings',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
      ]),
    ),
  );
}
