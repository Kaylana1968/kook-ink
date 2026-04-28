import 'package:flutter/material.dart';
import 'package:front/main.dart';

class FeedUserHeader extends StatelessWidget {
  final String username;
  final dynamic userId;

  const FeedUserHeader({
    super.key,
    required this.username,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: userId == null
          ? null
          : () {
              MyHomePage.openUserProfile(userId);
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.orange,
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              username,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            const Icon(Icons.more_horiz),
          ],
        ),
      ),
    );
  }
}
