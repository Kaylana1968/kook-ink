import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomeApiService {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "http://localhost:8000";

  static Uri feed() => Uri.parse('$baseUrl/feed');

  static Future<List<dynamic>> fetchFeed() async {
    final response = await http.get(
      feed(),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['feed'] as List<dynamic>;
    }

    throw Exception('Erreur serveur: ${response.statusCode}');
  }
}
