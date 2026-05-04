import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/auth_service.dart';
import 'package:http/http.dart' as http;

class DetailApiService {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "http://localhost:8000";

  static Uri postById(int id) => Uri.parse('$baseUrl/post/$id');
  static Uri recipeById(int id) => Uri.parse('$baseUrl/recipe/$id');
  static Uri postComments(int id) => Uri.parse('$baseUrl/post/$id/comments');
  static Uri recipeComments(int id) =>
      Uri.parse('$baseUrl/recipe/$id/comments');

  static Future<Map<String, dynamic>> fetchPost(int id) async {
    final response = await http.get(postById(id));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['post'] as Map<String, dynamic>;
    }

    throw Exception('Erreur chargement post');
  }

  static Future<Map<String, dynamic>> fetchRecipe(int id) async {
    final response = await http.get(recipeById(id));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['recipe'] as Map<String, dynamic>;
    }

    throw Exception('Erreur chargement recette');
  }

  static Future<List<dynamic>> fetchPostComments(int id) async {
    final response = await http.get(postComments(id));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['comments'] as List<dynamic>;
    }

    throw Exception('Erreur chargement commentaires');
  }

  static Future<List<dynamic>> fetchRecipeComments(int id) async {
    final response = await http.get(recipeComments(id));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['comments'] as List<dynamic>;
    }

    throw Exception('Erreur chargement commentaires');
  }

  static Future<void> createPostComment(int id, String content) async {
    await _createComment(postComments(id), content);
  }

  static Future<void> createRecipeComment(int id, String content) async {
    await _createComment(recipeComments(id), content);
  }

  static Future<void> _createComment(Uri uri, String content) async {
    final token = await AuthService.getToken();

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur envoi commentaire');
    }
  }
}
