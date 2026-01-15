import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> _recipeFuture;

  @override
  void initState() {
    super.initState();
    _recipeFuture = fetchRecipes();
  }

  Future<List<dynamic>> fetchRecipes() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/recipe'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        return data['recipes'] as List<dynamic>;
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Impossible de se connecter au serveur');
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _recipeFuture = fetchRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _recipeFuture,
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

        final recipes = snapshot.data!;

        return RefreshIndicator(
          onRefresh: _refresh,
          color: Colors.orange,
          child: ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) => RecipePost(recipe: recipes[index]),
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
  final Map<String, dynamic> recipe;
  const RecipePost({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header (User Info)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.orange,
                child:
                    Icon(Icons.restaurant_menu, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Text(
                "Utilisateur #${recipe['user_id']}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              const Icon(Icons.more_horiz),
            ],
          ),
        ),

        // Image
        AspectRatio(
          aspectRatio: 1,
          child: Image.network(
            recipe['image_link'],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[200],
              child:
                  const Icon(Icons.broken_image, size: 50, color: Colors.grey),
            ),
          ),
        ),

        // Buttons(icons)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.favorite_border, size: 28),
              SizedBox(width: 15),
              Icon(Icons.chat_bubble_outline, size: 26),
              SizedBox(width: 15),
              Spacer(),
              Icon(Icons.bookmark_border, size: 28),
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
                recipe['name'].toUpperCase(),
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(height: 4),

              // Time, Difficulty, Servings
              Row(
                children: [
                  _infoChip(
                    Icons.timer_outlined,
                    "${recipe['preparation_time'] ?? 0} min",
                  ),
                  const SizedBox(width: 12),
                  _infoChip(
                    Icons.local_fire_department_outlined,
                    "${recipe['baking_time'] ?? 0} min",
                  ),
                  const SizedBox(width: 12),
                  _infoChip(Icons.trending_up, "Niv. ${recipe['difficulty']}"),
                  const SizedBox(width: 12),
                  _infoChip(Icons.people_outline, "${recipe['person']} pers."),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24), // Space posts
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
