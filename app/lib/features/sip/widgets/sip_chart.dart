// ============================================================
// features/sip/widgets/sip_chart.dart
// ============================================================
//
// Renders a line chart comparing:
//   - Blue line  → Portfolio value over time
//   - Orange line → Total invested (straight ramp)
//
// Uses fl_chart's LineChart widget.
// The gap between lines = returns (profit or loss).
// ============================================================

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/sip_model.dart';

class SipChart extends StatelessWidget {
  final List<SipDataPoint> timeSeries;

  const SipChart({super.key, required this.timeSeries});

  @override
  Widget build(BuildContext context) {
    if (timeSeries.isEmpty) return const SizedBox();

    final portfolioSpots = timeSeries.asMap().entries.map((e) =>
        FlSpot(e.key.toDouble(), e.value.portfolioValue)).toList();

    final investedSpots = timeSeries.asMap().entries.map((e) =>
        FlSpot(e.key.toDouble(), e.value.totalInvested)).toList();

    final maxY = timeSeries
        .map((e) => e.portfolioValue)
        .reduce((a, b) => a > b ? a : b) * 1.1;

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 56,
                getTitlesWidget: (v, _) => Text(
                  '₹${(v / 1000).toStringAsFixed(0)}K',
                  style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (timeSeries.length / 4).ceilToDouble(),
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= timeSeries.length) {
                    return const SizedBox();
                  }
                  // Show only month-year abbreviation
                  final parts = timeSeries[idx].date.split('-');
                  return Text('${parts[1]}/${parts[0].substring(2)}',
                      style: TextStyle(fontSize: 9, color: Colors.grey.shade600));
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            // Portfolio value line (blue, filled)
            LineChartBarData(
              spots:          portfolioSpots,
              isCurved:       true,
              color:          Colors.indigo,
              barWidth:       2.5,
              dotData:        const FlDotData(show: false),
              belowBarData:   BarAreaData(
                show:  true,
                color: Colors.indigo.withOpacity(0.08),
              ),
            ),
            // Total invested line (orange, dashed)
            LineChartBarData(
              spots:    investedSpots,
              isCurved: false,
              color:    Colors.orange.shade600,
              barWidth: 2,
              dotData:  const FlDotData(show: false),
              dashArray: [6, 4],
            ),
          ],
        ),
      ),
    );
  }
}
