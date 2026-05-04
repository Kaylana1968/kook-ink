import 'package:flutter/material.dart';
import 'package:front/widgets/like_button.dart';
import 'feed_user_header.dart';

class FeedPostCard extends StatelessWidget {
  final Map<String, dynamic> post;

  const FeedPostCard({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final username = post['username']?.toString() ?? 'Utilisateur';
    final description = post['description']?.toString() ?? '';
    final userId = post['user_id'];
    final postId = post['id'];

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
        if (postId is int)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: LikeButton(type: 'post', itemId: postId),
          )
        else
          const SizedBox(height: 24),
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }
}
