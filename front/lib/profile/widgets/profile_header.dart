import 'package:flutter/material.dart';
import 'post_count_widget.dart';
import 'stat_widget.dart';

class ProfileHeader extends StatelessWidget {
  final Future<List<dynamic>> postFuture;
  final int followers;
  final int following;
  final String username;
  final String description;
  final VoidCallback? onCreatePost;

  const ProfileHeader({
    super.key,
    required this.postFuture,
    required this.followers,
    required this.following,
    required this.username,
    required this.description,
    required this.onCreatePost,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 40),
              ),
              PostCountWidget(postFuture: postFuture),
              StatWidget(
                value: followers.toString(),
                label: 'Followers',
              ),
              StatWidget(
                value: following.toString(),
                label: 'Following',
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username.isEmpty ? "Utilisateur" : username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (onCreatePost != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCreatePost,
                    child: const Text('Créer un post'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
