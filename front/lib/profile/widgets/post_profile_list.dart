import 'package:flutter/material.dart';
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
    );

    if (success) {
      await onRefresh();
      debugPrint("Post modifié");
    } else {
      debugPrint("Erreur modification post");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        const Divider(),
      ],
    );
  }
}
