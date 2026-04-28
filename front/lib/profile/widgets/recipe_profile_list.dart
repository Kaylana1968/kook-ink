import 'package:flutter/material.dart';
import 'package:front/recipe_screen.dart';
import '../services/profile_api_service.dart';
import 'info_chip.dart';

class RecipeProfileCard extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final Future<void> Function() onRefresh;

  const RecipeProfileCard({
    super.key,
    required this.recipe,
    required this.onRefresh,
  });

  String _getImageUrl() {
    final rawImageUrl = recipe['image_link']?.toString() ?? '';

    if (rawImageUrl.isEmpty) return '';

    if (rawImageUrl.startsWith('http')) {
      return rawImageUrl;
    }

    if (rawImageUrl.startsWith('/')) {
      return '${ProfileApiService.baseUrl}$rawImageUrl';
    }

    return '${ProfileApiService.baseUrl}/$rawImageUrl';
  }

  Future<void> _deleteRecipe(BuildContext context) async {
    final recipeId = recipe['id'];
    if (recipeId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: const Text("Voulez-vous vraiment supprimer cette recette ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await ProfileApiService.deleteRecipe(recipeId);

    if (success) {
      await onRefresh();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recette supprimée ✅")),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur suppression recette")),
        );
      }
    }
  }

  Future<void> _editRecipe(BuildContext context) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeScreen(recipe: recipe),
      ),
    );

    if (updated == true) {
      await onRefresh();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recette modifiée ✅")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getImageUrl();

    final hasValidImage = imageUrl.isNotEmpty &&
        Uri.tryParse(imageUrl) != null &&
        Uri.parse(imageUrl).hasScheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: hasValidImage
                    ? Image.network(
                        imageUrl,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      )
                    : Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe['name'] ?? 'Sans nom',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    infoChip(
                      Icons.timer_outlined,
                      "${recipe['preparation_time'] ?? 0} min",
                    ),
                    infoChip(
                      Icons.local_fire_department_outlined,
                      "${recipe['baking_time'] ?? 0} min",
                    ),
                    if (recipe['difficulty'] != null)
                      infoChip(
                        Icons.trending_up,
                        "Niv. ${recipe['difficulty']}",
                      ),
                    if (recipe['person'] != null)
                      infoChip(
                        Icons.people_outline,
                        "${recipe['person']} pers.",
                      ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 4,
            right: 4,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) async {
                if (value == 'edit') {
                  await _editRecipe(context);
                } else if (value == 'delete') {
                  await _deleteRecipe(context);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Text('Modifier'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Supprimer'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
