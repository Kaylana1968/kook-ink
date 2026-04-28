import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/auth_service.dart';

class RecipeApiService {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "http://localhost:8000";

  static Uri recipes() => Uri.parse('$baseUrl/recipe');
  static Uri recipeById(dynamic id) => Uri.parse('$baseUrl/recipe/$id');

  static Future<http.Response> createRecipe(Map<String, dynamic> body) async {
    final token = await AuthService().getToken();

    return http.post(
      recipes(),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> updateRecipe(
    dynamic recipeId,
    Map<String, dynamic> body,
  ) async {
    final token = await AuthService().getToken();

    return http.put(
      recipeById(recipeId),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }
}
