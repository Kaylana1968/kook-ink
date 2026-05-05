import 'package:flutter/material.dart';
import 'package:front/forum/widgets/forum_response_info.dart';
import 'package:front/home/widgets/feed_user_header.dart';
import 'package:go_router/go_router.dart';

class QuestionCard extends StatelessWidget {
  final int id;
  final int nbReponses;
  final String titre;
  final String contenu;
  final String author;
  final dynamic authorId;

  const QuestionCard({
    super.key,
    required this.id,
    required this.nbReponses,
    required this.titre,
    required this.contenu,
    required this.author,
    this.authorId,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(
        '/forum/$id',
        extra: {
          'title': titre,
          'author': author,
          'user_id': authorId,
        },
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: FeedUserHeader(
                    username: author,
                    userId: authorId,
                    padding: EdgeInsets.zero,
                  ),
                ),
                ForumResponseInfo(count: nbReponses),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              titre,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              contenu,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
