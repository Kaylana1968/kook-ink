import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/authentification/auth_service.dart';

class ForumService {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "http://127.0.0.1:8000";

  static Uri _postsUri() => Uri.parse('$baseUrl/forum/posts');
  static Uri _postDetailUri(int postId) =>
      Uri.parse('$baseUrl/forum/posts/$postId');
  static Uri _responsesUri(int postId) =>
      Uri.parse('$baseUrl/forum/posts/$postId/responses');
  static Uri _upvoteUri(int responseId) =>
      Uri.parse('$baseUrl/forum/responses/$responseId/upvote');

  Future<Map<String, String>> get _headers async {
    final token = await AuthService.getToken();

    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  Future<List<dynamic>> getAllPosts() async {
    final response = await http.get(
      _postsUri(),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception("Erreur lors du chargement des posts");
  }

  Future<Map<String, dynamic>> getPostDetail(int postId) async {
    final response = await http.get(
      _postDetailUri(postId),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception("Erreur lors du chargement du détail du post");
  }

  Future<void> createPost({
    required String title,
    required String description,
  }) async {
    final response = await http.post(
      _postsUri(),
      headers: await _headers,
      body: jsonEncode({
        "title": title,
        "description": description,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Erreur lors de la création du post");
    }
  }

  Future<void> createResponse({
    required int postId,
    required String content,
  }) async {
    final response = await http.post(
      _responsesUri(postId),
      headers: await _headers,
      body: jsonEncode({
        "content": content,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Erreur lors de l'envoi de la réponse");
    }
  }

  Future<bool> toggleUpvote({required int responseId}) async {
    final response = await http.post(
      _upvoteUri(responseId),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['upvoted'] == true;
    }

    throw Exception("Erreur lors du vote");
  }
}
