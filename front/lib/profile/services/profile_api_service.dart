import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/auth_service.dart';

class ProfileApiService {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "http://localhost:8000";

  static Uri recipes() => Uri.parse('$baseUrl/recipe');
  static Uri recipeById(dynamic id) => Uri.parse('$baseUrl/recipe/$id');
  static Uri myRecipes() => Uri.parse('$baseUrl/recipe/me');
  static Uri userRecipes(int id) => Uri.parse('$baseUrl/recipe/user/$id');

  static Uri posts() => Uri.parse('$baseUrl/post');
  static Uri postById(dynamic id) => Uri.parse('$baseUrl/post/$id');
  static Uri myPosts() => Uri.parse('$baseUrl/post/me');
  static Uri userPosts(int id) => Uri.parse('$baseUrl/post/user/$id');

  static Uri myProfile() => Uri.parse('$baseUrl/profile/me');
  static Uri userProfile(int id) => Uri.parse('$baseUrl/profile/$id');

  static Uri followCount() => Uri.parse('$baseUrl/follow/count');
  static Uri userFollowCount(int id) => Uri.parse('$baseUrl/follow/count/$id');

  static Uri favorites() => Uri.parse('$baseUrl/favorite');
  static Uri userFavorites(int id) => Uri.parse('$baseUrl/favorite/user/$id');

  static Future<List<dynamic>> fetchUserFavorites(int userId) async {
    final response = await http.get(
      userFavorites(userId),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["favorites"] as List<dynamic>;
    } else {
      throw Exception("Erreur favoris utilisateur");
    }
  }

  static Future<Map<String, dynamic>> fetchMyProfile() async {
    final token = await AuthService().getToken();

    final response = await http.get(
      myProfile(),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception("Erreur chargement profil");
    }
  }

  static Future<Map<String, dynamic>> fetchUserProfile(int userId) async {
    final response = await http.get(
      userProfile(userId),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception("Erreur chargement profil utilisateur");
    }
  }

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
        "followers": data["followers"] ?? 0,
        "following": data["following"] ?? 0,
      };
    } else {
      throw Exception("Erreur follow count");
    }
  }

  static Future<Map<String, int>> fetchUserFollowCount(int userId) async {
    final response = await http.get(
      userFollowCount(userId),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return {
        "followers": data["followers"] ?? 0,
        "following": data["following"] ?? 0,
      };
    } else {
      return {
        "followers": 0,
        "following": 0,
      };
    }
  }

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
      return data["posts"] as List<dynamic>;
    } else {
      throw Exception("Erreur serveur posts");
    }
  }

  static Future<List<dynamic>> fetchUserPosts(int userId) async {
    final response = await http.get(
      userPosts(userId),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["posts"] as List<dynamic>;
    } else {
      throw Exception("Erreur posts utilisateur");
    }
  }

  static Future<List<dynamic>> fetchRecipes() async {
    final response = await http.get(recipes());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["recipes"] as List<dynamic>;
    } else {
      throw Exception("Erreur serveur recettes");
    }
  }

  static Future<List<dynamic>> fetchMyRecipes() async {
    final token = await AuthService().getToken();

    final response = await http.get(
      myRecipes(),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["recipes"] as List<dynamic>;
    } else {
      throw Exception("Erreur serveur recettes");
    }
  }

  static Future<List<dynamic>> fetchUserRecipes(int userId) async {
    final response = await http.get(
      userRecipes(userId),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["recipes"] as List<dynamic>;
    } else {
      throw Exception("Erreur recettes utilisateur");
    }
  }

  static Future<List<dynamic>> fetchFavorites() async {
    final token = await AuthService().getToken();

    final response = await http.get(
      favorites(),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["favorites"] as List<dynamic>;
    } else {
      throw Exception("Erreur favoris");
    }
  }

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
