import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/profile_api_service.dart';
import '../../home/services/home_api_service.dart';
import 'info_chip.dart';

class RecipeProfileCard extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final Future<void> Function() onRefresh;
  final bool isMyRecipe;

  const RecipeProfileCard({
    super.key,
    required this.recipe,
    required this.onRefresh,
    required this.isMyRecipe,
  });

  @override
  State<RecipeProfileCard> createState() => _RecipeProfileCardState();
}

class _RecipeProfileCardState extends State<RecipeProfileCard> {
  bool liked = false;
  int likes = 0;

  @override
  void initState() {
    super.initState();

    if (!widget.isMyRecipe) {
      _loadLike();
    }
  }

  Future<void> _loadLike() async {
    final data = await HomeApiService.getRecipeLike(widget.recipe['id']);

    if (!mounted) return;

    setState(() {
      liked = data['liked'];
      likes = data['likes'];
    });
  }

  Future<void> _toggleLike() async {
    if (liked) {
      await HomeApiService.unlikeRecipe(widget.recipe['id']);
    } else {
      await HomeApiService.likeRecipe(widget.recipe['id']);
    }

    if (!mounted) return;

    setState(() {
      liked = !liked;
      likes += liked ? 1 : -1;
    });
  }

  Future<void> _deleteRecipe() async {
    final id = widget.recipe['id'];
    if (id == null) return;

    final success = await ProfileApiService.deleteRecipe(id);

    if (success) {
      await widget.onRefresh();
      debugPrint("Recette supprimée");
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.recipe["image_link"] ?? "";

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recipe['name'] ?? 'Sans nom',
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
                      "${widget.recipe['preparation_time'] ?? 0} min",
                    ),
                    infoChip(
                      Icons.local_fire_department_outlined,
                      "${widget.recipe['baking_time'] ?? 0} min",
                    ),
                    if (widget.recipe['difficulty'] != null)
                      infoChip(
                        Icons.trending_up,
                        "Niv. ${widget.recipe['difficulty']}",
                      ),
                    if (widget.recipe['person'] != null)
                      infoChip(
                        Icons.people_outline,
                        widget.recipe['person'] > 1
                            ? "${widget.recipe['person']} personnes"
                            : "${widget.recipe['person']} personne",
                      ),
                    if (!widget.isMyRecipe)
                      Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: _toggleLike,
                            icon: Icon(
                              liked ? Icons.favorite : Icons.favorite_border,
                              color: liked ? Colors.red : Colors.grey,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            likes.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.isMyRecipe)
            Positioned(
              top: 4,
              right: 4,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) async {
                  if (value == 'edit') {
                    context.go('/recipe/${widget.recipe["id"]}');
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
