import 'package:flutter/material.dart';
import 'package:front/home/services/detail_api_service.dart';
import 'package:front/home/widgets/comment_section.dart';
import 'package:front/home/widgets/feed_user_header.dart';
import 'package:front/widgets/like_button.dart';
import 'package:go_router/go_router.dart';

class RecipeDetailScreen extends StatelessWidget {
  final int recipeId;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: DetailApiService.fetchRecipe(recipeId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final recipe = snapshot.data!;
          final imageUrl = recipe['image_link']?.toString() ?? '';
          final steps = recipe['steps'] as List<dynamic>? ?? [];
          final ingredients = recipe['ingredients'] as List<dynamic>? ?? [];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FeedUserHeader(
                  username: recipe['username']?.toString() ?? 'Utilisateur',
                  userId: recipe['user_id'],
                ),
                if (imageUrl.isNotEmpty)
                  Image.network(
                    imageUrl,
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe['name']?.toString() ?? 'Recette',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${recipe["preparation_time"] ?? 0} min • '
                        '${recipe["baking_time"] ?? 0} min cuisson • '
                        '${recipe["person"] ?? 0} pers • '
                        'Niv ${recipe["difficulty"] ?? 0}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      if ((recipe['tips']?.toString() ?? '').isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(recipe['tips'].toString()),
                      ],
                      const SizedBox(height: 16),
                      LikeButton(type: 'recipe', itemId: recipeId),
                      const SizedBox(height: 20),
                      const Text(
                        'Ingrédients',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...ingredients.map((ingredient) {
                        return Text(
                          '- ${ingredient["quantity"] ?? ""} '
                          '${ingredient["unit"] ?? ""} '
                          '${ingredient["name"] ?? ""}',
                        );
                      }),
                      const SizedBox(height: 20),
                      const Text(
                        'Étapes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...steps.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text('${entry.key + 1}. ${entry.value}'),
                        );
                      }),
                    ],
                  ),
                ),
                const Divider(height: 24),
                CommentSection(
                  loadComments: () =>
                      DetailApiService.fetchRecipeComments(recipeId),
                  onSubmit: (content) =>
                      DetailApiService.createRecipeComment(recipeId, content),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
