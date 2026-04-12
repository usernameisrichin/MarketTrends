// features/news/models/news_model.dart

class NewsItem {
  final String headline;
  final String source;
  final String url;
  final String published;
  final String sentiment;       // "bullish", "bearish", "neutral"
  final double sentimentScore;  // -1.0 to +1.0
  final String assetType;       // "stock", "crypto", "general"

  const NewsItem({
    required this.headline,
    required this.source,
    required this.url,
    required this.published,
    required this.sentiment,
    required this.sentimentScore,
    required this.assetType,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) => NewsItem(
    headline       = json['headline']        as String,
    source         = json['source']          as String,
    url            = json['url']             as String,
    published      = json['published']       as String,
    sentiment      = json['sentiment']       as String,
    sentimentScore = (json['sentiment_score'] as num).toDouble(),
    assetType      = json['asset_type']      as String,
  );
}

class NewsResponse {
  final List<NewsItem> items;
  final int            total;

  const NewsResponse({required this.items, required this.total});

  factory NewsResponse.fromJson(Map<String, dynamic> json) => NewsResponse(
    items = (json['items'] as List)
        .map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    total = json['total'] as int,
  );
}
