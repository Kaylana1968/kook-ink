import 'package:flutter/material.dart';
import 'package:front/widgets/like_button.dart';
import 'package:go_router/go_router.dart';
import 'comment_bottom_sheet.dart';
import 'feed_user_header.dart';

class FeedPostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final Future<void> Function()? onCommentsChanged;

  const FeedPostCard({
    super.key,
    required this.post,
    this.onCommentsChanged,
  });

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  late int _commentsCount;

  @override
  void initState() {
    super.initState();
    _commentsCount = _readCommentsCount();
  }

  @override
  void didUpdateWidget(covariant FeedPostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post['comments_count'] != widget.post['comments_count']) {
      _commentsCount = _readCommentsCount();
    }
  }

  int _readCommentsCount() {
    return int.tryParse(
          widget.post['comments_count']?.toString() ?? '',
        ) ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final username = post['username']?.toString() ?? 'Utilisateur';
    final description = post['description']?.toString() ?? '';
    final imageUrl = post['image_link']?.toString() ?? '';
    final userId = post['user_id'];
    final postId = post['id'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FeedUserHeader(username: username, userId: userId),
        InkWell(
          onTap:
              postId is int ? () => context.push('/detail/post/$postId') : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              if (imageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      height: 220,
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
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                LikeButton(type: 'post', itemId: postId),
                TextButton.icon(
                  onPressed: () async {
                    final hasNewComment = await showCommentsBottomSheet(
                      context: context,
                      type: 'post',
                      itemId: postId,
                    );
                    if (hasNewComment && mounted) {
                      setState(() => _commentsCount++);
                    }
                    await widget.onCommentsChanged?.call();
                  },
                  icon: const Icon(Icons.mode_comment_outlined),
                  label: Text(_commentLabel(_commentsCount)),
                ),
              ],
            ),
          )
        else
          const SizedBox(height: 24),
        const SizedBox(height: 12),
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }

  String _commentLabel(int count) {
    if (count == 0) return '0 commentaire';
    if (count == 1) return '1 commentaire';
    return '$count commentaires';
  }
}
