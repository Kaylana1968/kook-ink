import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> _postFuture;

  @override
  void initState() {
    super.initState();
    _postFuture = fetchPosts();
  }

  Future<List<dynamic>> fetchPosts() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/post'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        return data['posts'] as List<dynamic>;
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Impossible de se connecter au serveur');
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _postFuture = fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _postFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.orange));
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final posts = snapshot.data!;

        return RefreshIndicator(
          onRefresh: _refresh,
          color: Colors.orange,
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) => RecipePost(post: posts[index]),
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
      child: Text("Aucune recette à afficher pour le moment."),
    );
  }
}

// POST COMPONENT
class RecipePost extends StatelessWidget {
  final Map<String, dynamic> post;
  const RecipePost({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header (User Info)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.orange,
                child:
                    Icon(Icons.restaurant_menu, size: 18, color: Colors.white),
              ),
              SizedBox(width: 10),
              Spacer(),
              Icon(Icons.more_horiz),
            ],
          ),
        ),

        // 4. Content Area
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe Name
              Text(
                post['description'],
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }
}
