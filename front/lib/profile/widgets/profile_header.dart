import 'package:flutter/material.dart';
import 'stat_widget.dart';

class ProfileHeader extends StatelessWidget {
  final int publicationsCount;
  final int followers;
  final int following;
  final String username;
  final String description;
  final VoidCallback? onCreatePost;
  final bool isFollowing;
  final bool isFollowLoading;
  final VoidCallback? onToggleFollow;

  const ProfileHeader({
    super.key,
    required this.publicationsCount,
    required this.followers,
    required this.following,
    required this.username,
    required this.description,
    required this.onCreatePost,
    required this.isFollowing,
    required this.isFollowLoading,
    required this.onToggleFollow,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),

        // AVATAR + FOLLOW
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.orange,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          username.isEmpty ? "Utilisateur" : username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StatWidget(
                          value: publicationsCount.toString(),
                          label: 'Publications',
                        ),
                        const SizedBox(width: 18),
                        StatWidget(
                          value: followers.toString(),
                          label: 'Followers',
                        ),
                        const SizedBox(width: 18),
                        StatWidget(
                          value: following.toString(),
                          label: 'Suivi(e)s',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (description.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      description,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              if (onToggleFollow != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    height: 32,
                    child: FilledButton(
                      onPressed: isFollowLoading ? null : onToggleFollow,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black87,
                        disabledBackgroundColor: Colors.grey.shade100,
                        disabledForegroundColor: Colors.grey.shade500,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                      child: isFollowLoading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(isFollowing ? 'Ne plus suivre' : 'Suivre'),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // BUTTON VISIBLE ON MY PROFILE
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
