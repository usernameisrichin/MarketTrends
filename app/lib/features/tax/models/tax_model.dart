// features/tax/models/tax_model.dart
// Mirrors the FastAPI TaxCalculationRequest and TaxCalculationResponse.

class TaxRequest {
  final String buyDate;    // "YYYY-MM-DD"
  final String sellDate;
  final double buyPrice;
  final double sellPrice;
  final double quantity;
  final String assetType;  // "equity" or "crypto"

  const TaxRequest({
    required this.buyDate,
    required this.sellDate,
    required this.buyPrice,
    required this.sellPrice,
    required this.quantity,
    required this.assetType,
  });

  /// Convert to JSON Map for the HTTP POST body
  Map<String, dynamic> toJson() => {
    'buy_date':   buyDate,
    'sell_date':  sellDate,
    'buy_price':  buyPrice,
    'sell_price': sellPrice,
    'quantity':   quantity,
    'asset_type': assetType,
  };
}


class TaxResult {
  final double gain;
  final double taxAmount;
  final String taxType;        // "STCG", "LTCG", or "CRYPTO"
  final double taxRate;        // e.g. 20.0, 12.5, 30.0
  final double netProfit;
  final int    holdingDays;
  final double? tdsAmount;         // crypto only
  final double? exemptionApplied;  // LTCG only

  const TaxResult({
    required this.gain,
    required this.taxAmount,
    required this.taxType,
    required this.taxRate,
    required this.netProfit,
    required this.holdingDays,
    this.tdsAmount,
    this.exemptionApplied,
  });

  factory TaxResult.fromJson(Map<String, dynamic> json) => TaxResult(
    gain              = (json['gain']       as num).toDouble(),
    taxAmount         = (json['tax_amount'] as num).toDouble(),
    taxType           = json['tax_type']    as String,
    taxRate           = (json['tax_rate']   as num).toDouble(),
    netProfit         = (json['net_profit'] as num).toDouble(),
    holdingDays       = json['holding_days'] as int,
    tdsAmount         = json['tds_amount']        != null
        ? (json['tds_amount'] as num).toDouble()    : null,
    exemptionApplied  = json['exemption_applied']  != null
        ? (json['exemption_applied'] as num).toDouble() : null,
  );
}
