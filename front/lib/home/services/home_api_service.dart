import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/authentification/auth_service.dart';

class HomeApiService {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "http://localhost:8000";

  static Uri feed({String dateOrder = 'desc'}) =>
      Uri.parse('$baseUrl/feed?date_order=$dateOrder');

  static Future<List<dynamic>> fetchFeed({String dateOrder = 'desc'}) async {
    final token = await AuthService.getToken();
    final response = await http.get(
      feed(dateOrder: dateOrder),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['feed'] as List<dynamic>;
    }

    throw Exception('Erreur serveur: ${response.statusCode}');
  }
}
