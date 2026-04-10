// features/sip/models/sip_model.dart

class SipRequest {
  final double monthlyAmount;
  final String asset;     // e.g. "RELIANCE.NS", "BTC"
  final String duration;  // "1y", "3y", "5y"

  const SipRequest({
    required this.monthlyAmount,
    required this.asset,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
    'monthly_amount': monthlyAmount,
    'asset':          asset,
    'duration':       duration,
  };
}


class SipDataPoint {
  final String date;            // "YYYY-MM"
  final double portfolioValue;
  final double totalInvested;

  const SipDataPoint({
    required this.date,
    required this.portfolioValue,
    required this.totalInvested,
  });

  factory SipDataPoint.fromJson(Map<String, dynamic> json) => SipDataPoint(
    date:           json['date']            as String,
    portfolioValue: (json['portfolio_value'] as num).toDouble(),
    totalInvested:  (json['total_invested']  as num).toDouble(),
  );
}


class SipResult {
  final double totalInvested;
  final double currentValue;
  final double returnsPct;
  final double returnsAmount;
  final double monthlyAmount;
  final String asset;
  final String duration;
  final List<SipDataPoint> timeSeries;

  const SipResult({
    required this.totalInvested,
    required this.currentValue,
    required this.returnsPct,
    required this.returnsAmount,
    required this.monthlyAmount,
    required this.asset,
    required this.duration,
    required this.timeSeries,
  });

  factory SipResult.fromJson(Map<String, dynamic> json) => SipResult(
    totalInvested  = (json['total_invested']  as num).toDouble(),
    currentValue   = (json['current_value']   as num).toDouble(),
    returnsPct     = (json['returns_pct']      as num).toDouble(),
    returnsAmount  = (json['returns_amount']   as num).toDouble(),
    monthlyAmount  = (json['monthly_amount']   as num).toDouble(),
    asset          = json['asset']    as String,
    duration       = json['duration'] as String,
    timeSeries     = (json['time_series'] as List)
        .map((e) => SipDataPoint.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
