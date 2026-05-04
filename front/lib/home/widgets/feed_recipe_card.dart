import 'package:flutter/material.dart';
import 'package:front/widgets/like_button.dart';
import 'package:go_router/go_router.dart';
import 'comment_bottom_sheet.dart';
import 'feed_user_header.dart';

class FeedRecipeCard extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final Future<void> Function()? onCommentsChanged;

  const FeedRecipeCard({
    super.key,
    required this.recipe,
    this.onCommentsChanged,
  });

  @override
  State<FeedRecipeCard> createState() => _FeedRecipeCardState();
}

class _FeedRecipeCardState extends State<FeedRecipeCard> {
  late int _commentsCount;

  @override
  void initState() {
    super.initState();
    _commentsCount = _readCommentsCount();
  }

  @override
  void didUpdateWidget(covariant FeedRecipeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recipe['comments_count'] != widget.recipe['comments_count']) {
      _commentsCount = _readCommentsCount();
    }
  }

  int _readCommentsCount() {
    return int.tryParse(
          widget.recipe['comments_count']?.toString() ?? '',
        ) ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final name = recipe["name"]?.toString() ?? "Recette";
    final username = recipe["username"]?.toString() ?? "Utilisateur";
    final imageUrl = recipe["image_link"]?.toString() ?? "";
    final userId = recipe["user_id"];
    final recipeId = recipe["id"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FeedUserHeader(username: username, userId: userId),
        InkWell(
          onTap: recipeId is int
              ? () => context.push('/detail/recipe/$recipeId')
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      child:
                          const Center(child: Icon(Icons.image_not_supported)),
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
            ],
          ),
        ),
        if (recipeId is int)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(
              children: [
                LikeButton(type: 'recipe', itemId: recipeId),
                TextButton.icon(
                  onPressed: () async {
                    final hasNewComment = await showCommentsBottomSheet(
                      context: context,
                      type: 'recipe',
                      itemId: recipeId,
                    );
                    if (hasNewComment && mounted) {
                      setState(() => _commentsCount++);
                    }
                    await widget.onCommentsChanged?.call();
                  },
                  icon: const Icon(Icons.mode_comment_outlined),
                  label: Text(_commentLabel(_commentsCount)),
                ),
              ],
            ),
          ),
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }

  String _commentLabel(int count) {
    if (count == 0) return '0 commentaire';
    if (count == 1) return '1 commentaire';
    return '$count commentaires';
  }
}
