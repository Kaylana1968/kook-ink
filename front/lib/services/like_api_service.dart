import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/auth_service.dart';
import 'package:http/http.dart' as http;

class LikeApiService {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "http://localhost:8000";

  static Uri likeUri(String type, int id) => Uri.parse('$baseUrl/like/$type/$id');

  static Future<Map<String, dynamic>> fetchStatus(String type, int id) async {
    final token = await AuthService.getToken();

    final response = await http.get(
      likeUri(type, id),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    return {"liked": false, "count": 0};
  }

  static Future<bool> like(String type, int id) async {
    final token = await AuthService.getToken();

    final response = await http.post(
      likeUri(type, id),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<bool> unlike(String type, int id) async {
    final token = await AuthService.getToken();

    final response = await http.delete(
      likeUri(type, id),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }
}
