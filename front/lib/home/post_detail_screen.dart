import 'package:flutter/material.dart';
import 'package:front/home/services/detail_api_service.dart';
import 'package:front/home/widgets/comment_section.dart';
import 'package:front/home/widgets/feed_user_header.dart';
import 'package:front/widgets/like_button.dart';
import 'package:go_router/go_router.dart';

class PostDetailScreen extends StatelessWidget {
  final int postId;

  const PostDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: DetailApiService.fetchPost(postId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final post = snapshot.data!;
          final description = post['description']?.toString() ?? '';
          final imageUrl = post['image_link']?.toString() ?? '';
          final username = post['username']?.toString() ?? 'Utilisateur';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FeedUserHeader(
                  username: username,
                  userId: post['user_id'],
                ),
                if (imageUrl.isNotEmpty)
                  Image.network(
                    imageUrl,
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    description,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: LikeButton(type: 'post', itemId: postId),
                ),
                const Divider(height: 24),
                CommentSection(
                  loadComments: () =>
                      DetailApiService.fetchPostComments(postId),
                  onSubmit: (content) =>
                      DetailApiService.createPostComment(postId, content),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
