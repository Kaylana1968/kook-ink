import 'package:flutter/material.dart';
import 'post_count_widget.dart';
import 'stat_widget.dart';

class ProfileHeader extends StatelessWidget {
  final Future<List<dynamic>> postFuture;
  final Future<List<dynamic>> recipeFuture;
  final int followers;
  final int following;
  final String username;
  final String description;
  final VoidCallback? onCreatePost;

  const ProfileHeader({
    super.key,
    required this.postFuture,
    required this.recipeFuture,
    required this.followers,
    required this.following,
    required this.username,
    required this.description,
    required this.onCreatePost,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        // 🔝 AVATAR + STATS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 👤 AVATAR (à gauche)
              const CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 40),
              ),

              const SizedBox(width: 20),

              // 📊 STATS (centrées par rapport à l'avatar)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    PostCountWidget(
                      postFuture: postFuture,
                      recipeFuture: recipeFuture,
                    ),
                    StatWidget(
                      value: followers.toString(),
                      label: 'Followers',
                    ),
                    StatWidget(
                      value: following.toString(),
                      label: 'Suivi(e)s',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 👤 USERNAME + DESCRIPTION (aligné à gauche)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
              if (description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    description,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
            ],
          ),
        ),

        // 🔘 BUTTON
        if (onCreatePost != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onCreatePost,
                child: const Text('Créer un post'),
              ),
            ),
          ),
      ],
    );
  }
}
