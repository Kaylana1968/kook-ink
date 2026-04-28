import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/auth_service.dart';

class RecipeApiService {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "http://localhost:8000";

  static Uri recipes() => Uri.parse('$baseUrl/recipe');
  static Uri recipeById(int id) => Uri.parse('$baseUrl/recipe/$id');

  static Future<Map<String, dynamic>> getRecipe(int recipeId) async {
    final response = await http.get(recipeById(recipeId));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data["recipe"] as Map<String, dynamic>;
    } else {
      throw Exception("Erreur chargement recette");
    }
  }

  static Future<http.Response> createRecipe(Map<String, dynamic> body) async {
    final token = await AuthService.getToken();

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
    int recipeId,
    Map<String, dynamic> body,
  ) async {
    final token = await AuthService.getToken();

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
