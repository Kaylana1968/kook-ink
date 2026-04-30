import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuestionCard extends StatelessWidget {
  final int id;
  final int nbReponses;
  final String titre;
  final String contenu;
  final String username;

  const QuestionCard({
    super.key,
    required this.id,
    required this.nbReponses,
    required this.titre,
    required this.contenu,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRespondu = false;

    return InkWell(
      onTap: () => context.go('/forum/$id', extra: titre),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // USER
            Column(
              children: [
                const CircleAvatar(
                  radius: 20,
                  child: Icon(Icons.person, size: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  username,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),

            const SizedBox(width: 12),

            // CONTENU
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITRE
                  Text(
                    titre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // DESCRIPTION
                  Text(
                    contenu,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  // NB REPONSES
                  Row(
                    children: [
                      Text(
                        '$nbReponses réponse${nbReponses > 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      if (isRespondu)
                        const Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.green, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Répondu',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                    ],
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
