// features/family/services/family_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/family_model.dart';
import '../../../core/constants/api_constants.dart';

class FamilyService {
  Future<FamilySummary> fetchFamilySummary() async {
    final response = await http.get(Uri.parse(ApiConstants.familySummary));
    if (response.statusCode == 200) {
      return FamilySummary.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to load family portfolio');
  }

  Future<FamilyMember> fetchMember(String memberId) async {
    final response = await http.get(
      Uri.parse(ApiConstants.memberPortfolio(memberId)),
    );
    if (response.statusCode == 200) {
      return FamilyMember.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Member not found');
  }
}
