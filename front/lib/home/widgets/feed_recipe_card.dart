import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:front/authentification/auth_service.dart';
import 'feed_user_header.dart';
import '../services/home_api_service.dart';

class FeedRecipeCard extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const FeedRecipeCard({
    super.key,
    required this.recipe,
  });

  @override
  State<FeedRecipeCard> createState() => _FeedRecipeCardState();
}

class _FeedRecipeCardState extends State<FeedRecipeCard> {
  final TextEditingController commentController = TextEditingController();

  bool liked = false;
  int likes = 0;
  int commentCount = 0;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final token = await AuthService.getToken();

    if (token != null) {
      final parts = token.split('.');
      if (parts.length == 3) {
        final payload = utf8.decode(
          base64Url.decode(base64Url.normalize(parts[1])),
        );
        final data = jsonDecode(payload);
        currentUserId = data['id']?.toString();
      }
    }

    await _loadLike();
    await _loadCommentCount();
  }

  Future<void> _loadLike() async {
    final data = await HomeApiService.getRecipeLike(widget.recipe['id']);

    if (!mounted) return;

    setState(() {
      liked = data['liked'];
      likes = data['likes'];
    });
  }

  Future<void> _loadCommentCount() async {
    final data = await HomeApiService.getRecipeComments(widget.recipe['id']);

    if (!mounted) return;

    setState(() {
      commentCount = data.length;
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

  void _openCommentsBottomSheet() async {
    List<dynamic> comments =
        await HomeApiService.getRecipeComments(widget.recipe['id']);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> addComment() async {
              final text = commentController.text.trim();
              if (text.isEmpty) return;

              final success = await HomeApiService.createRecipeComment(
                widget.recipe['id'],
                text,
              );

              if (success) {
                commentController.clear();

                comments = await HomeApiService.getRecipeComments(
                  widget.recipe['id'],
                );

                setModalState(() {});

                if (!mounted) return;

                setState(() {
                  commentCount = comments.length;
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Commentaires",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: comments.isEmpty
                          ? const Center(
                              child: Text("Aucun commentaire"),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final comment = comments[index];

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const CircleAvatar(
                                        radius: 16,
                                        child: Icon(Icons.person, size: 16),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                            children: [
                                              TextSpan(
                                                text:
                                                    "${comment["username"] ?? "Utilisateur"} ",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(
                                                text: comment["content"] ?? "",
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 12,
                        top: 8,
                        bottom: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              decoration: InputDecoration(
                                hintText: "Ajouter un commentaire...",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: addComment,
                            icon: const Icon(Icons.send),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    final name = recipe["name"]?.toString() ?? "Recette";
    final username = recipe["username"]?.toString() ?? "Utilisateur";
    final imageUrl = recipe["image_link"]?.toString() ?? "";
    final userId = recipe["user_id"]?.toString();

    final preparationTime = recipe["preparation_time"] ?? 0;
    final person = recipe["person"] ?? 0;
    final difficulty = recipe["difficulty"] ?? 0;

    final isMine = userId == currentUserId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FeedUserHeader(username: username, userId: userId),
        GestureDetector(
          onTap: () {
            context.go('/recipe-detail/${recipe["id"]}');
          },
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
                      child: const Center(
                        child: Icon(Icons.image_not_supported),
                      ),
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
                      "$preparationTime min • "
                      "$person pers • "
                      "Niv $difficulty",
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
        Row(
          children: [
            if (!isMine) ...[
              IconButton(
                onPressed: _toggleLike,
                icon: Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  color: liked ? Colors.red : Colors.grey,
                ),
              ),
              Text(likes.toString()),
            ],
            IconButton(
              onPressed: _openCommentsBottomSheet,
              icon: const Icon(Icons.chat_bubble_outline),
            ),
            Text(commentCount.toString()),
          ],
        ),
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }
}
