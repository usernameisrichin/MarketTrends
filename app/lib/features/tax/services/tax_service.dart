// features/tax/services/tax_service.dart
// Calls POST /tax/calculate and parses the response.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tax_model.dart';
import '../../../core/constants/api_constants.dart';

class TaxService {
  Future<TaxResult> calculate(TaxRequest request) async {
    final response = await http.post(
      Uri.parse(ApiConstants.taxCalculate),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return TaxResult.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      // Extract the "detail" field from FastAPI error responses
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Tax calculation failed');
    }
  }
}
