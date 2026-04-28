import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  Future<void> _deleteRecipe() async {
    final id = recipe['id'];
    if (id == null) return;

    final success = await ProfileApiService.deleteRecipe(id);

    if (success) {
      await onRefresh();
      debugPrint("Recette supprimée");
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = recipe["image_link"] ?? "";

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE (sinon rien)
              if (imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                  child: Image.network(
                    imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                ),

              // INFOS
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
                        recipe['person'] > 1
                            ? "${recipe['person']} personnes"
                            : "${recipe['person']} personne",
                      ),
                  ],
                ),
              ),
            ],
          ),

          // MENU
          Positioned(
            top: 4,
            right: 4,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) async {
                if (value == 'edit') {
                  context.go('/recipe/${recipe["id"]}');
                }

                if (value == 'delete') {
                  await _deleteRecipe();
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
