// features/dashboard/models/portfolio_model.dart
// Dart mirror of the FastAPI PortfolioSummary + Asset models.

class Asset {
  final String type;      // "stock" or "crypto"  (from API)
  final String name;
  final String symbol;
  final double value;
  final String change;

  // Convenience getter — used by sector heatmap and asset cards
  String get assetType => type;

  const Asset({
    required this.type,
    required this.name,
    required this.symbol,
    required this.value,
    required this.change,
  });

  factory Asset.fromJson(Map<String, dynamic> json) => Asset(
    type:   json['type']   as String,
    name:   json['name']   as String,
    symbol: json['symbol'] as String,
    value:  (json['value'] as num).toDouble(),
    change: json['change'] as String,
  );
}


class PortfolioSummary {
  final double     totalValue;
  final String     dailyChange;
  final List<Asset> assets;

  const PortfolioSummary({
    required this.totalValue,
    required this.dailyChange,
    required this.assets,
  });

  factory PortfolioSummary.fromJson(Map<String, dynamic> json) =>
      PortfolioSummary(
        totalValue:  (json['totalValue']  as num).toDouble(),
        dailyChange: json['dailyChange']  as String,
        assets:      (json['assets'] as List)
            .map((e) => Asset.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
