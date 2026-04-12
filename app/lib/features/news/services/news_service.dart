// features/news/services/news_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_model.dart';
import '../../../core/constants/api_constants.dart';

class NewsService {
  Future<NewsResponse> fetchNews({int limit = 20}) async {
    final uri = Uri.parse('${ApiConstants.news}?limit=$limit');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return NewsResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to load news feed');
  }
}
