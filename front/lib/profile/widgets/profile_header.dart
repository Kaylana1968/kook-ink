import 'package:flutter/material.dart';
import 'post_count_widget.dart';
import 'stat_widget.dart';

class ProfileHeader extends StatelessWidget {
  final Future<List<dynamic>> postFuture;
  final int followers;
  final int following;
  final VoidCallback onCreatePost;

  const ProfileHeader({
    super.key,
    required this.postFuture,
    required this.followers,
    required this.following,
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
              const CircleAvatar(radius: 40),
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
