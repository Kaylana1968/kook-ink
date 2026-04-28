import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/auth_service.dart';

class ProfileApiService {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "http://localhost:8000";

  // ROUTES
  static Uri recipes() => Uri.parse('$baseUrl/recipe');
  static Uri recipeById(dynamic id) => Uri.parse('$baseUrl/recipe/$id');

  static Uri posts() => Uri.parse('$baseUrl/post');
  static Uri postById(dynamic id) => Uri.parse('$baseUrl/post/$id');
  static Uri myPosts() => Uri.parse('$baseUrl/post/me');

  static Uri followCount() => Uri.parse('$baseUrl/follow/count');

  static Future<bool> createPost(String description) async {
    final token = await AuthService().getToken();

    final response = await http.post(
      posts(),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "description": description,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // FETCH POSTS (USER ONLY)
  static Future<List<dynamic>> fetchMyPosts() async {
    final token = await AuthService().getToken();

    final response = await http.get(
      myPosts(),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['posts'] as List<dynamic>;
    } else {
      throw Exception('Erreur serveur posts');
    }
  }

  // FETCH RECIPES
  static Future<List<dynamic>> fetchRecipes() async {
    final response = await http.get(recipes());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['recipes'] as List<dynamic>;
    } else {
      throw Exception('Erreur serveur recettes');
    }
  }

  // FETCH FOLLOW COUNT
  static Future<Map<String, int>> fetchFollowCount() async {
    final token = await AuthService().getToken();

    final response = await http.get(
      followCount(),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        "followers": data['followers'],
        "following": data['following'],
      };
    } else {
      throw Exception("Erreur follow count");
    }
  }

  // DELETE POST
  static Future<bool> deletePost(int postId) async {
    final token = await AuthService().getToken();

    final response = await http.delete(
      postById(postId),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  // DELETE RECIPE
  static Future<bool> deleteRecipe(int recipeId) async {
    final token = await AuthService().getToken();

    final response = await http.delete(
      recipeById(recipeId),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }
}
