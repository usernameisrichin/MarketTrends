// features/tax/widgets/tax_result_card.dart
// Shows the structured tax breakdown after calculation.

import 'package:flutter/material.dart';
import '../models/tax_model.dart';

class TaxResultCard extends StatelessWidget {
  final TaxResult result;
  const TaxResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isProfit = result.gain >= 0;
    final gainColor = isProfit ? Colors.green.shade700 : Colors.red.shade700;

    // Badge colour by tax type
    final badgeColor = switch (result.taxType) {
      'LTCG'   => Colors.blue.shade700,
      'STCG'   => Colors.orange.shade700,
      'CRYPTO' => Colors.purple.shade700,
      _        => Colors.grey.shade700,
    };

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header: Tax Type badge + holding period ───
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    result.taxType,
                    style: const TextStyle(color: Colors.white,
                        fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const Spacer(),
                Text('${result.holdingDays} days held',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),

            const Divider(height: 24),

            // ── Gain / Loss ───────────────────────────────
            _Row(
              label: result.gain >= 0 ? 'Total Gain' : 'Total Loss',
              value: '₹${_fmt(result.gain.abs())}',
              valueColor: gainColor,
              bold: true,
            ),

            const SizedBox(height: 8),

            // ── Tax rate + amount ─────────────────────────
            _Row(
              label: 'Tax Rate',
              value: '${result.taxRate.toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 6),
            _Row(
              label: 'Tax Payable',
              value: '₹${_fmt(result.taxAmount)}',
              valueColor: Colors.red.shade700,
            ),

            // ── LTCG exemption ────────────────────────────
            if (result.exemptionApplied != null && result.exemptionApplied! > 0) ...[
              const SizedBox(height: 6),
              _Row(
                label: 'LTCG Exemption Applied',
                value: '₹${_fmt(result.exemptionApplied!)}',
                valueColor: Colors.green.shade700,
              ),
            ],

            // ── Crypto TDS ────────────────────────────────
            if (result.tdsAmount != null) ...[
              const SizedBox(height: 6),
              _Row(
                label: '1% TDS (deducted at source)',
                value: '₹${_fmt(result.tdsAmount!)}',
                valueColor: Colors.orange.shade700,
              ),
            ],

            const Divider(height: 24),

            // ── Net profit ────────────────────────────────
            _Row(
              label: 'Net Profit After Tax',
              value: '₹${_fmt(result.netProfit)}',
              valueColor: result.netProfit >= 0
                  ? Colors.green.shade700
                  : Colors.red.shade700,
              bold: true,
              fontSize: 17,
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) =>
      v.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;
  final double fontSize;

  const _Row({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
    this.fontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: fontSize, color: Colors.grey.shade700)),
        Text(value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              color: valueColor,
            )),
      ],
    );
  }
}
