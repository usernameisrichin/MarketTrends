// core/constants/api_constants.dart — Single source of truth for all API URLs
//
// Change ONE line to point the entire app to a new environment:
//   - Development:  localhost:8000
//   - Android EMU:  10.0.2.2:8000
//   - Production:   https://api.yourapp.com

class ApiConstants {
  ApiConstants._();

  // ── Base URL ───────────────────────────────────────────────
  // iOS Simulator + Web : http://localhost:8000
  // Android Emulator    : http://10.0.2.2:8000
  // Real device (WiFi)  : http://192.168.x.x:8000
  static const String baseUrl = 'http://localhost:8000';
  static const String wsBaseUrl = 'ws://localhost:8000';    // WebSocket base

  // ── Portfolio ──────────────────────────────────────────────
  static const String portfolio      = '$baseUrl/portfolio';
  static const String familySummary  = '$baseUrl/portfolio/family-summary';
  static String memberPortfolio(String id) => '$baseUrl/portfolio/member/$id';

  // ── Tax Estimator ──────────────────────────────────────────
  static const String taxCalculate   = '$baseUrl/tax/calculate';

  // ── SIP Backtester ─────────────────────────────────────────
  static const String sipBacktest    = '$baseUrl/sip/backtest';

  // ── News Feed ──────────────────────────────────────────────
  static const String news           = '$baseUrl/news';

  // ── Real-Time ──────────────────────────────────────────────
  static const String cryptoWs       = '$wsBaseUrl/realtime/crypto';
  static String stockPrice(String symbol) => '$baseUrl/realtime/price/$symbol';
}
