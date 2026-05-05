import 'package:flutter/material.dart';
import 'package:front/home/widgets/comment_bottom_sheet.dart';
import 'package:front/home/widgets/feed_user_header.dart';
import 'package:front/widgets/like_button.dart';
import 'package:go_router/go_router.dart';
import '../services/profile_api_service.dart';

class FavorisList extends StatefulWidget {
  final int? userId;

  const FavorisList({super.key, this.userId});

  @override
  State<FavorisList> createState() => _FavorisListState();
}

class _FavorisListState extends State<FavorisList> {
  late Future<List<dynamic>> _favoritesFuture;
  final Map<String, int> _commentsCounts = {};

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _loadFavorites();
  }

  @override
  void didUpdateWidget(covariant FavorisList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.userId != widget.userId) {
      _commentsCounts.clear();
      _favoritesFuture = _loadFavorites();
    }
  }

  Future<List<dynamic>> _loadFavorites() {
    return widget.userId == null
        ? ProfileApiService.fetchFavorites()
        : ProfileApiService.fetchUserFavorites(widget.userId!);
  }

  int _commentsCount(String type, int itemId, Map<String, dynamic> item) {
    final key = _commentsKey(type, itemId);
    final localCount = _commentsCounts[key] ?? 0;
    final apiCount =
        int.tryParse(item["comments_count"]?.toString() ?? "") ?? 0;
    return localCount > apiCount ? localCount : apiCount;
  }

  Future<void> _openComments({
    required String type,
    required int itemId,
    required int currentCount,
  }) async {
    final hasNewComment = await showCommentsBottomSheet(
      context: context,
      type: type,
      itemId: itemId,
    );

    if (!hasNewComment || !mounted) return;

    setState(() {
      _commentsCounts[_commentsKey(type, itemId)] = currentCount + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _favoritesFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _emptyFavorites("Erreur lors du chargement des favoris");
        }

        final favorites = snapshot.data ?? [];

        if (favorites.isEmpty) {
          return _emptyFavorites("Aucun favori");
        }

        return ListView.builder(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final favorite = favorites[index];
            final type = favorite["type"];
            final item = favorite["item"];
            final likesCount =
                int.tryParse(item["likes_count"]?.toString() ?? "") ?? 0;
            final ownerName = _ownerName(item);
            final ownerId = item["user_id"];
            final itemId = item["id"];

            if (type == "post" && itemId is int) {
              final commentsCount = _commentsCount('post', itemId, item);
              final description =
                  item["description"]?.toString() ?? "Post sans description";
              final imageUrl = item["image_link"]?.toString() ?? "";

              return _FavoriteTile(
                ownerName: ownerName,
                ownerId: ownerId,
                onContentTap: () => context.push('/detail/post/$itemId'),
                content: Column(
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
                actions: _favoriteActions(
                  type: 'post',
                  itemId: itemId,
                  likesCount: likesCount,
                  commentsCount: commentsCount,
                  onCommentsTap: () => _openComments(
                    type: 'post',
                    itemId: itemId,
                    currentCount: commentsCount,
                  ),
                ),
              );
            }

            if (type == "recipe" && itemId is int) {
              final commentsCount = _commentsCount('recipe', itemId, item);
              final name = item["name"]?.toString() ?? "Recette";
              final imageUrl = item["image_link"]?.toString() ?? "";

              return _FavoriteTile(
                ownerName: ownerName,
                ownerId: ownerId,
                onContentTap: () => context.push('/detail/recipe/$itemId'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${item["preparation_time"] ?? 0} min - "
                            "${item["person"] ?? 0} pers - "
                            "Niv ${item["difficulty"] ?? 0}",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: _favoriteActions(
                  type: 'recipe',
                  itemId: itemId,
                  likesCount: likesCount,
                  commentsCount: commentsCount,
                  onCommentsTap: () => _openComments(
                    type: 'recipe',
                    itemId: itemId,
                    currentCount: commentsCount,
                  ),
                ),
              );
            }

            return const SizedBox();
          },
        );
      },
    );
  }
}

Widget _emptyFavorites(String message) {
  return Center(child: Text(message));
}

class _FavoriteTile extends StatelessWidget {
  final String ownerName;
  final dynamic ownerId;
  final VoidCallback onContentTap;
  final Widget content;
  final Widget actions;

  const _FavoriteTile({
    required this.ownerName,
    required this.ownerId,
    required this.onContentTap,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FeedUserHeader(username: ownerName, userId: ownerId),
          InkWell(
            onTap: onContentTap,
            mouseCursor: SystemMouseCursors.click,
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            focusColor: Colors.transparent,
            child: content,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
            child: actions,
          ),
        ],
      ),
    );
  }
}

Widget _favoriteActions({
  required String type,
  required int itemId,
  required int likesCount,
  required int commentsCount,
  required VoidCallback onCommentsTap,
}) {
  return Row(
    children: [
      LikeButton(
        type: type,
        itemId: itemId,
        compact: true,
        initialCount: likesCount,
      ),
      const SizedBox(width: 12),
      _commentsInfo(commentsCount, onTap: onCommentsTap),
    ],
  );
}

Widget _commentsInfo(int count, {required VoidCallback onTap}) {
  return InkWell(
    borderRadius: BorderRadius.circular(20),
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.mode_comment_outlined,
            size: 18,
            color: Colors.black87,
          ),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

String _ownerName(Map<String, dynamic> item) {
  return item["first_name"]?.toString().trim().isNotEmpty == true
      ? item["first_name"].toString()
      : item["prenom"]?.toString().trim().isNotEmpty == true
          ? item["prenom"].toString()
          : item["username"]?.toString().trim().isNotEmpty == true
              ? item["username"].toString()
              : "Utilisateur";
}

String _commentsKey(String type, int itemId) {
  return "$type:$itemId";
}
