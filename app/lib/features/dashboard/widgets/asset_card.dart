// ============================================================
// features/dashboard/widgets/asset_card.dart
// ============================================================
//
// What is a widget file in the widgets/ folder?
//   Small, reusable UI pieces that the screen composes together.
//   Instead of one giant dashboard_screen.dart, we split the UI
//   into focused widgets. Each widget does ONE thing.
//
// AssetCard: renders a single asset row (name, symbol, value, change).
// ============================================================

import 'package:flutter/material.dart';
import '../models/portfolio_model.dart';


class AssetCard extends StatelessWidget {
  /// The asset data to display
  final Asset asset;

  const AssetCard({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    // Determine color based on whether the change is positive or negative
    final bool isPositive = asset.change.startsWith('+');
    final Color changeColor = isPositive ? Colors.green.shade700 : Colors.red.shade700;
    final bool isCrypto = asset.type == 'crypto';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // ── Icon circle ──────────────────────────────────
            CircleAvatar(
              backgroundColor: isCrypto
                  ? Colors.orange.shade100
                  : Colors.indigo.shade100,
              child: Text(
                asset.symbol[0],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCrypto
                      ? Colors.orange.shade800
                      : Colors.indigo.shade800,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ── Name + symbol ────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '${asset.symbol} · ${isCrypto ? "Crypto" : "Stock"}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // ── Value + change ───────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${asset.value.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  asset.change,
                  style: TextStyle(
                    color: changeColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
