import 'package:flutter/material.dart';
import 'package:front/home/widgets/comment_bottom_sheet.dart';
import 'package:front/widgets/like_button.dart';
import 'package:go_router/go_router.dart';
import '../services/profile_api_service.dart';

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
  late int _commentsCount;

  @override
  void initState() {
    super.initState();
    _commentsCount = _readCommentsCount();
  }

  @override
  void didUpdateWidget(covariant PostProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.post['comments_count'] != widget.post['comments_count']) {
      final nextCount = _readCommentsCount();
      if (nextCount > _commentsCount) {
        _commentsCount = nextCount;
      }
    }
  }

  int _readCommentsCount() {
    return int.tryParse(widget.post['comments_count']?.toString() ?? '') ?? 0;
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
      imageLink: widget.post['image_link']?.toString(),
    );

    if (success) {
      await widget.onRefresh();
      debugPrint(" modifié");
    } else {
      debugPrint("Erreur modification post");
    }
  }

  Future<void> _openComments(int postId) async {
    final hasNewComment = await showCommentsBottomSheet(
      context: context,
      type: 'post',
      itemId: postId,
    );

    if (!hasNewComment || !mounted) return;

    setState(() => _commentsCount++);
    await widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.post['image_link']?.toString() ?? '';
    final postId = widget.post['id'];
    final likesCount =
        int.tryParse(widget.post['likes_count']?.toString() ?? '') ?? 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: postId is int
                ? () => context.push('/detail/post/$postId')
                : null,
            mouseCursor: postId is int
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            focusColor: Colors.transparent,
            child: Column(
              children: [
                if (imageUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
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
                    radius: 16,
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.person, size: 18, color: Colors.white),
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
                      : null,
                ),
              ],
            ),
          ),
          if (postId is int)
            Padding(
              padding: const EdgeInsets.only(left: 64, right: 12),
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
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _openComments(postId),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.mode_comment_outlined,
                              size: 18,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _commentLabel(_commentsCount),
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
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _commentLabel(int count) {
    if (count == 0) return '0';
    return count.toString();
  }
}
