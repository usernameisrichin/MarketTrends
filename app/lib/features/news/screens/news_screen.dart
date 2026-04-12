// features/news/screens/news_screen.dart

import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../services/news_service.dart';
import '../widgets/news_item_card.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});
  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final _service = NewsService();

  bool           _isLoading = false;
  String?        _error;
  NewsResponse?  _news;
  String         _filter = 'all';   // "all", "stock", "crypto"

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await _service.fetchNews(limit: 30);
      setState(() { _news = data; _isLoading = false; });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<NewsItem> get _filtered {
    if (_news == null) return [];
    if (_filter == 'all') return _news!.items;
    return _news!.items.where((i) => i.assetType == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('News & Sentiment', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: Column(
        children: [

          // ── Filter chips ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                for (final f in [
                  ('all',    'All News',    Icons.article),
                  ('stock',  'Stocks',      Icons.show_chart),
                  ('crypto', 'Crypto',      Icons.currency_bitcoin),
                ]) ...[
                  FilterChip(
                    label:      Text(f.$2),
                    avatar:     Icon(f.$3, size: 14),
                    selected:   _filter == f.$1,
                    onSelected: (_) => setState(() => _filter = f.$1),
                  ),
                  const SizedBox(width: 8),
                ],

                if (_news != null) ...[
                  const Spacer(),
                  _SentimentBadges(items: _news!.items),
                ],
              ],
            ),
          ),

          // ── Content ───────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _ErrorView(message: _error!, onRetry: _load)
                    : _filtered.isEmpty
                        ? const Center(child: Text('No news available'))
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _filtered.length,
                              itemBuilder: (_, i) => NewsItemCard(item: _filtered[i]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}


/// Shows bullish / bearish / neutral counts in compact form
class _SentimentBadges extends StatelessWidget {
  final List<NewsItem> items;
  const _SentimentBadges({required this.items});

  @override
  Widget build(BuildContext context) {
    final bullish = items.where((i) => i.sentiment == 'bullish').length;
    final bearish = items.where((i) => i.sentiment == 'bearish').length;
    return Row(children: [
      _Dot(color: Colors.green, label: '$bullish'),
      const SizedBox(width: 4),
      _Dot(color: Colors.red,   label: '$bearish'),
    ]);
  }
}

class _Dot extends StatelessWidget {
  final Color  color;
  final String label;
  const _Dot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(
        color: color, shape: BoxShape.circle)),
    const SizedBox(width: 3),
    Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
  ]);
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
      const SizedBox(height: 12),
      Text(message, textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey)),
      const SizedBox(height: 16),
      ElevatedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: const Text('Retry'),
      ),
    ]),
  );
}
