// ============================================================
// features/dashboard/services/portfolio_service.dart
// ============================================================
//
// What is a service in Flutter?
//   A service handles data fetching and business logic.
//   The screen (UI) should NOT contain network calls directly.
//   Instead, the screen calls the service, which does the work.
//
// Why separate it?
//   - Cleaner screens (UI code only)
//   - Easy to test the service in isolation
//   - Easy to swap the data source later (e.g. mock → real API)
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/portfolio_model.dart';
import '../../../core/constants/api_constants.dart';


class PortfolioService {
  /// Fetches the portfolio summary from the FastAPI backend.
  ///
  /// Returns a [PortfolioSummary] on success.
  /// Throws an [Exception] if the request fails or returns a non-200 status.
  Future<PortfolioSummary> fetchPortfolio() async {
    // Make the HTTP GET request
    final response = await http.get(
      Uri.parse(ApiConstants.portfolioEndpoint),
    );

    if (response.statusCode == 200) {
      // Parse the JSON body into a Dart Map, then into our model
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PortfolioSummary.fromJson(json);
    } else {
      throw Exception('Failed to load portfolio (HTTP ${response.statusCode})');
    }
  }
}
