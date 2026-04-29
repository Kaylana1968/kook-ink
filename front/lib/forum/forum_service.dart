import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/auth_service.dart';

class ForumService {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "http://localhost:8000";
  final AuthService _authService = AuthService();

  Future<Map<String, String>> get _headers async {
    final token = await _authService.getToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  Future<List<dynamic>> getAllPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/forum/posts'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Erreur lors du chargement des posts');
  }

  Future<Map<String, dynamic>> getPostDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/forum/posts/$id'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Erreur lors du chargement du détail');
  }

  Future<void> createPost({
    required String title,
    required String description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forum/posts'),
      headers: await _headers,
      body: jsonEncode({"title": title, "description": description}),
    );
    if (response.statusCode != 201) throw Exception('Erreur création post');
  }

  Future<void> createResponse({
    required int postId,
    required String content,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forum/posts/$postId/responses'),
      headers: await _headers,
      body: jsonEncode({"content": content}),
    );
    if (response.statusCode != 201) throw Exception('Erreur envoi réponse');
  }

  Future<bool> toggleUpvote({required int responseId}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forum/responses/$responseId/upvote'),
      headers: await _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['upvoted'] as bool;
    }
    throw Exception('Erreur upvote');
  }
}