import 'package:flutter/material.dart';
import 'package:front/widgets/like_button.dart';
import 'package:go_router/go_router.dart';
import '../services/profile_api_service.dart';

class PostProfileCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final Future<void> Function() onRefresh;
  final bool isMyPost;

  const PostProfileCard({
    super.key,
    required this.post,
    required this.onRefresh,
    required this.isMyPost,
  });

  Future<void> _deletePost() async {
    final postId = post['id'];
    if (postId == null) return;

    final success = await ProfileApiService.deletePost(postId);

    if (success) {
      await onRefresh();
      debugPrint("Post supprimé");
    } else {
      debugPrint("Erreur suppression post");
    }
  }

  Future<void> _editPost(BuildContext context) async {
    final controller = TextEditingController(
      text: post['description'] ?? '',
    );

    final newDescription = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier le post'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => context.pop(controller.text.trim()),
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    if (newDescription == null || newDescription.isEmpty) return;

    final success = await ProfileApiService.updatePost(
      post['id'],
      newDescription,
      imageLink: post['image_link']?.toString(),
    );

    if (success) {
      await onRefresh();
      debugPrint(" modifié");
    } else {
      debugPrint("Erreur modification post");
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = post['image_link']?.toString() ?? '';
    final postId = post['id'];
    final likesCount = int.tryParse(post['likes_count']?.toString() ?? '') ?? 0;
    final commentsCount =
        int.tryParse(post['comments_count']?.toString() ?? '') ?? 0;

    return Column(
      children: [
        if (imageUrl.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),
        ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text(post['description'] ?? ''),
          trailing: isMyPost
              ? PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      await _editPost(context);
                    }

                    if (value == 'delete') {
                      await _deletePost();
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
                )
              : null,
        ),
        if (postId is int)
          Padding(
            padding: const EdgeInsets.only(left: 64, right: 12, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LikeButton(
                    type: 'post',
                    itemId: postId,
                    compact: true,
                    initialCount: likesCount,
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.mode_comment_outlined,
                    size: 18,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _commentLabel(commentsCount),
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const Divider(),
      ],
    );
  }

  String _commentLabel(int count) {
    if (count == 0) return '0';
    return count.toString();
  }
}
