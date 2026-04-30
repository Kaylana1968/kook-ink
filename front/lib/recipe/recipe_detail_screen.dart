import 'package:flutter/material.dart';
import '../profile/services/profile_api_service.dart';
import 'services/recipe_api_service.dart';

class RecipeDetailScreen extends StatelessWidget {
  final int recipeId;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: RecipeApiService.fetchRecipeById(recipeId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Erreur chargement recette"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final recipe = snapshot.data!;
          final imageUrl = recipe["image_link"]?.toString() ?? "";
          final steps = recipe["steps"] as List<dynamic>? ?? [];
          final ingredients = recipe["ingredients"] as List<dynamic>? ?? [];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl.isNotEmpty)
                  Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 240,
                    fit: BoxFit.cover,
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe["name"] ?? "Recette",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "${recipe["preparation_time"] ?? 0} min préparation • "
                        "${recipe["baking_time"] ?? 0} min cuisson • "
                        "${recipe["person"] ?? 0} pers. • "
                        "Niv ${recipe["difficulty"] ?? 0}",
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Ingrédients",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...ingredients.map((ingredient) {
                        return Text(
                          "- ${ingredient["quantity"] ?? ""} "
                          "${ingredient["unit"] ?? ""} "
                          "${ingredient["name"] ?? ""}",
                        );
                      }),
                      const SizedBox(height: 24),
                      const Text(
                        "Étapes",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...steps.asMap().entries.map((entry) {
                        final index = entry.key + 1;
                        final step = entry.value;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text("$index. $step"),
                        );
                      }),
                      if ((recipe["tips"] ?? "").toString().isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          "Conseil",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(recipe["tips"]),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
