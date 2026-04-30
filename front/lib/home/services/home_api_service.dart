import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/authentification/auth_service.dart';

class HomeApiService {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "http://127.0.0.1:8000";

  // FEED
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

  // LIKE POST

  static Uri postLike(dynamic id) => Uri.parse('$baseUrl/post/$id/like');

  static Future<Map<String, dynamic>> getPostLike(int postId) async {
    final token = await AuthService.getToken();

    final response = await http.get(
      postLike(postId),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Erreur get like");
  }

  static Future<void> likePost(int postId) async {
    final token = await AuthService.getToken();

    final response = await http.post(
      postLike(postId),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Erreur like");
    }
  }

  static Future<void> unlikePost(int postId) async {
    final token = await AuthService.getToken();

    final response = await http.delete(
      postLike(postId),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Erreur unlike");
    }
  }

  static Uri recipeLike(dynamic id) => Uri.parse('$baseUrl/recipe/$id/like');

  static Future<Map<String, dynamic>> getRecipeLike(int recipeId) async {
    final token = await AuthService.getToken();

    final response = await http.get(
      recipeLike(recipeId),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Erreur get recipe like");
  }

  static Future<void> likeRecipe(int recipeId) async {
    final token = await AuthService.getToken();

    await http.post(
      recipeLike(recipeId),
      headers: {
        "Authorization": "Bearer $token",
      },
    );
  }

  static Future<void> unlikeRecipe(int recipeId) async {
    final token = await AuthService.getToken();

    await http.delete(
      recipeLike(recipeId),
      headers: {
        "Authorization": "Bearer $token",
      },
    );
  }
}
