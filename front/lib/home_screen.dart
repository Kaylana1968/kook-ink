import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front/main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> _feedFuture;

  @override
  void initState() {
    super.initState();
    _feedFuture = fetchFeed();
  }

  Future<List<dynamic>> fetchFeed() async {
    try {
      final String baseUrl = dotenv.env['BASE_URL'] ?? "http://localhost:8000";

      final response = await http.get(
        Uri.parse('$baseUrl/feed'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['feed'] as List<dynamic>;
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Impossible de se connecter au serveur');
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _feedFuture = fetchFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _feedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final feed = snapshot.data!;

        return RefreshIndicator(
          onRefresh: _refresh,
          color: Colors.orange,
          child: ListView.builder(
            itemCount: feed.length,
            itemBuilder: (context, index) {
              final feedItem = feed[index];

              if (feedItem["type"] == "post") {
                return RecipePost(post: feedItem["item"]);
              }

              if (feedItem["type"] == "recipe") {
                return RecipeCard(recipe: feedItem["item"]);
              }

              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 10),
          Text(error),
          TextButton(onPressed: _refresh, child: const Text("Réessayer")),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text("Aucun contenu à afficher pour le moment."),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeCard({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    final name = recipe["name"]?.toString() ?? "Recette";
    final username = recipe["username"]?.toString() ?? "Utilisateur";
    final imageUrl = recipe["image_link"]?.toString() ?? "";
    final userId = recipe["user_id"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: userId == null
              ? null
              : () {
                  MyHomePage.openUserProfile(userId);
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.person, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Text(
                  username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.more_horiz),
              ],
            ),
          ),
        ),
        if (imageUrl.isNotEmpty)
          Image.network(
            imageUrl,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.image_not_supported)),
              );
            },
          )
        else
          Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(child: Icon(Icons.image)),
          ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "${recipe["preparation_time"] ?? 0} min • "
                "${recipe["person"] ?? 0} pers • "
                "Niv ${recipe["difficulty"] ?? 0}",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }
}

class RecipePost extends StatelessWidget {
  final Map<String, dynamic> post;

  const RecipePost({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final username = post['username']?.toString() ?? 'Utilisateur';
    final description = post['description']?.toString() ?? '';
    final userId = post['user_id'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: userId == null
              ? null
              : () {
                  MyHomePage.openUserProfile(userId);
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.person, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Text(
                  username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.more_horiz),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            description,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }
}
