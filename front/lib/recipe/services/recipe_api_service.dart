import 'dart:convert';
import 'package:front/recipe/models/api_exception.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/authentification/auth_service.dart';

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

  static Future<void> createRecipe(Map<String, dynamic> body,
      {http.Client? client, String? token}) async {
    final authToken = token ?? await AuthService.getToken();
    final c = client ?? http.Client();

    final response = await c.post(
      recipes(),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException(response.statusCode, response.body);
    }
  }

  static Future<void> updateRecipe(int recipeId, Map<String, dynamic> body,
      {http.Client? client, String? token}) async {
    final authToken = token ?? await AuthService.getToken();
    final c = client ?? http.Client();

    final response = await c.put(
      recipeById(recipeId),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException(response.statusCode, response.body);
    }
  }

  static Future<Map<String, dynamic>> fetchRecipeById(int recipeId) async {
    final response = await http.get(
      recipeById(recipeId),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["recipe"] as Map<String, dynamic>;
    }

    throw Exception("Erreur chargement recette");
  }
}
