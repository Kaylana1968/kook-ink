import 'package:flutter/material.dart';
import 'package:front/home/widgets/comment_bottom_sheet.dart';
import 'package:front/widgets/like_button.dart';
import 'package:go_router/go_router.dart';
import '../services/profile_api_service.dart';
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
  late int _commentsCount;

  @override
  void initState() {
    super.initState();
    _commentsCount = _readCommentsCount();
  }

  @override
  void didUpdateWidget(covariant RecipeProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.recipe['comments_count'] != widget.recipe['comments_count']) {
      final nextCount = _readCommentsCount();
      if (nextCount > _commentsCount) {
        _commentsCount = nextCount;
      }
    }
  }

  int _readCommentsCount() {
    return int.tryParse(widget.recipe['comments_count']?.toString() ?? '') ?? 0;
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

  Future<void> _openComments(int recipeId) async {
    final hasNewComment = await showCommentsBottomSheet(
      context: context,
      type: 'recipe',
      itemId: recipeId,
    );

    if (!hasNewComment || !mounted) return;

    setState(() => _commentsCount++);
    await widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final imageUrl = recipe["image_link"] ?? "";
    final recipeId = recipe["id"];
    final likesCount =
        int.tryParse(recipe['likes_count']?.toString() ?? '') ?? 0;

    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      margin: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: recipeId is int
                ? () => context.push('/detail/recipe/$recipeId')
                : null,
            mouseCursor: recipeId is int
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            focusColor: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGE ?? NULL
                if (imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
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
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
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
                      if (recipeId is int) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            LikeButton(
                              type: 'recipe',
                              itemId: recipeId,
                              compact: true,
                              initialCount: likesCount,
                            ),
                            const SizedBox(width: 12),
                            _commentInfo(
                              _commentsCount,
                              onTap: () => _openComments(recipeId),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // MENU
          widget.isMyRecipe
              ? Positioned(
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
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}

Widget _commentInfo(int count, {required VoidCallback onTap}) {
  return InkWell(
    borderRadius: BorderRadius.circular(20),
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.mode_comment_outlined,
            size: 18,
            color: Colors.black87,
          ),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
