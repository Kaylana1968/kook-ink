import 'package:flutter/material.dart';
import 'feed_user_header.dart';

class FeedRecipeCard extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const FeedRecipeCard({
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
        FeedUserHeader(username: username, userId: userId),
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
