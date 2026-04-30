import 'package:flutter/material.dart';
import '../services/profile_api_service.dart';
import 'post_count_widget.dart';
import 'stat_widget.dart';

class ProfileHeader extends StatefulWidget {
  final Future<List<dynamic>> postFuture;
  final Future<List<dynamic>> recipeFuture;
  final int followers;
  final int following;
  final String username;
  final String description;
  final int userId;
  final bool isMyProfile;
  final VoidCallback? onCreatePost;
  final Future<void> Function()? onRefresh;

  const ProfileHeader({
    super.key,
    required this.postFuture,
    required this.recipeFuture,
    required this.followers,
    required this.following,
    required this.username,
    required this.description,
    required this.userId,
    required this.isMyProfile,
    required this.onCreatePost,
    required this.onRefresh,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  bool isFollowing = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    if (!widget.isMyProfile) {
      _loadFollowStatus();
    } else {
      isLoading = false;
    }
  }

  Future<void> _loadFollowStatus() async {
    if (widget.isMyProfile) return;

    final status = await ProfileApiService.getFollowStatus(widget.userId);

    if (!mounted) return;

    setState(() {
      isFollowing = status;
      isLoading = false;
    });
  }

  Future<void> _toggleFollow() async {
    setState(() {
      isLoading = true;
    });

    final success = isFollowing
        ? await ProfileApiService.unfollowUser(widget.userId)
        : await ProfileApiService.followUser(widget.userId);

    if (!mounted) return;

    if (success) {
      await _loadFollowStatus();

      if (widget.onRefresh != null) {
        await widget.onRefresh!();
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        // AVATAR + STATS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 40),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    PostCountWidget(
                      postFuture: widget.postFuture,
                      recipeFuture: widget.recipeFuture,
                    ),
                    StatWidget(
                      value: widget.followers.toString(),
                      label: 'Followers',
                    ),
                    StatWidget(
                      value: widget.following.toString(),
                      label: 'Suivi(e)s',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.username.isEmpty ? "Utilisateur" : widget.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (!widget.isMyProfile)
                isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : ElevatedButton(
                        onPressed: _toggleFollow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isFollowing ? Colors.grey[300] : Colors.blue,
                        ),
                        child: Text(
                          isFollowing ? "Suivi" : "Suivre",
                          style: TextStyle(
                            color: isFollowing ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
            ],
          ),
        ),

        // DESCRIPTION
        if (widget.description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                widget.description,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),

        // CREATE POST BUTTON
        if (widget.onCreatePost != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: widget.onCreatePost,
                child: const Text('Créer un post'),
              ),
            ),
          ),
      ],
    );
  }
}
