import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ForumService {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "http://localhost:8000";

  // Récupérer la liste des posts
  Future<List<dynamic>> getAllPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/forum/posts'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors du chargement des posts');
    }
  }

  // Récupérer les détails et réponses d'un post spécifique
  Future<Map<String, dynamic>> getPostDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/forum/posts/$id'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors du chargement du détail');
    }
  }
}