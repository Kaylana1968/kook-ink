import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front/authentification/auth_service.dart';
import 'feed_user_header.dart';
import '../services/home_api_service.dart';

class FeedPostCard extends StatefulWidget {
  final Map<String, dynamic> post;

  const FeedPostCard({
    super.key,
    required this.post,
  });

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
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
    final data = await HomeApiService.getPostLike(widget.post['id']);

    if (!mounted) return;

    setState(() {
      liked = data['liked'];
      likes = data['likes'];
    });
  }

  Future<void> _toggleLike() async {
    if (liked) {
      await HomeApiService.unlikePost(widget.post['id']);
    } else {
      await HomeApiService.likePost(widget.post['id']);
    }

    if (!mounted) return;

    setState(() {
      liked = !liked;
      likes += liked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final username = widget.post['username']?.toString() ?? 'Utilisateur';
    final description = widget.post['description']?.toString() ?? '';
    final userId = widget.post['user_id']?.toString();

    final isMine = userId == currentUserId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FeedUserHeader(username: username, userId: userId),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            description,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
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

        const SizedBox(height: 12),
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }
}
