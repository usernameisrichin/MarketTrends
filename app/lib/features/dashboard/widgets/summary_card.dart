// ============================================================
// features/dashboard/widgets/summary_card.dart
// ============================================================
//
// SummaryCard: displays the portfolio total value and daily change.
// Used at the top of the dashboard screen.
// ============================================================

import 'package:flutter/material.dart';


class SummaryCard extends StatelessWidget {
  final double totalValue;
  final String dailyChange;

  const SummaryCard({
    super.key,
    required this.totalValue,
    required this.dailyChange,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPositive = dailyChange.startsWith('+');
    final Color changeColor =
        isPositive ? Colors.green.shade700 : Colors.red.shade700;

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Portfolio Value',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context)
                    .colorScheme
                    .onPrimaryContainer
                    .withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '₹${totalValue.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: changeColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Today: $dailyChange',
                  style: TextStyle(
                    color: changeColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
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
