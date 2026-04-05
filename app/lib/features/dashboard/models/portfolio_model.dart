// ============================================================
// features/dashboard/models/portfolio_model.dart
// ============================================================
//
// What are models in Flutter?
//   Models are Dart classes that represent data structures.
//   They mirror the JSON shape returned by the API so we can
//   easily convert JSON → Dart object and back.
//
// "fromJson()" is a constructor that takes a Map (parsed JSON)
//   and fills in the object's fields.
//
// "toJson()" converts the object back to a Map (for sending data).
// ============================================================

/// Represents a single asset holding (stock or crypto)
class Asset {
  final String type;    // "stock" or "crypto"
  final String name;    // Full name, e.g. "Reliance Industries"
  final String symbol;  // Ticker, e.g. "RELIANCE"
  final double value;   // Current value in INR
  final String change;  // Daily change, e.g. "+1.2%"

  // Constructor: all fields are required
  const Asset({
    required this.type,
    required this.name,
    required this.symbol,
    required this.value,
    required this.change,
  });

  /// Create an Asset from a JSON map.
  ///
  /// When we get JSON from the API, it's a Map<String, dynamic>.
  /// This factory constructor converts that map into an Asset object.
  ///
  /// Example JSON:
  ///   { "type": "stock", "name": "TCS", "symbol": "TCS", "value": 300000, "change": "-0.5%" }
  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      type: json['type'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      // API returns a number; we cast it to double safely
      value: (json['value'] as num).toDouble(),
      change: json['change'] as String,
    );
  }
}


/// Represents the full portfolio response from the API
class PortfolioSummary {
  final double totalValue;    // Total portfolio value in INR
  final String dailyChange;   // Overall daily change, e.g. "+2.3%"
  final List<Asset> assets;   // All individual holdings

  const PortfolioSummary({
    required this.totalValue,
    required this.dailyChange,
    required this.assets,
  });

  /// Create a PortfolioSummary from a JSON map.
  ///
  /// Example JSON:
  ///   {
  ///     "totalValue": 1600000,
  ///     "dailyChange": "+2.3%",
  ///     "assets": [ ... ]
  ///   }
  factory PortfolioSummary.fromJson(Map<String, dynamic> json) {
    return PortfolioSummary(
      totalValue: (json['totalValue'] as num).toDouble(),
      dailyChange: json['dailyChange'] as String,
      // "assets" is a JSON array → we map each element to an Asset object
      assets: (json['assets'] as List<dynamic>)
          .map((item) => Asset.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
