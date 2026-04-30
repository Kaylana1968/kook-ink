import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/authentification/auth_service.dart';

class HomeApiService {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "http://127.0.0.1:8000";

  static Uri feed() => Uri.parse('$baseUrl/feed');

// LIKE
  static Uri postLike(dynamic id) => Uri.parse('$baseUrl/post/$id/like');
  static Uri recipeLike(dynamic id) => Uri.parse('$baseUrl/recipe/$id/like');

// COMMENT
  static Uri postComments(dynamic id) =>
      Uri.parse('$baseUrl/post/$id/comments');
  static Uri recipeComments(dynamic id) =>
      Uri.parse('$baseUrl/recipe/$id/comments');

  // FEED
  static Future<List<dynamic>> fetchFeed() async {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception("Utilisateur non connecté");
    }

    final response = await http.get(
      feed(),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['feed'] as List<dynamic>;
    }

    throw Exception(
        "Erreur lors du chargement du fil d'actualité (${response.statusCode})");
  }

  // RECOVER THE LIKES FROM A POST
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

    throw Exception("Impossible de récupérer les likes du post");
  }

  // LIKE POST
  static Future<void> likePost(int postId) async {
    final token = await AuthService.getToken();

    final response = await http.post(
      postLike(postId),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Erreur lors du like du post");
    }
  }

  // UNLIKE POST
  static Future<void> unlikePost(int postId) async {
    final token = await AuthService.getToken();

    final response = await http.delete(
      postLike(postId),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Erreur lors du retrait du like du post");
    }
  }

  // RECOVER THE LIKES FOR A RECIPE
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

    throw Exception("Impossible de récupérer les likes de la recette");
  }

  // LIKE RECETTE
  static Future<void> likeRecipe(int recipeId) async {
    final token = await AuthService.getToken();

    final response = await http.post(
      recipeLike(recipeId),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Erreur lors du like de la recette");
    }
  }

  // UNLIKE RECETTE
  static Future<void> unlikeRecipe(int recipeId) async {
    final token = await AuthService.getToken();

    final response = await http.delete(
      recipeLike(recipeId),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Erreur lors du retrait du like de la recette");
    }
  }

  // COMMENTS POST
  static Future<List<dynamic>> getPostComments(int postId) async {
    final response = await http.get(
      postComments(postId),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["comments"] as List<dynamic>;
    }

    return [];
  }

// CREATE COMMENT POST
  static Future<bool> createPostComment(int postId, String content) async {
    final token = await AuthService.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/post/$postId/comments'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "content": content,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

// COMMENTS RECIPE
  static Future<List<dynamic>> getRecipeComments(int recipeId) async {
    final response = await http.get(
      recipeComments(recipeId),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["comments"] as List<dynamic>;
    }

    return [];
  }

  static Future<bool> createRecipeComment(int recipeId, String content) async {
    final token = await AuthService.getToken();

    final response = await http.post(
      recipeComments(recipeId),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "content": content,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }
}
