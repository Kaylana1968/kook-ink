import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/auth_service.dart';

class ProfileApiService {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "http://localhost:8000";

  //ROUTES RECETTES
  // Toutes les recettes
  static Uri recipes() => Uri.parse('$baseUrl/recipe');
  // Recette par ID
  static Uri recipeById(dynamic id) => Uri.parse('$baseUrl/recipe/$id');
  // Recettes de l'utilisateur connecté
  static Uri myRecipes() => Uri.parse('$baseUrl/recipe/me');
  // Recettes d’un utilisateur spécifique
  static Uri userRecipes(int id) => Uri.parse('$baseUrl/recipe/user/$id');

  // ROUTES POSTS
  // Tous les posts
  static Uri posts() => Uri.parse('$baseUrl/post');
  // Post par ID
  static Uri postById(dynamic id) => Uri.parse('$baseUrl/post/$id');
  // Posts de l'utilisateur connecté
  static Uri myPosts() => Uri.parse('$baseUrl/post/me');
  // Posts d’un utilisateur spécifique
  static Uri userPosts(int id) => Uri.parse('$baseUrl/post/user/$id');

  // ROUTES PROFIL
  // Profil utilisateur connecté
  static Uri myProfile() => Uri.parse('$baseUrl/profile/me');

  // Profil d'un utilisateur
  static Uri userProfile(int id) => Uri.parse('$baseUrl/profile/$id');

  // ROUTES FOLLOW
  // Nombre de followers de l'utilisateur connecté
  static Uri followCount() => Uri.parse('$baseUrl/follow/count');
  // Nombre de followers d’un utilisateur
  static Uri userFollowCount(int id) => Uri.parse('$baseUrl/follow/count/$id');

// ROUTES FAVORIS
  // Favoris utilisateur connecté
  static Uri favorites() => Uri.parse('$baseUrl/favorite');
  // Favoris d'un utilisateur
  static Uri userFavorites(int id) => Uri.parse('$baseUrl/favorite/user/$id');

  // RECUPERE LE PROFIL DE L'UTILISATEUR CONNECTE
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

  // RECUPERE LE PROFIL D'UN UTILISATEUR
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

  // RECUPERE LES followers/following DE L'UTILISATEUR CONNECTE
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

  // RECUPERE LES FOLLOWERS D'UN UTILISATEUR
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

  //FAVORIS UTILISATEUR CONNECTE
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

  //FAVORIS D'UN UTILISATEUR
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

  // POST DE L'UTILISATEUR CONNECTE
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

  // POST D'UN UTILISATEUR
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

  //CREER UN POST
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

  //SUPPRIMER UN POST
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

  // RECETTE D'UN UTILISATEUR
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

  // TOUTES LES RECETTES
  static Future<List<dynamic>> fetchRecipes() async {
    final response = await http.get(recipes());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["recipes"] as List<dynamic>;
    } else {
      throw Exception("Erreur serveur recettes");
    }
  }

  // RECETTE DE L'UTILISATEUR CONNECTE
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

  // SUPPRIMER UNE RECETTE
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
