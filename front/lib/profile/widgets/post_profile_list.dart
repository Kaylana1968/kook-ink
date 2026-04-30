import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/profile_api_service.dart';
import '../../home/services/home_api_service.dart';

class PostProfileCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final Future<void> Function() onRefresh;
  final bool isMyPost;

  const PostProfileCard({
    super.key,
    required this.post,
    required this.onRefresh,
    required this.isMyPost,
  });

  @override
  State<PostProfileCard> createState() => _PostProfileCardState();
}

class _PostProfileCardState extends State<PostProfileCard> {
  bool liked = false;
  int likes = 0;

  @override
  void initState() {
    super.initState();

    if (!widget.isMyPost) {
      _loadLike();
    }
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

  Future<void> _deletePost() async {
    final postId = widget.post['id'];
    if (postId == null) return;

    final success = await ProfileApiService.deletePost(postId);

    if (success) {
      await widget.onRefresh();
      debugPrint("Post supprimé");
    } else {
      debugPrint("Erreur suppression post");
    }
  }

  Future<void> _editPost(BuildContext context) async {
    final controller = TextEditingController(
      text: widget.post['description'] ?? '',
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
      widget.post['id'],
      newDescription,
    );

    if (success) {
      await widget.onRefresh();
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
          title: Text(widget.post['description'] ?? ''),
          trailing: widget.isMyPost
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
              : Row(
                  mainAxisSize: MainAxisSize.min,
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
        ),
        const Divider(),
      ],
    );
  }
}
