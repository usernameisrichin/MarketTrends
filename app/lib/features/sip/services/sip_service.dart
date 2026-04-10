// features/sip/services/sip_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sip_model.dart';
import '../../../core/constants/api_constants.dart';

class SipService {
  Future<SipResult> backtest(SipRequest request) async {
    final response = await http.post(
      Uri.parse(ApiConstants.sipBacktest),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return SipResult.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'SIP backtest failed');
    }
  }
}
