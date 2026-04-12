// features/news/widgets/news_item_card.dart

import 'package:flutter/material.dart';
import '../models/news_model.dart';

class NewsItemCard extends StatelessWidget {
  final NewsItem item;
  const NewsItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final (sentimentColor, sentimentIcon, sentimentLabel) = switch (item.sentiment) {
      'bullish' => (Colors.green.shade700,  Icons.arrow_upward,   'Bullish'),
      'bearish' => (Colors.red.shade700,    Icons.arrow_downward, 'Bearish'),
      _         => (Colors.grey.shade600,   Icons.remove,          'Neutral'),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Headline ──────────────────────────────────
          Text(
            item.headline,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
          ),

          const SizedBox(height: 8),

          // ── Meta row ──────────────────────────────────
          Row(children: [
            // Source
            Text(item.source,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),

            // Asset type pill
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: item.assetType == 'crypto'
                    ? Colors.orange.shade100 : Colors.indigo.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.assetType == 'crypto' ? 'Crypto' : 'Stock',
                style: TextStyle(
                  fontSize: 10,
                  color: item.assetType == 'crypto'
                      ? Colors.orange.shade800 : Colors.indigo.shade800,
                ),
              ),
            ),

            const Spacer(),

            // Sentiment badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: sentimentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: sentimentColor.withOpacity(0.4)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(sentimentIcon, size: 12, color: sentimentColor),
                const SizedBox(width: 3),
                Text(sentimentLabel,
                    style: TextStyle(fontSize: 11, color: sentimentColor,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ]),
        ]),
      ),
    );
  }
}
