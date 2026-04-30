import 'dart:convert';
import 'package:flutter/material.dart';
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
  bool liked = false;
  int likes = 0;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _init();
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

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    final name = recipe["name"]?.toString() ?? "Recette";
    final username = recipe["username"]?.toString() ?? "Utilisateur";
    final imageUrl = recipe["image_link"]?.toString() ?? "";
    final userId = recipe["user_id"]?.toString();

    final isMine = userId == currentUserId;

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
          )
        else
          Container(
            height: 200,
            color: Colors.grey[300],
          ),

        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),

        // ❤️ seulement si ce n'est pas moi
        if (!isMine)
          Row(
            children: [
              IconButton(
                onPressed: _toggleLike,
                icon: Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  color: liked ? Colors.red : Colors.grey,
                ),
              ),
              Text(likes.toString()),
            ],
          ),

        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }
}
