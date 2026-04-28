import 'package:flutter/material.dart';
import '../forum_detail_screen.dart'; // Ajuste le chemin selon ton projet

class QuestionCard extends StatelessWidget {
  final int id;
  final int nbReponses;
  final int nbVues;
  final String titre;
  final String contenu;

  const QuestionCard({
    super.key,
    required this.id,
    required this.nbReponses,
    required this.nbVues,
    required this.titre,
    required this.contenu,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRespondu = nbReponses > 0;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ForumDetailScreen(
              postId: id,
              title: titre,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$nbReponses réponse${nbReponses > 1 ? 's' : ''}  •  $nbVues vue${nbVues > 1 ? 's' : ''}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
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
            if (isRespondu)
              const Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Répondu',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}