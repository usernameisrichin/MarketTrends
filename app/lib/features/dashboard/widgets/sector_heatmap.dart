// ============================================================
// features/dashboard/widgets/sector_heatmap.dart
// ============================================================
//
// A donut chart showing allocation across sectors.
// Built with fl_chart's PieChart widget.
//
// Sectors are derived from the asset list:
//   - Banking:  HDFCBANK, SBIN, BAJFINANCE
//   - IT:       TCS, INFY, WIPRO
//   - Energy:   RELIANCE, COALINDIA
//   - Consumer: HINDUNILVR, ITC, ASIANPAINT, TITAN
//   - Crypto:   BTC, ETH, SOL
//   - Other:    everything else
// ============================================================

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../dashboard/models/portfolio_model.dart';

// Sector → color mapping
const _sectorColors = {
  'IT':       Color(0xFF3F51B5),   // indigo
  'Banking':  Color(0xFF009688),   // teal
  'Energy':   Color(0xFFFF5722),   // deep orange
  'Consumer': Color(0xFF8BC34A),   // light green
  'Crypto':   Color(0xFFFF9800),   // orange
  'Other':    Color(0xFF9E9E9E),   // grey
};

String _sector(Asset a) {
  if (a.assetType == 'crypto') return 'Crypto';
  final s = a.symbol.toUpperCase();
  if (['TCS', 'INFY', 'WIPRO', 'HCLTECH', 'TECHM'].contains(s)) return 'IT';
  if (['HDFCBANK', 'SBIN', 'ICICIBANK', 'KOTAKBANK', 'BAJFINANCE'].contains(s)) return 'Banking';
  if (['RELIANCE', 'COALINDIA', 'NTPC', 'POWERGRID', 'ONGC'].contains(s)) return 'Energy';
  if (['HINDUNILVR', 'ITC', 'ASIANPAINT', 'TITAN', 'NESTLEIND'].contains(s)) return 'Consumer';
  return 'Other';
}

class SectorHeatmap extends StatefulWidget {
  final List<Asset> assets;
  const SectorHeatmap({super.key, required this.assets});

  @override
  State<SectorHeatmap> createState() => _SectorHeatmapState();
}

class _SectorHeatmapState extends State<SectorHeatmap> {
  int _touchedIdx = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.assets.isEmpty) return const SizedBox();

    // Aggregate value by sector
    final Map<String, double> sectorValues = {};
    for (final a in widget.assets) {
      final sec = _sector(a);
      sectorValues[sec] = (sectorValues[sec] ?? 0) + a.value;
    }

    final total  = sectorValues.values.fold(0.0, (a, b) => a + b);
    final entries = sectorValues.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));   // largest first

    final sections = entries.asMap().entries.map((mapEntry) {
      final idx    = mapEntry.key;
      final entry  = mapEntry.value;
      final pct    = entry.value / total * 100;
      final isTouched = idx == _touchedIdx;
      final color  = _sectorColors[entry.key] ?? _sectorColors['Other']!;

      return PieChartSectionData(
        value:           entry.value,
        color:           color,
        radius:          isTouched ? 52.0 : 44.0,
        title:           isTouched ? '${pct.toStringAsFixed(1)}%' : '',
        titleStyle:      const TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                             color: Colors.white),
        borderSide:      isTouched
            ? const BorderSide(color: Colors.white, width: 2)
            : BorderSide.none,
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sector Allocation',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        Row(
          children: [
            // ── Donut chart ─────────────────────────────
            SizedBox(
              width:  160,
              height: 160,
              child: PieChart(
                PieChartData(
                  sections:      sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            response == null ||
                            response.touchedSection == null) {
                          _touchedIdx = -1;
                          return;
                        }
                        _touchedIdx =
                            response.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // ── Legend ──────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: entries.map((e) {
                  final color = _sectorColors[e.key] ?? _sectorColors['Other']!;
                  final pct   = e.value / total * 100;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(children: [
                      Container(width: 10, height: 10,
                          decoration: BoxDecoration(
                              color: color, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 6),
                      Expanded(child: Text(e.key,
                          style: const TextStyle(fontSize: 13))),
                      Text('${pct.toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600)),
                    ]),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
