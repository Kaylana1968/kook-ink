import 'package:flutter/material.dart';
import 'package:front/home/widgets/comment_bottom_sheet.dart';
import 'package:front/home/widgets/feed_user_header.dart';
import 'package:front/widgets/app_feedback.dart';
import 'package:front/widgets/like_button.dart';
import 'package:go_router/go_router.dart';
import '../services/profile_api_service.dart';

class PostProfileCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final Future<void> Function() onRefresh;
  final bool isMyPost;
  final String username;

  const PostProfileCard({
    super.key,
    required this.post,
    required this.onRefresh,
    required this.isMyPost,
    required this.username,
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
    if (postId is! int) return;

    try {
      final success = await ProfileApiService.deletePost(postId);

      if (success) {
        await widget.onRefresh();
        if (!mounted) return;
        showAppFeedback(context, "Post supprimé");
        debugPrint("Post supprimé");
      } else {
        if (!mounted) return;

        showAppFeedback(
          context,
          "Impossible de supprimer le post",
          isError: true,
        );
        debugPrint("Erreur suppression post");
      }
    } catch (e) {
      if (!mounted) return;
      showAppFeedback(context, "Erreur réseau pendant la suppression : $e",
          isError: true);
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

    try {
      final success = await ProfileApiService.updatePost(
        widget.post['id'],
        newDescription,
        imageLink: widget.post['image_link']?.toString(),
      );

      if (success) {
        await widget.onRefresh();
        if (!mounted) return;
        showAppFeedback(context, "Post modifié");
        debugPrint(" modifié");
      } else {
        if (mounted) {
          showAppFeedback(context, "Impossible de modifier le post",
              isError: true);
        }
        debugPrint("Erreur modification post");
      }
    } catch (e) {
      if (!mounted) return;
      showAppFeedback(context, "Erreur réseau pendant la modification : $e",
          isError: true);
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
    final description =
        widget.post['description']?.toString() ?? 'Post sans description';
    final ownerName = _ownerName(widget.post, widget.username);
    final ownerId = widget.post['user_id'];

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FeedUserHeader(username: ownerName, userId: ownerId),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        description,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (imageUrl.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
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
                  ],
                ),
              ),
              if (postId is int)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                  child: Row(
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
                        mouseCursor: SystemMouseCursors.click,
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.mode_comment_outlined,
                                size: 18,
                                color: Colors.black87,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _commentLabel(_commentsCount),
                                style: const TextStyle(
                                  color: Colors.black87,
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
            ],
          ),
          if (widget.isMyPost)
            Positioned(
              top: 2,
              right: 4,
              child: PopupMenuButton<String>(
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

  String _ownerName(Map<String, dynamic> post, String profileUsername) {
    final postUsername = post['username']?.toString().trim();
    if (postUsername != null && postUsername.isNotEmpty) {
      return postUsername;
    }

    final fallbackUsername = profileUsername.trim();
    if (fallbackUsername.isNotEmpty) {
      return fallbackUsername;
    }

    return 'Utilisateur';
  }
}
